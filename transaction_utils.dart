import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';


class TransactionItem {
  final int? id; 
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
}

Map<DateTime, double> calculateDailyIncome(List<TransactionItem> items) {
  return calculateDailyAmounts(items, "Income");
}

Map<DateTime, double> calculateDailySpending(List<TransactionItem> items) {
  return calculateDailyAmounts(items, "Spending");
}

Map<DateTime, double> calculateDailyAmounts(List<TransactionItem> items, String transactionType) {
  Map<DateTime, double> dailyAmounts = {};

  for (var item in items) {
    if (transactionType == "Income" && item.type != "Income") continue;
    if (transactionType == "Spending" && item.type == "Income") continue;
    // ... (rest of the calculation logic remains the same) ...
  }

  return dailyAmounts;
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
