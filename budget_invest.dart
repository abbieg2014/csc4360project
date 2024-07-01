import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'login.dart';
import 'homepage.dart';
import 'database_helper3.dart';

class BudgetPage extends StatefulWidget {
  final int userId;
  final bool isDarkMode;

  const BudgetPage({Key? key, required this.userId, required this.isDarkMode})
      : super(key: key);

  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  bool _isSidebarOpen = false;

  final List<BudgetItem> _budgetItems = [];
  final List<InvestmentItem> _investmentItems = [];
  final TextEditingController _budgetAmountController = TextEditingController();
  final TextEditingController _budgetDescriptionController =
      TextEditingController();
  final TextEditingController _investmentAmountController =
      TextEditingController();
  final TextEditingController _investmentDescriptionController =
      TextEditingController();
  String _budgetType = 'Fixed';
  String _investmentType = 'Stocks';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final budgetItems = await DatabaseHelper().getBudgetItems(widget.userId);
    final investmentItems =
        await DatabaseHelper().getInvestmentItems(widget.userId);

    setState(() {
      _budgetItems.addAll(budgetItems.map((item) => BudgetItem(
            id: item['id'],
            userId: item['user_id'],
            amount: item['amount'],
            type: item['type'],
            description: item['description'],
            dateAdded: DateTime.parse(item['date_added']),
          )));

      _investmentItems.addAll(investmentItems.map((item) => InvestmentItem(
            id: item['id'],
            userId: item['user_id'],
            amount: item['amount'],
            type: item['type'],
            description: item['description'],
            dateAdded: DateTime.parse(item['date_added']),
          )));
    });
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
            icon: Icon(
                widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round), 
            onPressed: () {
               Navigator.pop(context, !widget.isDarkMode);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Theme(  
        data: Theme.of(context).copyWith(
          brightness: widget.isDarkMode ? Brightness.dark : Brightness.light, 
        ),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: _isSidebarOpen
                  ? MediaQuery.of(context).size.width * 0.35
                  : 0,
              child: Visibility(
                visible: _isSidebarOpen,
                child: Container(
                  color: widget.isDarkMode 
                      ? Colors.grey[900]
                      : Colors.grey[200],
                  child: _buildSidebar(context),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: widget.isDarkMode ? Colors.black : Colors.white, 
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildBudgetSection(),
                      _buildInvestmentSection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }


  void _logout() {
     Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          title: const Text('Income/Spending'),
          onTap: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage(userId: widget.userId)));
          },
        ),
        ListTile(
          title: const Text('Budget/Investing'),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildBudgetSection() {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _budgetAmountController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Budget Amount',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _budgetType,
                  items: <String>['Fixed', 'Variable'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _budgetType = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _budgetDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Enter Budget Description',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addBudgetItem,
            child: const Text('+'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _budgetItems.length,
              itemBuilder: (context, index) {
                final item = _budgetItems[index];
                return ListTile(
                  title: Text(
                    '${item.amount} - ${item.type}',
                    style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
                  ),
                  subtitle: Text(
                    '${item.description}\nAdded on: ${DateFormat('yyyy-MM-dd').format(item.dateAdded)}',
                    style: TextStyle(color: widget.isDarkMode ? Colors.grey :Colors.black),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                    onPressed: () => _deleteBudgetItem(index, item.id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addBudgetItem() async {
    final amount = double.parse(_budgetAmountController.text);
    final description = _budgetDescriptionController.text;
    final dateAdded = DateTime.now();

    final id = await DatabaseHelper().addBudgetItem(widget.userId, amount, _budgetType, description, dateAdded.toIso8601String());

    setState(() {
      _budgetItems.add(BudgetItem(
        id: id,
        userId: widget.userId,
        amount: amount,
        type: _budgetType,
        description: description,
        dateAdded: dateAdded,
      ));
      _budgetAmountController.clear();
      _budgetDescriptionController.clear();
    });
  }

  Future<void> _deleteBudgetItem(int index, int id) async {
    await DatabaseHelper().deleteBudgetItem(id);

    setState(() {
      _budgetItems.removeAt(index);
    });
  }

  Widget _buildInvestmentSection() {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _investmentAmountController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Investment Amount',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _investmentType,
                  items: <String>['Stocks', 'Bonds', 'Real Estate', 'Crypto'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _investmentType = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _investmentDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Enter Investment Description',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addInvestmentItem,
            child: const Text('+'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _investmentItems.length,
              itemBuilder: (context, index) {
                final item = _investmentItems[index];
                return ListTile(
                  title: Text(
                    '${item.amount} - ${item.type}',
                    style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
                  ),
                  subtitle: Text(
                    '${item.description}\nAdded on: ${DateFormat('yyyy-MM-dd').format(item.dateAdded)}',
                    style: TextStyle(color: widget.isDarkMode ? Colors.grey : Colors.black),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                    onPressed: () => _deleteInvestmentItem(index, item.id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addInvestmentItem() async {
    final amount = double.parse(_investmentAmountController.text);
    final description = _investmentDescriptionController.text;
    final dateAdded = DateTime.now();

    final id = await DatabaseHelper().addInvestmentItem(widget.userId, amount, _investmentType, description, dateAdded.toIso8601String());

    setState(() {
      _investmentItems.add(InvestmentItem(
        id: id,
        userId: widget.userId,
        amount: amount,
        type: _investmentType,
        description: description,
        dateAdded: dateAdded,
      ));
      _investmentAmountController.clear();
      _investmentDescriptionController.clear();
    });
  }

  Future<void> _deleteInvestmentItem(int index, int id) async {
    await DatabaseHelper().deleteInvestmentItem(id);

    setState(() {
      _investmentItems.removeAt(index);
    });
  }
}

class BudgetItem {
  final int id;
  final int userId;
  final double amount;
  final String type;
  final String description;
  final DateTime dateAdded;

  BudgetItem({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    required this.dateAdded,
  });
}

class InvestmentItem {
  final int id;
  final int userId;
  final double amount;
  final String type;
  final String description;
  final DateTime dateAdded;

  InvestmentItem({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    required this.dateAdded,
  });
}
