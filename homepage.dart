import 'package:flutter/material.dart';
import 'incomeandexpense.dart';
import 'login.dart';
import 'budget_invest.dart';

class HomePage extends StatefulWidget {
  final int userId;
  const HomePage({super.key, required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isDarkMode = false; // Initialize to false
  bool _isSidebarOpen = false;
  String _selectedItem = 'Item 1'; 

  @override
  void initState() {
    super.initState();
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
  });

  Widget page;
  if (item == 'Income/Spending') {
    page = IncomeAndExpensePage(isDarkMode: _isDarkMode); 
  } else if (item == 'Budget/Investing') {
    page = (widget.userId != null)
        ? BudgetPage(userId: widget.userId!, isDarkMode: _isDarkMode) 
        : const Center(child: Text('Error: User ID not found'));
  } else {
    page = const Center(child: Text('No content'));
  }

  Navigator.push(context, MaterialPageRoute(builder: (context) => page)).then((newIsDarkMode){ //Changed to Navigator.push
    if (newIsDarkMode != null) {
      setState(() {
        _isDarkMode = newIsDarkMode;
      });
    }
  });
}


  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()), 
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
              child: _selectedItem == 'Item 1' 
                ? const Center(child: Text("Select from the sidebar"))
                : Container(), 
          ),
          ),
        ],
      ),
    );
  }
}
