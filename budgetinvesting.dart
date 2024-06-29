import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts; 
import 'database_helper2.dart';
import 'transaction_utils.dart';

class BudgetInvestingPage extends StatefulWidget {
  const BudgetInvestingPage({super.key});

  @override
  _BudgetInvestingPageState createState() => _BudgetInvestingPageState();
}

class _BudgetInvestingPageState extends State<BudgetInvestingPage> {
  List<BudgetCategory> _budgetCategories = [];
  bool _isLoading = true; // Declare _isLoading as a property of the State class

  @override
  void initState() {
    super.initState();
    _loadBudgetCategories(); // Load categories on initialization
  }

  Future<void> _loadBudgetCategories() async {
    try {
      final categories = await DatabaseHelper().getBudgetCategories();
      setState(() {
        _budgetCategories = categories;
        _isLoading = false; // Data loaded, turn off loading
      });
    } catch (e) {
      // Handle potential errors during data loading
      print("Error loading categories: $e");
      setState(() {
        _isLoading = false;
      });
      //  might want to display an error message to the user here
    }
  }

  void _showAddCategoryDialog() {
    TextEditingController categoryNameController = TextEditingController();
    TextEditingController budgetAmountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Budget Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: categoryNameController,
                decoration: const InputDecoration(labelText: 'Category Name'),
              ),
              TextField(
                controller: budgetAmountController,
                decoration: const InputDecoration(labelText: 'Budget Amount'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                String categoryName = categoryNameController.text;
                double budgetAmount = double.tryParse(budgetAmountController.text) ?? 0.0;
                await DatabaseHelper().addBudgetCategory(categoryName, budgetAmount); 
                _loadBudgetCategories(); // Refresh the list
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<charts.Series<BudgetSegment, String>> pieChartData = _generatePieChartData(_budgetCategories);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget & Investing'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_budgetCategories.isNotEmpty)
                  SizedBox(
                    height: 200,
                    child: charts.PieChart(
                      pieChartData,
                      animate: true,
                      defaultRenderer: charts.ArcRendererConfig(
                        arcWidth: 60,
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _budgetCategories.length,
                    itemBuilder: (context, index) {
                      final category = _budgetCategories[index];
                      return ListTile(
                        title: Text(category.name),
                        trailing: Text('\$${category.amount.toStringAsFixed(2)}'),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  List<charts.Series<BudgetSegment, String>> _generatePieChartData(List<BudgetCategory> categories) {
    final data = categories.map((category) => BudgetSegment(category.name, category.amount)).toList();

    return [
      charts.Series<BudgetSegment, String>(
        id: 'Budget',
        domainFn: (BudgetSegment segment, _) => segment.category,
        measureFn: (BudgetSegment segment, _) => segment.amount,
        data: data,
        labelAccessorFn: (BudgetSegment segment, _) => '\$${segment.amount.toStringAsFixed(2)}',
      )
    ];
  }
}
