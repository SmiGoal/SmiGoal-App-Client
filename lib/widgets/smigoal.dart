import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smigoal/widgets/chart.dart';

import 'package:smigoal/widgets/settings.dart';

import '../functions/result_handler.dart';

class SmiGoal extends StatefulWidget {
  SmiGoal({super.key});

  @override
  State<SmiGoal> createState() => _SmiGoalState();
}

class _SmiGoalState extends State<SmiGoal> {
  String message = "SmiGoal....";
  String sender = "KU";
  String result = "Unknown";
  int ham=1, spam=1;
  DateTime timestamp = DateTime.now();
  Chart? chart = null;

  @override
  void initState() {
    super.initState();
    final resultHandler = ResultHandler(_getMessage, _getDbDatas);
    resultHandler.init();
  }

  // Future<String> get message async {
  void _getMessage(String message, String sender, String result, int timestamp) {
    setState(() {
      this.message = message;
      this.sender = sender;
      this.result = result;
      this.timestamp = DateTime.fromMillisecondsSinceEpoch(timestamp);
    });
  }

  void _getDbDatas(List dbDatas, int ham, int spam){
    setState(() {
      print('getDB');
      this.ham = ham;
      this.spam = spam;
      chart = Chart(ham: ham, spam: spam);
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Smigoal');

    return Scaffold(
      appBar: AppBar(),
      drawer: const Settings(),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Text(
              '안전을 지키는 중입니다!',
              style: GoogleFonts.lato(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              child: Card(
                child: Chart(ham: ham, spam: spam),
              ),
              padding: EdgeInsets.all(10),
            ),
            Text(message),
            Text(sender),
            Text(result),
            Text(timestamp.toString()),
          ],
        ),
      ),
    );
  }
}
