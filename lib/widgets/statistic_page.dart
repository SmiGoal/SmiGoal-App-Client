import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/sms_message.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  List<SMSMessage> messages = [
    SMSMessage(sender: 'a', content: 'b', timestamp: DateTime.now(), isSmishing: false),
    SMSMessage(sender: 'a', content: 'b', timestamp: DateTime.now(), isSmishing: true),
    SMSMessage(sender: 'a', content: 'b', timestamp: DateTime.now(), isSmishing: false),
    SMSMessage(sender: 'a', content: 'b', timestamp: DateTime.now(), isSmishing: false),
    SMSMessage(sender: 'a', content: 'b', timestamp: DateTime.now(), isSmishing: false),
    SMSMessage(sender: 'a', content: 'b', timestamp: DateTime.now(), isSmishing: true),
    SMSMessage(sender: 'a', content: 'b', timestamp: DateTime.now(), isSmishing: false),
    SMSMessage(sender: 'a', content: 'b', timestamp: DateTime.now(), isSmishing: false),
    SMSMessage(sender: 'a', content: 'b', timestamp: DateTime.now(), isSmishing: false),
    SMSMessage(sender: 'a', content: 'b', timestamp: DateTime.now(), isSmishing: true),
    SMSMessage(sender: 'a', content: 'b', timestamp: DateTime.now(), isSmishing: false),
    SMSMessage(sender: 'a', content: 'b', timestamp: DateTime.now(), isSmishing: false),
  ];

  void _getMessages() {
    // get Message from DB
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
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                  child: GestureDetector(
                    onTap: () {},
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: message.isSmishing ? Colors.red : Colors.green,
                          child: Icon(message.isSmishing ? Icons.warning : Icons.thumb_up, color: Colors.white),
                        ),
                        title: Text(message.isSmishing ? '스미싱 문자' : '안전한 문자'),
                        subtitle: Text('${message.sender} - ${message.timestamp}'),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
