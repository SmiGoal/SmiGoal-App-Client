class SMSMessage {
  final String sender;
  final String content;
  final DateTime timestamp;
  final bool isSmishing;

  SMSMessage({
    required this.sender,
    required this.content,
    required this.timestamp,
    required this.isSmishing,
  });
}