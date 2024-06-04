import 'dart:convert';
import 'dart:math';

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
      final String result = await platform.invokeMethod('getSmishingData');
      final List<dynamic> data = jsonDecode(result);
      Map<String, int> countMap = {};
      for (var item in data) {
        final timestamp = item['timestamp'] as int;
        final isSmishing = item['isSmishing'] as bool;

        if (isSmishing) {
          final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
          final monthYear = '${date.year}-${date.month}';
          countMap[monthYear] = (countMap[monthYear] ?? 0) + 1;
        }
      }

      // 최근 3개월의 모든 월을 추가합니다.
      final now = DateTime.now();
      for (int i = 0; i < 3; i++) {
        final month = DateTime(now.year, now.month - i, 1);
        final monthYear = '${month.year}-${month.month}';
        countMap.putIfAbsent(monthYear, () => 0);
      }

      setState(() {
        smishingCountPerMonth = Map.fromEntries(
            countMap.entries.toList()..sort((a, b) => b.key.compareTo(a.key))
        );
      });
    } on PlatformException catch (e) {
      print("Failed to get data: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedKeys = smishingCountPerMonth.keys.toList()
      ..sort((a, b) {
        final aParts = a.split('-');
        final bParts = b.split('-');
        final aDate = DateTime(int.parse(aParts[0]), int.parse(aParts[1]));
        final bDate = DateTime(int.parse(bParts[0]), int.parse(bParts[1]));
        return aDate.compareTo(bDate);
      });

    final maxY = (smishingCountPerMonth.values.reduce((a, b) => a > b ? a : b) * 1.5).ceilToDouble();

    List<BarChartGroupData> barGroups = sortedKeys
        .map(
          (key) => BarChartGroupData(
        x: sortedKeys.indexOf(key),
        barRods: [
          BarChartRodData(
            fromY: 0,
            toY: smishingCountPerMonth[key]!.toDouble(),
            color: Colors.red,
            borderRadius: BorderRadius.zero,
            width: 20,
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 0,
              color: Colors.grey.withOpacity(0.2),
            ),
          ),
        ],
        showingTooltipIndicators: [0],
      ),
    )
        .toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(10,30,10,10),
      child: BarChart(
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          barGroups: barGroups,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= sortedKeys.length) {
                    return Text('');
                  }
                  final monthYear = sortedKeys[index];
                  final month = monthYear.split('-')[1];
                  return Text('$month월');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(value.toInt().toString());
                },
                reservedSize: 28,
                interval: max(1,maxY~/10+1),
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
          ),
          gridData: FlGridData(
            show: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey,
                strokeWidth: 0.5,
              );
            },
            checkToShowHorizontalLine: (value) {
              return value % 1 == 0;
            },
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey, width: 1),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.blueAccent,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final index = group.x.toInt();
                if (index < 0 || index >= sortedKeys.length) {
                  return null;
                }
                final monthYear = sortedKeys[index];
                final month = monthYear.split('-')[1];
                return BarTooltipItem(
                  '',
                  TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: rod.toY.toInt().toString(),
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
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
