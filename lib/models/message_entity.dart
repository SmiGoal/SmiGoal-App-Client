import 'dart:ffi';

class MessageEntity {
  final int id;
  final String url;
  final String message;
  final String sender;
  final bool containsUrl;
  final int timestamp;
  final bool isSmishing;

  MessageEntity({
    required this.id,
    required this.url,
    required this.message,
    required this.sender,
    required this.containsUrl,
    required this.timestamp,
    required this.isSmishing
  });

  factory MessageEntity.fromMap(Map<String, dynamic> map) {
    return MessageEntity(
        id: map['id'] as int,
        url: map['url'] as String,
        message: map['message'] as String,
        sender: map['sender'] as String,
        containsUrl: map['containsUrl'] as bool,
        timestamp: map['timestamp'] as int,
        isSmishing: map['isSmishing'] as bool
    );
  }
}