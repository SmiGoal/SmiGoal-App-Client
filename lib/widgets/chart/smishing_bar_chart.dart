import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';

class SmishingBarChart extends StatefulWidget {
  @override
  _SmishingBarChartState createState() => _SmishingBarChartState();
}

class _SmishingBarChartState extends State<SmishingBarChart> {
  static const platform = MethodChannel('com.example.smigoal/data');
  Map<String, int> smishingCountPerMonth = {};

  @override
  void initState() {
    super.initState();
    _getSmishingData();
  }

  Future<void> _getSmishingData() async {
    try {
      final List<dynamic> result =
          await platform.invokeMethod('getSmishingData');
      Map<String, int> countMap = {};
      for (var item in result) {
        print(item);
        final timestamp = item['timestamp'] as int;
        final isSmishing = item['isSmishing'] as bool;

        if (isSmishing) {
          final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
          final monthYear = '${date.month}-${date.year}';
          countMap[monthYear] = (countMap[monthYear] ?? 0) + 1;
        }
      }
      setState(() {
        smishingCountPerMonth = countMap;
      });
    } on PlatformException catch (e) {
      print("Failed to get data: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> barGroups = smishingCountPerMonth.entries
        .map(
          (entry) => BarChartGroupData(
            x: entry.key.hashCode,
            barRods: [
              BarChartRodData(
                  fromY: 0, toY: entry.value.toDouble(), color: Colors.blue),
            ],
          ),
        )
        .toList();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: barGroups,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final monthYear = smishingCountPerMonth.keys.firstWhere(
                    (key) => key.hashCode == value.toInt(),
                    orElse: () => '',
                  );
                  return Text(monthYear);
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SmishingBarChart(),
  ));
}
