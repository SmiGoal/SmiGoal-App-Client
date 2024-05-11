import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/statistic_page.dart';
import '../widgets/analysis_manual_page.dart';
import '../resources/app_resources.dart';
import './chart/circular_chart.dart';

import 'drawer/drawer_page.dart';

class SmiGoal extends StatefulWidget {
  SmiGoal({super.key});

  @override
  State<SmiGoal> createState() => _SmiGoalState();
}

class _SmiGoalState extends State<SmiGoal> with WidgetsBindingObserver {
  String message = "SmiGoal....";
  String sender = "KU";
  String result = "Unknown";
  int ham = 1, spam = 1;
  DateTime timestamp = DateTime.now();
  DateTime? lastPressed;
  CircularChart? chart = null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // final resultHandler = ResultHandler(_getMessage, _getDbDatas);
    // resultHandler.init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
      chart = CircularChart(ham: ham, spam: spam);
    });
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();

    if (lastPressed == null || now.difference(lastPressed!) > Duration(seconds: 2)) {
      lastPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('한 번 더 누르면 종료됩니다.'),
          duration: Duration(seconds: 2),
        ),
      );
      return true; // Prevent pop
    }
    return false; // Allow pop
  }

  @override
  Future<bool> didPopRoute() async {
    final result = await _onWillPop();
    return result;
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
      drawer: const DrawerPage(),
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
                    child: Image.asset(Assets.appIconPath)),
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
            Container(
              padding: edgeInset,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StatisticPage()),
                  );
                },
                child: Card(
                  elevation: 10,
                  color: AppColors.contentColorWhite,
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                          child: Text(
                            '메시지 통계',
                            style: GoogleFonts.nanumGothic(
                              color: Colors.black87,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      CircularChart(ham: ham, spam: spam),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      padding: edgeInset,
                      child: Card(
                        color: AppColors.contentColorBlue,
                        elevation: 10,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "스미싱 피해 신고\n국번 없이 112",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.contentColorWhite,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: edgeInset,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const AnalysisManualPage()),
                          );
                        },
                        child: Card(
                          color: AppColors.contentColorWhite,
                          elevation: 10,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "메시지\n수동 분석",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.lato(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.contentColorBlack,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                    color: AppColors.contentColorBlue,
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
