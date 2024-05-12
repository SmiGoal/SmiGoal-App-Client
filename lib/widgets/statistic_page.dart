import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/message_entity.dart';
import 'list/statistic_list_item.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  List<MessageEntity> messages = [
    MessageEntity(
        sender: 'a',
        message: 'b'*10000,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        thumbnail: "",
        isSmishing: false,
        containsUrl: true,
        id: 1,
        url: ''),
    MessageEntity(
        sender: 'b',
        message: 'c',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        thumbnail: "",
        isSmishing: true,
        containsUrl: true,
        id: 1,
        url: ''),
    MessageEntity(
        sender: 'c',
        message: 'd',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        thumbnail: "",
        isSmishing: false,
        containsUrl: true,
        id: 1,
        url: ''),
    MessageEntity(
        sender: 'd',
        message: 'e',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        thumbnail: "",
        isSmishing: false,
        containsUrl: true,
        id: 1,
        url: ''),
    MessageEntity(
        sender: 'e',
        message: 'f',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        thumbnail: "",
        isSmishing: false,
        containsUrl: true,
        id: 1,
        url: ''),
    MessageEntity(
        sender: 'f',
        message: 'g',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        thumbnail: "",
        isSmishing: true,
        containsUrl: true,
        id: 1,
        url: ''),
    MessageEntity(
        sender: 'g',
        message: 'h',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        thumbnail: "",
        isSmishing: false,
        containsUrl: true,
        id: 1,
        url: ''),
    MessageEntity(
        sender: 'h',
        message: 'i',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        thumbnail: "",
        isSmishing: false,
        containsUrl: true,
        id: 1,
        url: ''),
    MessageEntity(
        sender: 'i',
        message: 'j',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        thumbnail: "",
        isSmishing: false,
        containsUrl: true,
        id: 1,
        url: ''),
    MessageEntity(
        sender: 'j',
        message: 'k',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        thumbnail: "",
        isSmishing: true,
        containsUrl: true,
        id: 1,
        url: ''),
    MessageEntity(
        sender: 'k',
        message: 'l',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        thumbnail: "",
        isSmishing: false,
        containsUrl: true,
        id: 1,
        url: ''),
    MessageEntity(
        sender: 'k',
        message: 'm',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        thumbnail: "",
        isSmishing: false,
        containsUrl: true,
        id: 1,
        url: ''),
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
                return StatisticListItem(message: message);
              },
            ),
          ),
        ],
      ),
    );
  }
}
