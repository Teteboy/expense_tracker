import 'package:flutter/material.dart';
import 'package:expense_tracker/models/transaction.dart';

class ExpensesScreen extends StatefulWidget {
  @override
  _ExpensesScreenState createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final List<Transaction> _expenses = [];
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Other'; // Default category

  final List<String> _categories = ['Food', 'Transport', 'Shopping', 'Other'];
  String _filterType = 'Day'; // Filter by Day, Week, Month

  @override
  void initState() {
    super.initState();

    // Adding sample data
    _expenses.addAll([
      Transaction(
        title: 'Groceries',
        description: 'Weekly groceries',
        amount: 5500.0,
        category: 'Food',
        date: DateTime.now().subtract(Duration(days: 2)),
      ),
      Transaction(
        title: 'Bus Ticket',
        description: 'Daily commute',
        amount: 1500.0,
        category: 'Transport',
        date: DateTime.now().subtract(Duration(days: 1)),
      ),
    ]);
  }

  // Helper function to group and filter expenses
  Map<DateTime, List<Transaction>> _groupExpenses(String filterType) {
    Map<DateTime, List<Transaction>> groupedExpenses = {};

    for (var expense in _expenses) {
      DateTime dateKey;

      // Grouping logic based on filter type
      if (filterType == 'Day') {
        dateKey = DateTime(expense.date.year, expense.date.month, expense.date.day);
      } else if (filterType == 'Week') {
        final weekStart = expense.date.subtract(Duration(days: expense.date.weekday - 1));
        dateKey = DateTime(weekStart.year, weekStart.month, weekStart.day);
      } else {
        dateKey = DateTime(expense.date.year, expense.date.month);
      }

      if (!groupedExpenses.containsKey(dateKey)) {
        groupedExpenses[dateKey] = [];
      }
      groupedExpenses[dateKey]!.add(expense);
    }

    return groupedExpenses;
  }

  @override
  Widget build(BuildContext context) {
    final groupedExpenses = _groupExpenses(_filterType);

    // Sort dates in descending order
    final sortedDates = groupedExpenses.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Expenses"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filterType = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'Day', child: Text('Day')),
              PopupMenuItem(value: 'Week', child: Text('Week')),
              PopupMenuItem(value: 'Month', child: Text('Month')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: sortedDates.length,
          itemBuilder: (context, index) {
            final date = sortedDates[index];
            final expenses = groupedExpenses[date]!;
            final total = expenses.fold(0.0, (sum, item) => sum + item.amount);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(
                  '${date.toLocal()}'.split(' ')[0],
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text('Total: ${total.toStringAsFixed(2)} FCFA'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ExpenseDetailScreen(
                        expenses: expenses,
                        title: _filterType == 'Day'
                            ? '${date.toLocal()}'.split(' ')[0]
                            : _filterType == 'Week'
                                ? 'Week of ${date.toLocal()}'.split(' ')[0]
                                : 'Month: ${date.month}/${date.year}',
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddExpenseForm,
        child: Icon(Icons.add),
        tooltip: 'Add Expense',
      ),
    );
  }

  void _addExpense() {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) {
      return;
    }

    final expense = Transaction(
      title: _titleController.text,
      description: _descriptionController.text,
      amount: double.parse(_amountController.text),
      category: _selectedCategory,
      date: _selectedDate,
    );

    setState(() {
      _expenses.add(expense);
    });

    Navigator.of(context).pop();

    // Clear form fields
    _titleController.clear();
    _descriptionController.clear();
    _amountController.clear();
    _selectedDate = DateTime.now();
    _selectedCategory = 'Other';
  }

  void _openAddExpenseForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16.0,
            left: 16.0,
            right: 16.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addExpense,
                child: const Text('Add Expense'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ExpenseDetailScreen extends StatelessWidget {
  final List<Transaction> expenses;
  final String title;

  const ExpenseDetailScreen({Key? key, required this.expenses, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            final expense = expenses[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                title: Text(expense.title),
                subtitle: Text(expense.description),
                trailing: Text('${expense.amount.toStringAsFixed(2)} FCFA'),
              ),
            );
          },
        ),
      ),
    );
  }
}
