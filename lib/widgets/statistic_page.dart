import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smigoal/models/message_entity.dart';
import 'package:smigoal/widgets/chart/smishing_bar_chart.dart';

import '../models/sms_message.dart';
import '../resources/app_resources.dart';
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
          const Expanded(
            flex: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "최근 3개월 내 스미싱 수",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: Assets.nanumSquareNeo,
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          Expanded(flex: 10, child: SmishingBarChart()),
          Expanded(
            flex: 12,
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
