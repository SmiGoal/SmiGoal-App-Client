import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/message_entity.dart';
import '../resources/app_resources.dart';

class ResultHandler {
  ResultHandler(this.onReceive, this.showDb);
  final Function(MessageEntity) onReceive;
  final Function(List<MessageEntity>, int, int) showDb;
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
        print(ret);
        onReceive(ret);
        break;

      case "showDb":
        print(call.arguments);
        print(call.arguments['dbDatas']);
        // 안전한 타입 변환을 위해 is를 사용하여 타입 체크
        //   (call.arguments['dbDatas'] as List).forEach((element) {print(element);});
        final jsonString = call.arguments['dbDatas'] as String;
        print(jsonString);
        print(jsonString.runtimeType);
        print(jsonDecode(jsonString).runtimeType);
        final List<dynamic> temp = jsonDecode(jsonString) as List<dynamic>;
        print('temp complete');
        final List<MessageEntity> dbDatas = temp.map((e) => MessageEntity.fromMap(e as Map<String, dynamic>)).toList();

        // 나머지 처리...
        final int ham = call.arguments['ham'];
        final int spam = call.arguments['spam'];
        showDb(dbDatas, ham, spam);
        break;

      default:
        print('Unknown method ${call.method}');

    }
  }
}
