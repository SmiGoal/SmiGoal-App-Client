import 'dart:core';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/message_entity.dart';

class StatisticListItem extends StatelessWidget {
  StatisticListItem({super.key, required this.message});

  MessageEntity message;

  List<String> titles = ['발신자', '수신 날짜', '메시지 내용'];

  Dialog _showDialog(MessageEntity message) {
    List contents = [message.sender, DateFormat('yyyy년 MM월 dd일').format(DateTime.fromMillisecondsSinceEpoch(message.timestamp)), message.message];
    return Dialog(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 40,
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                color: message.isSmishing
                    ? Colors.red
                    : Colors.green,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: titles.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titles[index]),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 200, // 최대 높이 설정 (필요에 따라 조정)
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              contents[index].toString(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
      child: GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (context) => _showDialog(message));
        },
        child: Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: message.isSmishing ? Colors.red : Colors.green,
              child: Icon(message.isSmishing ? Icons.warning : Icons.thumb_up,
                  color: Colors.white),
            ),
            title: Text(message.isSmishing ? '스미싱 문자' : '안전한 문자'),
            subtitle: Text('${message.sender} - ${DateFormat('yyyy년 MM월 dd일').format(DateTime.fromMillisecondsSinceEpoch(message.timestamp))}'),
          ),
        ),
      ),
    );
  }
}
