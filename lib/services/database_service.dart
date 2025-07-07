import 'package:hive_flutter/hive_flutter.dart';

import '../models/chat_session.dart' as local;
import '../models/chat_session.dart'; // Adapterleri import etmek için

class DatabaseService {
  static const String _chatSessionBoxName = 'chatSessions';
  static Box<local.ChatSession>? _chatSessionBox;

  // Hive'ı başlat
  static Future<void> init() async {
    await Hive.initFlutter();

    // Adapterleri kaydet
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ChatSessionAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ChatMessageAdapter());
    }

    // Box'ları aç
    _chatSessionBox = await Hive.openBox<local.ChatSession>(
      _chatSessionBoxName,
    );
  }

  // Yeni sohbet oturumu oluştur
  static Future<local.ChatSession> createChatSession(
    String firstMessage,
  ) async {
    final chatSession = local.ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: local.ChatSession.generateTitle(firstMessage),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      messages: [],
    );

    await _chatSessionBox?.add(chatSession);
    return chatSession;
  }

  // Sohbet oturumuna mesaj ekle
  static Future<void> addMessageToSession(
    local.ChatSession session,
    local.ChatMessage message,
  ) async {
    session.messages.add(message);
    session.updatedAt = DateTime.now();
    await session.save();
  }

  // Tüm sohbet oturumlarını getir
  static List<local.ChatSession> getAllChatSessions() {
    return _chatSessionBox?.values.toList() ?? [];
  }

  // Sohbet oturumlarını tarihe göre sırala
  static List<local.ChatSession> getChatSessionsSorted() {
    final sessions = getAllChatSessions();
    sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sessions;
  }

  // Sohbet oturumunu sil
  static Future<void> deleteChatSession(local.ChatSession session) async {
    await session.delete();
  }

  // Sohbet oturumlarında arama yap
  static List<local.ChatSession> searchChatSessions(String query) {
    if (query.isEmpty) {
      return getChatSessionsSorted();
    }

    final sessions = getAllChatSessions();
    final filteredSessions =
        sessions.where((session) {
          // Başlıkta ara
          final titleMatch = session.title.toLowerCase().contains(
            query.toLowerCase(),
          );

          // Mesajlarda ara
          final messageMatch = session.messages.any(
            (message) =>
                message.content.toLowerCase().contains(query.toLowerCase()),
          );

          return titleMatch || messageMatch;
        }).toList();

    filteredSessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return filteredSessions;
  }

  // Belirli bir sohbet oturumunu getir
  static local.ChatSession? getChatSession(String id) {
    return _chatSessionBox?.values.firstWhere(
      (session) => session.id == id,
      orElse: () => throw Exception('Session not found'),
    );
  }

  // Veritabanını temizle
  static Future<void> clearDatabase() async {
    await _chatSessionBox?.clear();
  }
}
