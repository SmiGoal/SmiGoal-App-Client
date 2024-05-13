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
        // print(jsonMap.runtimeType);
        final ret = MessageEntity.fromMap(jsonMap);
        print(ret);
        // final Map<String, dynamic> map = call.arguments as Map<String, dynamic>;
        // final String message = call.arguments['message'];
        // print(message);
        // final String sender = call.arguments['sender'];
        // print(sender);
        // final String result = call.arguments['result'];
        // print(result);
        // final int timestamp = call.arguments['timestamp'];
        // DateTime.fromMillisecondsSinceEpoch(call.arguments['timestamp']);
        // 여기서 메시지 내용, 송신자, 시각 정보를 처리합니다.
        // print("From ${sender}, ${timestamp}: Message: ${message}\n");
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
        // print('after Convert: $dbDatas');

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
