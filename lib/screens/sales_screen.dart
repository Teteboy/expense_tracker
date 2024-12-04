import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

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
    return Product(
      barcode: csvData[0]?.toString().trim() ?? '',
      name: csvData[1]?.toString().trim() ?? 'Unnamed Product',
      quantity: int.tryParse(csvData[2]?.toString().trim() ?? '0') ?? 0,
      volume: csvData[3]?.toString().trim() ?? '',
      price: double.tryParse(csvData[4]?.toString().replaceAll(",", ".") ?? '0.0') ?? 0.0,
      retailPrice: double.tryParse(csvData[5]?.toString().replaceAll(",", ".") ?? '0.0') ?? 0.0,
    );
  }
}

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

class SalesScreen extends StatefulWidget {
  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<Sale> _sales = [];
  bool _isLoading = true;
  Map<Product, int> _pendingSales = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCsvData();
  }

  Future<void> _loadCsvData() async {
    try {
      final String fileContent = await DefaultAssetBundle.of(context).loadString('assets/produit.csv');
      final rows = const CsvToListConverter().convert(fileContent, eol: '\n');
      setState(() {
        _products = rows
            .where((row) => row.isNotEmpty && row[0]?.toString().trim().isNotEmpty == true)
            .map((row) => Product.fromCsv(row))
            .toList();
        _filteredProducts = _products;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading CSV: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterProducts(String query) {
    setState(() {
      _searchQuery = query;
      _filteredProducts = _products
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _addPendingSale(Product product, int quantity) {
    setState(() {
      if (quantity > 0 && quantity <= product.quantity) {
        _pendingSales[product] = quantity;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid quantity for ${product.name}')),
        );
      }
    });
  }

  void _saveSales() {
    setState(() {
      _pendingSales.forEach((product, quantity) {
        _sales.add(Sale(product: product, quantity: quantity, date: DateTime.now()));
      });
      _pendingSales.clear();
    });
  }

  Map<String, List<Sale>> _groupSalesByDate() {
    Map<String, List<Sale>> groupedSales = {};
    for (var sale in _sales) {
      String dateKey = DateFormat.yMMMEd().format(sale.date);
      if (!groupedSales.containsKey(dateKey)) {
        groupedSales[dateKey] = [];
      }
      groupedSales[dateKey]!.add(sale);
    }
    return groupedSales;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
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
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: _filterProducts,
                    decoration: InputDecoration(
                      labelText: 'Search by product name',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text('${product.price.toStringAsFixed(2)} FCFA'),
                        trailing: TextButton(
                          onPressed: () {
                            _showQuantityDialog(product);
                          },
                          child: Text('Add'),
                        ),
                      );
                    },
                  ),
                ),
                if (_pendingSales.isNotEmpty)
                  ElevatedButton(
                    onPressed: _saveSales,
                    child: Text('Save Sales (${_pendingSales.length})'),
                  ),
              ],
            ),
    );
  }

  void _showQuantityDialog(Product product) {
    int selectedQuantity = 1;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Quantity for ${product.name}'),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              selectedQuantity = int.tryParse(value) ?? 1;
            },
            decoration: InputDecoration(hintText: 'Enter Quantity'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _addPendingSale(product, selectedQuantity);
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class SalesListScreen extends StatelessWidget {
  final List<Sale> sales;

  SalesListScreen({required this.sales});

  @override
  Widget build(BuildContext context) {
    final groupedSales = groupSalesByDate();
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales List'),
      ),
      body: ListView(
        children: groupedSales.entries.map((entry) {
          // Calculate the total amount sold for this date
          double totalAmount = entry.value.fold(
            0.0,
            (sum, sale) => sum + (sale.quantity * sale.product.price),
          );

          return ExpansionTile(
            title: Text('${entry.key} - Total: ${totalAmount.toStringAsFixed(2)} FCFA'),
            children: entry.value.map((sale) {
              return ListTile(
                title: Text('${sale.product.name}'),
                subtitle: Text('${sale.quantity} units sold'),
                trailing: Text(
                  '${(sale.quantity * sale.product.price).toStringAsFixed(2)} FCFA',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  Map<String, List<Sale>> groupSalesByDate() {
    Map<String, List<Sale>> groupedSales = {};
    for (var sale in sales) {
      String dateKey = DateFormat.yMMMEd().format(sale.date);
      if (!groupedSales.containsKey(dateKey)) {
        groupedSales[dateKey] = [];
      }
      groupedSales[dateKey]!.add(sale);
    }
    return groupedSales;
  }
}
