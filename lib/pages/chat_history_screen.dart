import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/chat_session.dart' as local;
import '../services/database_service.dart';
import '../utils/size.dart';
import '../utils/style.dart';
import 'chat_screen.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<local.ChatSession> _chatSessions = [];
  List<local.ChatSession> _filteredSessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatSessions();
  }

  Future<void> _loadChatSessions() async {
    try {
      final sessions = DatabaseService.getChatSessionsSorted();
      setState(() {
        _chatSessions = sessions;
        _filteredSessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchSessions(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSessions = _chatSessions;
      } else {
        _filteredSessions = DatabaseService.searchChatSessions(query);
      }
    });
  }

  Future<void> _deleteChatSession(local.ChatSession session) async {
    try {
      await DatabaseService.deleteChatSession(session);
      _loadChatSessions();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sohbet silindi',
            style: messageText.copyWith(color: backgroundDark),
          ),
          backgroundColor: white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sohbet silinirken hata oluştu',
            style: messageText.copyWith(color: white),
          ),
          backgroundColor: accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Modern App Bar
              Container(
                padding: const EdgeInsets.all(lg),
                decoration: BoxDecoration(
                  color: glassColor,
                  border: Border(
                    bottom: BorderSide(color: white.withOpacity(0.1), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(sm),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(radiusSmall),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: white.withOpacity(0.8),
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: md),
                    Text(
                      'Sohbet Geçmişi',
                      style: appBarTitle.copyWith(fontSize: 20),
                    ),
                    const Spacer(),
                    Text(
                      '${_filteredSessions.length} sohbet',
                      style: messageText.copyWith(
                        color: greyLight,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Container(
                padding: const EdgeInsets.all(lg),
                child: Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(radiusMedium),
                    border: Border.all(color: white.withOpacity(0.1), width: 1),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: promptText,
                    decoration: InputDecoration(
                      hintText: 'Sohbetlerde ara...',
                      hintStyle: hintText,
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: greyDark),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: lg,
                        vertical: md,
                      ),
                    ),
                    onChanged: _searchSessions,
                  ),
                ),
              ),

              // Chat Sessions List
              Expanded(
                child:
                    _isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(primary),
                          ),
                        )
                        : _filteredSessions.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: lg),
                          itemCount: _filteredSessions.length,
                          itemBuilder: (context, index) {
                            final session = _filteredSessions[index];
                            return _buildChatSessionCard(session);
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(xl),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(radiusXLarge),
              border: Border.all(color: white.withOpacity(0.1), width: 1),
            ),
            child: Icon(Icons.chat_bubble_outline, color: greyDark, size: 48),
          ),
          const SizedBox(height: lg),
          Text(
            _searchController.text.isEmpty
                ? 'Henüz sohbet yok'
                : 'Arama sonucu bulunamadı',
            style: appBarTitle.copyWith(fontSize: 20, color: greyLight),
          ),
          const SizedBox(height: sm),
          Text(
            _searchController.text.isEmpty
                ? 'İlk sohbetinizi başlatın'
                : 'Farklı kelimeler deneyebilirsiniz',
            style: messageText.copyWith(color: greyDark, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildChatSessionCard(local.ChatSession session) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(existingSession: session),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: md),
        padding: const EdgeInsets.all(lg),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(radiusMedium),
          border: Border.all(color: white.withOpacity(0.1), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(sm),
                  decoration: BoxDecoration(
                    gradient: aiChatGradient,
                    borderRadius: BorderRadius.circular(radiusSmall),
                  ),
                  child: const Icon(Icons.chat, color: white, size: 16),
                ),
                const SizedBox(width: md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title,
                        style: messageText.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: xs),
                      Text(
                        '${session.messages.length} mesaj',
                        style: dateText.copyWith(color: greyDark),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _showDeleteConfirmation(session);
                    }
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: accent,
                                size: 18,
                              ),
                              const SizedBox(width: sm),
                              Text(
                                'Sil',
                                style: messageText.copyWith(color: accent),
                              ),
                            ],
                          ),
                        ),
                      ],
                  icon: Icon(Icons.more_vert, color: greyDark, size: 18),
                ),
              ],
            ),
            const SizedBox(height: md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(session.updatedAt),
                  style: dateText.copyWith(color: greyDark, fontSize: 12),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: sm,
                    vertical: xs,
                  ),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(radiusSmall),
                  ),
                  child: Text(
                    _getTimeAgo(session.updatedAt),
                    style: dateText.copyWith(color: primary, fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Şimdi';
    }
  }

  void _showDeleteConfirmation(local.ChatSession session) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMedium),
            ),
            title: Text(
              'Sohbeti Sil',
              style: appBarTitle.copyWith(fontSize: 18),
            ),
            content: Text(
              'Bu sohbeti silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
              style: messageText.copyWith(color: greyLight),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'İptal',
                  style: messageText.copyWith(color: greyDark),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteChatSession(session);
                },
                child: Text('Sil', style: messageText.copyWith(color: accent)),
              ),
            ],
          ),
    );
  }
}
