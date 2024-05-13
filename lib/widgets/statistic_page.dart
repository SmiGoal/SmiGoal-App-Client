import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smigoal/models/message_entity.dart';

import '../models/sms_message.dart';
import 'list/statistic_list_item.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key, required this.messages});

  final List<MessageEntity> messages;

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  List<SMSMessage> messagesToShow = List.empty();

  @override
  void initState() {
    messagesToShow = widget.messages
        .map((e) => SMSMessage(
        sender: e.sender,
        message: e.message,
        timestamp: DateTime.fromMillisecondsSinceEpoch(e.timestamp),
        isSmishing: e.isSmishing))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('문자 메시지 통계', style: GoogleFonts.lato()),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: BarChart(BarChartData(
              // Bar chart configurations
              barGroups: [
                BarChartGroupData(x: 0, barRods: [
                  BarChartRodData(fromY: 5, color: Colors.red, toY: 10)
                ]),
                BarChartGroupData(x: 1, barRods: [
                  BarChartRodData(fromY: 3, color: Colors.green, toY: 6)
                ]),
                // 추가 데이터...
              ],
              // 다른 차트 설정들...
            )),
          ),
          Expanded(
            flex: 3,
            child: ListView.builder(
              itemCount: messagesToShow.length,
              itemBuilder: (context, index) {
                final message = messagesToShow[index];
                return StatisticListItem(message: message);
              },
            ),
          ),
        ],
      ),
    );
  }
}
