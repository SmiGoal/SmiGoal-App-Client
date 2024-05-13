class MessageEntity {
  final int? id;
  final List<String>? url;
  final String message;
  final String sender;
  final String thumbnail;
  final bool containsUrl;
  final int timestamp;
  final bool isSmishing;

  MessageEntity({
    required this.id,
    required this.url,
    required this.message,
    required this.sender,
    required this.thumbnail,
    required this.containsUrl,
    required this.timestamp,
    required this.isSmishing
  });

  factory MessageEntity.fromMap(Map<String, dynamic> map) {
    List<String>? urls;
    int? tid;
    if (map['id'] != null) {
      tid = map['id'];
    }
    if (map['url'] != null) {
      urls = List<String>.from(map['url']);
    }
    return MessageEntity(
      id: tid,
      url: urls,
      message: map['message'] as String,
      sender: map['sender'] as String,
      thumbnail: map['thumbnail'] as String,
      containsUrl: map['containsUrl'] as bool,
      timestamp: map['timestamp'] as int,
      isSmishing: map['isSmishing'] as bool
    );
  }
}