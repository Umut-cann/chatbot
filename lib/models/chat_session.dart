import 'package:hive/hive.dart';

part 'chat_session.g.dart';

@HiveType(typeId: 0)
class ChatSession extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  DateTime updatedAt;

  @HiveField(4)
  List<ChatMessage> messages;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  // İlk mesajdan başlık oluştur
  static String generateTitle(String firstMessage) {
    if (firstMessage.length <= 50) {
      return firstMessage;
    }
    return '${firstMessage.substring(0, 47)}...';
  }
}

@HiveType(typeId: 1)
class ChatMessage extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String content;

  @HiveField(2)
  bool isUser;

  @HiveField(3)
  DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}
