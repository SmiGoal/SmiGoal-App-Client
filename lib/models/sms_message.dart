class SMSMessage {
  final String sender;
  final String message;
  final DateTime timestamp;
  final bool isSmishing;

  SMSMessage({
    required this.sender,
    required this.message,
    required this.timestamp,
    required this.isSmishing,
  });
}