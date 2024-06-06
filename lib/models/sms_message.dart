class SMSMessage {
  final String sender;
  final String message;
  final DateTime timestamp;
  final double hamPercentage;
  final double spamPercentage;
  final bool isSmishing;

  SMSMessage({
    required this.sender,
    required this.message,
    required this.timestamp,
    required this.hamPercentage,
    required this.spamPercentage,
    required this.isSmishing,
  });
}