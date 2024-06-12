import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/sms_message.dart';
import '../widgets/list/statistic_list_item.dart';
import '../functions/result_handler.dart';
import '../models/message_entity.dart';
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
  final Uri _url = Uri.parse(Assets.reportSpamUrl);
  List<MessageEntity> messages = List.empty(growable: true);
  String message = "";
  String sender = "";
  double hamPercentage = .0;
  double spamPercentage = .0;
  bool result = false;
  int ham = 0, spam = 0, doubt = 0;
  DateTime timestamp = DateTime(0);
  DateTime? lastPressed;
  CircularChart? chart;

  final SvgPicture button_analysis = SvgPicture.asset(
    Assets.buttonAnalysisPage,
    width: double.infinity,
    height: double.infinity,
  );
  final SvgPicture button_report = SvgPicture.asset(
    Assets.buttonReportPage,
    width: double.infinity,
    height: double.infinity,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final resultHandler = ResultHandler(_getMessage, _getDbDatas);
    resultHandler.init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Future<String> get message async {
  void _getMessage(MessageEntity entity) {
    setState(() {
      // print(map);
      // final entity = MessageEntity.fromMap(map);
      if (entity.isSmishing) {
        spam++;
      } else {
        if (entity.spamPercentage >= 50) {
          doubt++;
        } else {
          ham++;
        }
      }
      messages.add(entity);
      messages.sort((a, b) => a.timestamp - b.timestamp);
      entity = messages.last;
      message = entity.message;
      sender = entity.sender;
      hamPercentage = entity.hamPercentage;
      spamPercentage = entity.spamPercentage;
      result = entity.isSmishing;
      timestamp = DateTime.fromMillisecondsSinceEpoch(entity.timestamp);
    });
  }

  void _getDbDatas(List<MessageEntity> dbDatas, int ham, int spam, int doubt) {
    setState(() {
      print('getDB');
      this.ham = ham;
      this.spam = spam;
      this.doubt = doubt;
      messages = dbDatas;
      messages.sort((a, b) => a.timestamp - b.timestamp);
      if (dbDatas.isNotEmpty) {
        MessageEntity entity = messages.last;
        message = entity.message;
        sender = entity.sender;
        hamPercentage = entity.hamPercentage;
        spamPercentage = entity.spamPercentage;
        result = entity.isSmishing;
        timestamp = DateTime.fromMillisecondsSinceEpoch(entity.timestamp);
      }
      chart = CircularChart(ham: ham, spam: spam, doubt: doubt);
    });
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();

    if (lastPressed == null ||
        now.difference(lastPressed!) > const Duration(seconds: 2)) {
      lastPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
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

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
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
            ham + spam == 0
                ? Card(
                    child: ListTile(
                      title: Text(
                        "최근 저장된 문자 메시지가 없습니다.",
                        style: GoogleFonts.lato(
                            fontSize: 20, fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : StatisticListItem(
                    message: SMSMessage(
                      sender: sender,
                      message: message,
                      timestamp: timestamp,
                      hamPercentage: hamPercentage,
                      spamPercentage: spamPercentage,
                      isSmishing: result,
                    ),
                  ),
            Container(
              padding: const EdgeInsets.all(8),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return StatisticPage(
                          messages: messages.reversed.toList());
                    }),
                  );
                },
                child: Card(
                  elevation: 10,
                  color: AppColors.contentColorWhite,
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                          child: Text(
                            '메시지 통계',
                            style: TextStyle(
                              fontFamily: Assets.nanumSquareNeo,
                              color: Colors.black87,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: height * 0.33,
                        child: ham + spam > 0
                            ? CircularChart(ham: ham, spam: spam, doubt: doubt)
                            : const Center(
                                child: Text(
                                  '현재 저장된 데이터가 없습니다.',
                                  style: TextStyle(
                                    fontFamily: Assets.nanumSquareNeo,
                                    color: Colors.black87,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                      ),
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
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: InkWell(
                        onTap: () async {
                          _launchUrl();
                        },
                        child: Card(
                          color: AppColors.contentColorBlue,
                          elevation: 10,
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: button_report
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: InkWell(
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
                          child: button_analysis,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
