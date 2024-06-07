import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/message_entity.dart';
import '../resources/app_resources.dart';

class ResultHandler {
  ResultHandler(this.onReceive, this.showDb);
  final Function(MessageEntity) onReceive;
  final Function(List<MessageEntity>, int, int, int) showDb;
  // final platform = MethodChannel('com.example.smigoal/sms');

  Future<void> init() async {
    // await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    platform.setMethodCallHandler(_onMethodCall);
  }

  Future<void> _onMethodCall(MethodCall call) async {
    print("Message Received");
    print(call.method);
    switch (call.method) {
      case "onReceivedSMS":
        print("onReceivedSMS : ${call.arguments}");
        final jsonString = call.arguments as String;
        final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
        final ret = MessageEntity.fromMap(jsonMap);
        onReceive(ret);
        break;

      case "showDb":
        print(call.arguments);
        print(call.arguments['dbDatas']);
        final jsonString = call.arguments['dbDatas'] as String;
        final List<dynamic> temp = jsonDecode(jsonString) as List<dynamic>;
        print('temp complete');
        final List<MessageEntity> dbDatas = temp.map((e) => MessageEntity.fromMap(e as Map<String, dynamic>)).toList();

        // 나머지 처리...
        final int ham = call.arguments['ham'];
        final int spam = call.arguments['spam'];
        final int doubt = call.arguments['doubt'];
        showDb(dbDatas, ham, spam, doubt);
        break;

      default:
        print('Unknown method ${call.method}');

    }
  }
}
