import 'package:flutter/material.dart';

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
  DateTime timestamp = DateTime.now();

  @override
  void initState() {
    super.initState();
    final resultHandler = ResultHandler(_getMessage);
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

  @override
  Widget build(BuildContext context) {
    print('hello');

    return Scaffold(
      appBar: AppBar(),
      drawer: const Settings(),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
