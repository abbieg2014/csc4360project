import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isDarkMode = false;
  bool _isSidebarOpen = false;
  String _selectedItem = 'Item 1';
  final List<TransactionItem> _transactionItems = [];

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
    });
  }

  void _addTransaction(String name, double amount, String type) {
    setState(() {
      DateTime now = DateTime.now();
      _transactionItems.add(TransactionItem(name: name, amount: amount, type: type, dateAdded: now));
    });
  }

  void _showAddTransactionDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    String dropdownValue = 'Entertainment';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Add Transaction'),
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
                    items: <String>[
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
      },
    );
  }

  Widget _buildMainContent() {
    switch (_selectedItem) {
      case 'Income':
        return const Center(child: Text('INCOME'));
      case 'Spending':
        Map<DateTime, double> dailySpendingData = calculateDailySpending(_transactionItems);
        List<charts.Series<TimeSeriesSales, String>> chartData = generateChartData(dailySpendingData);
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: charts.BarChart(
                chartData,
                animate: true,
                barGroupingType: charts.BarGroupingType.grouped,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _transactionItems.length,
                itemBuilder: (context, index) {
                  String formattedDate = DateFormat('yyyy-MM-dd').format(_transactionItems[index].dateAdded);
                  return ListTile(
                    title: Text(
                      _transactionItems[index].name,
                      style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                    ),
                    subtitle: Text(
                      '${_transactionItems[index].amount} - ${_transactionItems[index].type} - $formattedDate',
                      style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _transactionItems.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  onPressed: _showAddTransactionDialog,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('+'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      case 'Investing':
        return const Center(child: Text('INVEST'));
      default:
        return const Center(child: Text('No content'));
    }
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
        ],
      ),
      body: Row(
        children: <Widget>[
          SizedBox(
            width: _isSidebarOpen ? MediaQuery.of(context).size.width * 0.3 : 0,
            child: Visibility(
              visible: _isSidebarOpen,
              child: Container(
                color: _isDarkMode ? Colors.grey[900] : Colors.grey[200],
                child: ListView(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        'Income',
                        style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                      ),
                      onTap: () => _selectItem('Income'),
                    ),
                    ListTile(
                      title: Text(
                        'Spending',
                        style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                      ),
                      onTap: () => _selectItem('Spending'),
                    ),
                    ListTile(
                      title: Text(
                        'Investing',
                        style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                      ),
                      onTap: () => _selectItem('Investing'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: _isDarkMode ? Colors.black : Colors.white,
              child: _buildMainContent(),
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionItem {
  final String name;
  final double amount;
  final String type;
  final DateTime dateAdded;

  TransactionItem({
    required this.name,
    required this.amount,
    required this.type,
    required this.dateAdded,
  });
}

Map<DateTime, double> calculateDailySpending(List<TransactionItem> items) {
  Map<DateTime, double> dailySpending = {};

  for (var item in items) {
    DateTime date = item.dateAdded;
    double amount = item.amount;

    DateTime truncatedDate = DateTime(date.year, date.month, date.day);

    dailySpending.update(truncatedDate, (value) => value + amount,
        ifAbsent: () => amount);
  }

  return dailySpending;
}

List<charts.Series<TimeSeriesSales, String>> generateChartData(
    Map<DateTime, double> data) {
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
