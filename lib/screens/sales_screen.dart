import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart'; // For date formatting

// Sales class to store individual sales transactions
class Sale {
  final Product product;
  final int quantity;
  final DateTime date;

  Sale({
    required this.product,
    required this.quantity,
    required this.date,
  });
}

// Product class remains the same
class Product {
  final String barcode;
  final String name;
  final int quantity;
  final String volume;
  final double price;
  final double retailPrice;

  Product({
    required this.barcode,
    required this.name,
    required this.quantity,
    required this.volume,
    required this.price,
    required this.retailPrice,
  });

  factory Product.fromCsv(List<dynamic> csvData) {
    try {
      return Product(
        barcode: csvData[0].toString().trim(),
        name: csvData[1].toString().trim(),
        quantity: int.tryParse(csvData[2].toString()) ?? 0,
        volume: csvData[3].toString().trim(),
        price: double.tryParse(csvData[4].toString().replaceAll(",", ".")) ?? 0.0,
        retailPrice: double.tryParse(csvData[5].toString().replaceAll(",", ".")) ?? 0.0,
      );
    } catch (e) {
      print('Error parsing row: $csvData');
      throw Exception('Error parsing CSV row: $csvData');
    }
  }
}

class SalesScreen extends StatefulWidget {
  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<Sale> _sales = []; // List to store sales transactions
  String _searchQuery = "";
  Set<int> _selectedProducts = Set<int>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCsvData();
  }

  // Load CSV data from the asset file
  Future<void> _loadCsvData() async {
    try {
      final String fileContent = await DefaultAssetBundle.of(context).loadString('assets/produit.csv');
      if (fileContent.isEmpty) {
        throw Exception('CSV file is empty');
      }
      final List<String> rows = fileContent.split('\n');
      List<List<dynamic>> csvTable = [];
      for (var row in rows) {
        if (row.isNotEmpty) {
          csvTable.add(CsvToListConverter().convert(row)[0]);
        }
      }
      setState(() {
        _products.clear();
        for (var row in csvTable) {
          if (row.isNotEmpty && row[0].toString().isNotEmpty) {
            try {
              _products.add(Product.fromCsv(row));
            } catch (e) {
              print('Skipping invalid row: $row');
            }
          }
        }
        _filteredProducts = List.from(_products);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading CSV file: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load CSV: $e')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Filter the products based on the search query
  void _filterProducts(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredProducts = List.from(_products);
      } else {
        _filteredProducts = _products.where((product) {
          return product.name.toLowerCase().contains(query.toLowerCase()) ||
                 product.barcode.contains(query);
        }).toList();
      }
    });
  }

  // Add sales to the sales list
  void _addSale(Product product, int quantity) {
    setState(() {
      _sales.add(Sale(product: product, quantity: quantity, date: DateTime.now()));
    });
  }

  // Show a dialog to select quantity when a product is tapped
  void _selectQuantity(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int selectedQuantity = 1;
        return AlertDialog(
          title: Text('Select Quantity for ${product.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Available Quantity: ${product.quantity}'),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  selectedQuantity = int.tryParse(value) ?? 1;
                },
                decoration: InputDecoration(hintText: 'Enter Quantity'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (selectedQuantity > 0 && selectedQuantity <= product.quantity) {
                  _addSale(product, selectedQuantity);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid quantity')));
                }
              },
              child: Text('Save Sale'),
            ),
          ],
        );
      },
    );
  }

  // Filter sales by date range
  List<Sale> _filterSales(String period) {
    DateTime now = DateTime.now();
    switch (period) {
      case 'daily':
        return _sales.where((sale) => sale.date.day == now.day && sale.date.month == now.month && sale.date.year == now.year).toList();
      case 'weekly':
        // Assuming a week starts from Sunday
        DateTime startOfWeek = now.subtract(Duration(days: now.weekday));
        return _sales.where((sale) => sale.date.isAfter(startOfWeek) && sale.date.isBefore(now)).toList();
      case 'monthly':
        return _sales.where((sale) => sale.date.month == now.month && sale.date.year == now.year).toList();
      default:
        return _sales;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(
                  onSearch: _filterProducts,
                  products: _products,
                  filteredProducts: _filteredProducts,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              // Navigate to the sales list screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SalesListScreen(sales: _sales),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _filteredProducts.isEmpty
              ? Center(child: Text('No products found'))
              : ListView.builder(
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: ListTile(
                        title: Text(product.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Barcode: ${product.barcode}'),
                            Text('Volume: ${product.volume}'),
                            Text('Quantity: ${product.quantity}'),
                            Text('Price: ${product.price.toStringAsFixed(2)} FCFA'),
                            Text('Retail Price: ${product.retailPrice.toStringAsFixed(2)} FCFA'),
                          ],
                        ),
                        onTap: () => _selectQuantity(product),
                      ),
                    );
                  },
                ),
    );
  }
}

// Sales List Screen to show all sales with filters
class SalesListScreen extends StatelessWidget {
  final List<Sale> sales;

  SalesListScreen({required this.sales});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales List'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              // Filter sales based on selected period
              // e.g., 'daily', 'weekly', 'monthly'
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'daily', child: Text('Daily')),
              PopupMenuItem(value: 'weekly', child: Text('Weekly')),
              PopupMenuItem(value: 'monthly', child: Text('Monthly')),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: sales.length,
        itemBuilder: (context, index) {
          final sale = sales[index];
          return ListTile(
            title: Text('${sale.product.name} - ${sale.quantity} units'),
            subtitle: Text('Sold on ${DateFormat.yMd().format(sale.date)}'),
          );
        },
      ),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate<String> {
  final Function(String) onSearch;
  final List<Product> products;
  final List<Product> filteredProducts;

  ProductSearchDelegate({
    required this.onSearch,
    required this.products,
    required this.filteredProducts,
  });

  @override
  Widget buildSuggestions(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text('Search by name or barcode'),
        ),
        ListTile(
          title: TextField(
            controller: TextEditingController(text: query),
            decoration: InputDecoration(hintText: 'Enter search term'),
            onChanged: onSearch,
          ),
        ),
        if (query.isNotEmpty)
          Expanded(
            child: ListView(
              children: _buildSearchSuggestions(context),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildSearchSuggestions(BuildContext context) {
    List<Product> suggestions = _searchProducts(query);
    return suggestions.map((product) {
      return ListTile(
        title: Text(product.name),
        subtitle: Text(product.barcode),
        onTap: () {
          query = product.name;
          onSearch(query);
          close(context, product.name);
        },
      );
    }).toList();
  }

  List<Product> _searchProducts(String query) {
    if (query.isEmpty) return [];
    return filteredProducts.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
             product.barcode.contains(query);
    }).toList();
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(child: Text('Results for: $query'));
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearch(query);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }
}
