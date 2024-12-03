import 'package:flutter/material.dart';
import 'package:expense_tracker/screens/dashboard_screen.dart';
import 'package:expense_tracker/screens/statistics_screen.dart';
import 'package:expense_tracker/screens/expenses_screen.dart';
import 'package:expense_tracker/screens/sales_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primaryColor: Color(0xFF4CAF50),
        // Use updated text styles according to Material 3
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(secondary: Color(0xFF8BC34A))
            .copyWith(background: Colors.white),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFF4CAF50), // Green color for selected item
          unselectedItemColor:
              Colors.black54, // Lighter color for unselected items
          backgroundColor: Colors.white, // Background color for the bottom bar
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Color(0xFF4CAF50), // Text color for the button
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Rounded corners
            ),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),
      ),
      home: MyHomePage(),
      routes: {
        '/statistics': (context) => StatisticsScreen(),
        '/expenses': (context) => ExpensesScreen(),
        '/sales': (context) => SalesScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    StatisticsScreen(),
    ExpensesScreen(),
    SalesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        backgroundColor: Color(0xFF4CAF50), // Green background for the app bar
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money),
            label: 'Income',
          ),
        ],
      ),
    );
  }
}
