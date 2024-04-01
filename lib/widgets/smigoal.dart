import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import '../resources/app_colors.dart';
import './chart/chart.dart';

import './settings.dart';

class SmiGoal extends StatefulWidget {
  SmiGoal({super.key});

  @override
  State<SmiGoal> createState() => _SmiGoalState();
}

class _SmiGoalState extends State<SmiGoal> {
  String message = "SmiGoal....";
  String sender = "KU";
  String result = "Unknown";
  int ham = 1, spam = 1;
  DateTime timestamp = DateTime.now();
  Chart? chart = null;

  @override
  void initState() {
    super.initState();
    // final resultHandler = ResultHandler(_getMessage, _getDbDatas);
    // resultHandler.init();
  }

  // Future<String> get message async {
  void _getMessage(
      String message, String sender, String result, int timestamp) {
    setState(() {
      this.message = message;
      this.sender = sender;
      this.result = result;
      this.timestamp = DateTime.fromMillisecondsSinceEpoch(timestamp);
    });
  }

  void _getDbDatas(List dbDatas, int ham, int spam) {
    setState(() {
      print('getDB');
      this.ham = ham;
      this.spam = spam;
      chart = Chart(ham: ham, spam: spam);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final height = screenSize.height;
    final width = screenSize.width;
    final edgeInset = EdgeInsets.fromLTRB(
      width * 0.01,
      height * 0.01,
      width * 0.01,
      height * 0.01,
    );

    print('Smigoal');

    return Scaffold(
      appBar: AppBar(),
      drawer: const Settings(),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                    width: height * 0.1,
                    height: height * 0.1,
                    child: Image.asset('assets/icon_smigoal_removed_bg.png')),
                Text(
                  '안전을 지키는 중입니다!',
                  style: GoogleFonts.lato(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const SizedBox(height: 30),
            Container(
              padding: edgeInset,
              child: Card(
                elevation: 10,
                color: AppColors.contentColorWhite,
                child: Chart(ham: ham, spam: spam),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      padding: edgeInset,
                      child: const Card(
                        color: AppColors.contentColorBlue,
                        elevation: 10,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "스미싱 피해 신고",
                              style:
                              TextStyle(color: AppColors.contentColorWhite),
                            ),
                            Text(
                              "국번없이 112",
                              style:
                              TextStyle(color: AppColors.contentColorWhite),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: edgeInset,
                      child: const Card(
                        color: AppColors.contentColorWhite,
                        elevation: 10,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "오늘은 내가 짜파게티 요리사",
                              style:
                              TextStyle(color: AppColors.contentColorBlack),
                            ),
                            Text(
                              "국번없이 112",
                              style:
                              TextStyle(color: AppColors.contentColorBlack),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: height * 0.1,
              child: Expanded(
                child: Container(
                  padding: edgeInset,
                  child: const Card(
                    color: AppColors.contentColorRed,
                    elevation: 10,
                    child: Center(
                      child: Text(
                        "광고 보고 오시죠",
                        style: TextStyle(
                          color: AppColors.contentColorWhite,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Text(message),
            // Text(sender),
            // Text(result),
            // Text(timestamp.toString()),
          ],
        ),
      ),
    );
  }
}
