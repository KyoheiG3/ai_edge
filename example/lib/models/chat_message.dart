enum MessageType { user, assistant, system }

class ChatMessage {
  final String content;
  final MessageType type;
  final DateTime timestamp;

  ChatMessage({required this.content, required this.type, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();
}
