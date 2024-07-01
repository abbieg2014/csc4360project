import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
import 'database_helper2.dart';
import 'transaction_utils.dart';

class IncomeAndExpensePage extends StatefulWidget {
  const IncomeAndExpensePage({super.key}); // Remove transactionType from the constructor

  @override
  _IncomeAndExpensePageState createState() => _IncomeAndExpensePageState();
}

class _IncomeAndExpensePageState extends State<IncomeAndExpensePage> {
  List<TransactionItem> _allTransactionItems = [];
  final bool _isDarkMode = false; 
  String? _selectedType; 

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final transactions = await DatabaseHelper().getTransactions();
    setState(() {
      _allTransactionItems = transactions;
    });
  }

  void _addTransaction(String name, double amount, String type) async {
    DateTime now = DateTime.now();
    final transaction = TransactionItem(
      name: name,
      amount: amount,
      type: type,
      dateAdded: now,
    );
    await DatabaseHelper().insertTransaction(transaction);
    _loadTransactions();
  }

  void _updateTransaction(TransactionItem transaction) async {
    await DatabaseHelper().updateTransaction(transaction);
    _loadTransactions();
  }

  void _deleteTransaction(int id) async {
    await DatabaseHelper().deleteTransaction(id);
    _loadTransactions();
  }

  void _showAddTransactionDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    _selectedType = null; // Reset selected type when dialog opens
    
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
                    value: _selectedType,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedType = newValue!;
                      });
                    },
                    items: <String>['Income', 'Entertainment', 'Food', 'Rent', 'Utilities', 'Others']
                      .map<DropdownMenuItem<String>>((String value) {
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
                    _addTransaction(name, amount, _selectedType!);
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

  void _showEditTransactionDialog(TransactionItem transaction) {
    TextEditingController nameController = TextEditingController(text: transaction.name);
    TextEditingController amountController = TextEditingController(text: transaction.amount.toString());
    _selectedType = transaction.type; 

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Edit Transaction'),
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
                    value: _selectedType,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedType = newValue!;
                      });
                    },
                    items: <String>['Income', 'Entertainment', 'Food', 'Rent', 'Utilities', 'Others']
                      .map<DropdownMenuItem<String>>((String value) {
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
                    TransactionItem updatedTransaction = TransactionItem(
                      id: transaction.id, // Use the transaction object passed to the dialog
                      name: nameController.text,
                      amount: double.tryParse(amountController.text) ?? 0.0,
                      type: _selectedType!,
                      dateAdded: transaction.dateAdded, // Preserve the original date
                    );
                    _updateTransaction(updatedTransaction);
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
  


  Widget buildIncomeExpenseView(
      List<charts.Series<TimeSeriesSales, String>> incomeData,
      List<charts.Series<TimeSeriesSales, String>> expenseData,
      bool isDarkMode) {
    return Column(
      children: [
        // Title for Income
        const Text("Income", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

        // Income Chart
        SizedBox(height: 200, child: charts.BarChart(incomeData, animate: true)),

        // List of Income Transactions
        Expanded(
          child: ListView.builder(
            itemCount: _allTransactionItems.where((item) => item.type == "Income").length,
            itemBuilder: (context, index) {
              final item = _allTransactionItems.where((item) => item.type == "Income").toList()[index];
              String formattedDate = DateFormat('yyyy-MM-dd').format(item.dateAdded);
              return ListTile(
                title: Text(
                  item.name,
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                ),
                subtitle: Text(
                  '${item.amount} - $formattedDate',
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showEditTransactionDialog(item); 
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _deleteTransaction(item.id!);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Title for Expenses
        const Text("Expenses", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

        // Expenses Chart
        SizedBox(height: 200, child: charts.BarChart(expenseData, animate: true)),

        // List of Expense Transactions
        Expanded(
          child: ListView.builder(
            itemCount: _allTransactionItems.where((item) => item.type != "Income").length,
            itemBuilder: (context, index) {
              final item = _allTransactionItems.where((item) => item.type != "Income").toList()[index];
              String formattedDate = DateFormat('yyyy-MM-dd').format(item.dateAdded);
              return ListTile(
                title: Text(
                  item.name,
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                ),
                subtitle: Text(
                  '${item.amount} - $formattedDate',
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showEditTransactionDialog(item); 
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _deleteTransaction(item.id!);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }




  @override
  Widget build(BuildContext context) {
    final incomeData = generateChartData(calculateDailyIncome(_allTransactionItems));
    final expenseData = generateChartData(calculateDailySpending(_allTransactionItems));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Income & Spending'),
      ),
      body: buildIncomeExpenseView(incomeData, expenseData, _isDarkMode),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
