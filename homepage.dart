import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'login.dart';
import 'database_helper2.dart';
import 'budget_invest.dart';

class HomePage extends StatefulWidget {
  final int userId;

  const HomePage({super.key, required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isDarkMode = false;
  bool _isSidebarOpen = false;
  String _selectedItem = 'Income/Spending';
  final List<TransactionItem> _transactionItems = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final transactions = await DatabaseHelper().getTransactions();
    setState(() {
      _transactionItems.clear();
      _transactionItems.addAll(transactions);
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  void _selectItem(String item) {
    setState(() {
      _selectedItem = item;
      _isSidebarOpen = false;  // Close the sidebar when an item is selected
    });

    if (item == 'Budget/Investing') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => BudgetPage(userId: widget.userId)),
      );
    }
  }

  void _addTransaction(String name, double amount, String type) async {
    DateTime now = DateTime.now();
    final transaction = TransactionItem(name: name, amount: amount, type: type, dateAdded: now);
    await DatabaseHelper().insertTransaction(transaction);
    _loadTransactions();
  }

  void _deleteTransaction(int id) async {
    await DatabaseHelper().deleteTransaction(id);
    _loadTransactions();
  }

  void _updateTransaction(TransactionItem transaction) async {
    await DatabaseHelper().updateTransaction(transaction);
    _loadTransactions();
  }

  void _showAddTransactionDialog(String type) {
    TextEditingController nameController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    String dropdownValue = type == 'Income' ? 'Salary' : 'Entertainment';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add $type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              DropdownButton<String>(
                value: dropdownValue,
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                },
                items: type == 'Income'
                    ? <String>[
                  'Salary',
                  'Investment',
                  'Gift',
                  'Others',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList()
                    : <String>[
                  'Entertainment',
                  'Food',
                  'Rent',
                  'Utilities',
                  'Others',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String name = nameController.text;
                double amount = double.tryParse(amountController.text) ?? 0.0;
                _addTransaction(name, amount, dropdownValue);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()), // Replace with your login screen
    );
  }

  Widget _buildContent() {
    Map<DateTime, double> dailySpendingData = calculateDailySpending(_transactionItems);
    List<charts.Series<TimeSeriesSales, String>> spendingChartData = generateChartData(dailySpendingData);
    Map<DateTime, double> dailyIncomeData = calculateDailyIncome(_transactionItems);
    List<charts.Series<TimeSeriesSales, String>> incomeChartData = generateChartData(dailyIncomeData);

    return SingleChildScrollView(
      child: Column(
        children: [
          if (_selectedItem == 'Income/Spending') ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Income:'),
                  FloatingActionButton(
                    onPressed: () => _showAddTransactionDialog('Income'),
                    child: const Icon(Icons.add),
                    mini: true,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200,
              width: double.infinity,
              child: charts.BarChart(
                incomeChartData,
                animate: true,
                barGroupingType: charts.BarGroupingType.grouped,
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _transactionItems.where((item) => item.type == 'Income').length,
              itemBuilder: (context, index) {
                var incomeItems = _transactionItems.where((item) => item.type == 'Income').toList();
                String formattedDate = DateFormat('yyyy-MM-dd').format(incomeItems[index].dateAdded);
                return ListTile(
                  title: Text(
                    incomeItems[index].name,
                    style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                  ),
                  subtitle: Text(
                    '${incomeItems[index].amount} - ${incomeItems[index].type} - $formattedDate',
                    style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteTransaction(incomeItems[index].id!);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Spending:'),
                  FloatingActionButton(
                    onPressed: () => _showAddTransactionDialog('Spending'),
                    mini: true,
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200,
              width: double.infinity,
              child: charts.BarChart(
                spendingChartData,
                animate: true,
                barGroupingType: charts.BarGroupingType.grouped,
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _transactionItems.where((item) => item.type != 'Income').length,
              itemBuilder: (context, index) {
                var spendingItems = _transactionItems.where((item) => item.type != 'Income').toList();
                String formattedDate = DateFormat('yyyy-MM-dd').format(spendingItems[index].dateAdded);
                return ListTile(
                  title: Text(
                    spendingItems[index].name,
                    style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                  ),
                  subtitle: Text(
                    '${spendingItems[index].amount} - ${spendingItems[index].type} - $formattedDate',
                    style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteTransaction(spendingItems[index].id!);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ] else if (_selectedItem == 'Budget/Investing') ...[
            // Add the relevant content for Budget/Investing
          ]
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Finance Manager'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: _toggleSidebar,
        ),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: _toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Row(
        children: <Widget>[
          SizedBox(
            width: _isSidebarOpen ? MediaQuery.of(context).size.width * 0.35 : 0,
            child: Visibility(
              visible: _isSidebarOpen,
              child: Container(
                color: _isDarkMode ? Colors.grey[900] : Colors.grey[200],
                child: ListView(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        'Income/Spending',
                        style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                      ),
                      onTap: () => _selectItem('Income/Spending'),
                    ),
                    ListTile(
                      title: Text(
                        'Budget/Investing',
                        style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                      ),
                      onTap: () => _selectItem('Budget/Investing'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: _isDarkMode ? Colors.black : Colors.white,
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionItem {
  final int? id;  // Make id nullable for cases where the database hasn't yet assigned an ID.
  final String name;
  final double amount;
  final String type;
  final DateTime dateAdded;

  TransactionItem({
    this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.dateAdded,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'type': type,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  // Convert a Map into a TransactionItem. The keys must correspond to the names of the columns in the database.
  static TransactionItem fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id'],
      name: map['name'],
      amount: map['amount'],
      type: map['type'],
      dateAdded: DateTime.parse(map['dateAdded']),
    );
  }
}

Map<DateTime, double> calculateDailySpending(List<TransactionItem> items) {
  Map<DateTime, double> dailySpending = {};

  for (var item in items) {
    if (item.type != 'Income') {
      DateTime date = item.dateAdded;
      double amount = item.amount;

      DateTime truncatedDate = DateTime(date.year, date.month, date.day);

      dailySpending.update(truncatedDate, (value) => value + amount, ifAbsent: () => amount);
    }
  }

  return dailySpending;
}

Map<DateTime, double> calculateDailyIncome(List<TransactionItem> items) {
  Map<DateTime, double> dailyIncome = {};

  for (var item in items) {
    if (item.type == 'Income') {
      DateTime date = item.dateAdded;
      double amount = item.amount;

      DateTime truncatedDate = DateTime(date.year, date.month, date.day);

      dailyIncome.update(truncatedDate, (value) => value + amount, ifAbsent: () => amount);
    }
  }

  return dailyIncome;
}

List<charts.Series<TimeSeriesSales, String>> generateChartData(Map<DateTime, double> data) {
  List<TimeSeriesSales> chartData = [];
  data.forEach((key, value) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(key);
    chartData.add(TimeSeriesSales(formattedDate, value));
  });

  return [
    charts.Series<TimeSeriesSales, String>(
      id: 'Sales',
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (TimeSeriesSales sales, _) => sales.time,
      measureFn: (TimeSeriesSales sales, _) => sales.sales,
      data: chartData,
    ),
  ];
}

class TimeSeriesSales {
  final String time;
  final double sales;

  TimeSeriesSales(this.time, this.sales);
}
