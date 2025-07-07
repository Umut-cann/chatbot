import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';

import '../models/chat_session.dart' as local;
import '../models/message.dart';
import '../models/messages.dart';
import '../services/database_service.dart';
import '../utils/size.dart';
import '../utils/style.dart';
import 'chat_history_screen.dart';

class ChatScreen extends StatefulWidget {
  final local.ChatSession? existingSession;

  const ChatScreen({Key? key, this.existingSession}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _userMessage = TextEditingController();
  bool isLoading = false;

  // Güvenlik uyarısı: API anahtarınızı asla doğrudan kod içine yazmayın.
  // Güvenli bir şekilde yönetmek için environment variables (ortam değişkenleri) kullanın.
  static const apiKey = "AIzaSyClX1e9O4JPyaEIU9gOe8isxd34-fzVpPI";

  final List<Message> _messages = [];
  local.ChatSession? _currentSession;

  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

  @override
  void initState() {
    super.initState();
    if (widget.existingSession != null) {
      _loadExistingSession();
    }
  }

  void _loadExistingSession() {
    _currentSession = widget.existingSession;
    setState(() {
      _messages.clear();
      for (var chatMessage in _currentSession!.messages) {
        _messages.add(
          Message(
            isUser: chatMessage.isUser,
            message: chatMessage.content,
            date: chatMessage.timestamp,
          ),
        );
      }
      // Mesajları en yeniden en eskiye doğru göstermek için listeyi ters çevir.
      // ListView'da reverse: true kullandığımız için bu adıma gerek kalmıyor.
    });
  }

  Future<void> _saveMessageToDatabase(String content, bool isUser) async {
    try {
      final chatMessage = local.ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        isUser: isUser,
        timestamp: DateTime.now(),
      );

      if (_currentSession == null) {
        _currentSession = await DatabaseService.createChatSession(content);
      }

      await DatabaseService.addMessageToSession(_currentSession!, chatMessage);
    } catch (e) {
      print('Veritabanına kaydetme hatası: $e');
      // Kullanıcıya bir hata mesajı göstermek için SnackBar kullanabilirsiniz.
    }
  }

  void sendMessage() async {
    final message = _userMessage.text.trim();
    if (message.isEmpty) return;

    // Odak noktasını kaldırarak klavyeyi kapat
    FocusScope.of(context).unfocus();
    _userMessage.clear();

    setState(() {
      _messages.insert(0, Message(isUser: true, message: message, date: DateTime.now()));
      isLoading = true;
    });

    await _saveMessageToDatabase(message, true);

    try {
      final content = [Content.text(message)];
      final response = await model.generateContent(content);
      final responseText = response.text ?? "Üzgünüm, yanıt oluşturamadım.";

      setState(() {
        _messages.insert(0, Message(isUser: false, message: responseText, date: DateTime.now()));
      });

      await _saveMessageToDatabase(responseText, false);

    } catch (e) {
      setState(() {
        _messages.insert(0, Message(
          isUser: false,
          message: "Üzgünüm, bir hata oluştu. Lütfen tekrar deneyin.",
          date: DateTime.now(),
        ));
      });
      print("API Hatası: $e");
    } finally {
      // API yanıtı başarılı da olsa, hata da alsa loading durumunu kapat.
      // onAnimatedTextFinished içinde zaten yapılıyor, ama bu daha garantili bir yol.
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Bu fonksiyon artık `finally` bloğunda yönetildiği için daha basit hale getirilebilir
  // veya sadece isLoading durumunu false yapmak için kullanılabilir.
  void onAnimatedTextFinished() {
    if (isLoading) {
      setState(() {
        isLoading = false;
      });
    }
  }
  
  @override
  void dispose() {
    _userMessage.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // DEĞİŞİKLİK 1: Scaffold widget'ı en dış katmana taşındı.
    // Bu, klavye açıldığında Flutter'ın ekranı doğru bir şekilde
    // yeniden boyutlandırmasını sağlar ve "overflow" hatasını önler.
    return Scaffold(
      // resizeToAvoidBottomInset: true (varsayılan değer) sayesinde
      // klavye açıldığında body, klavyenin üstünde kalan alana sığar.
      resizeToAvoidBottomInset: true,
      
      // DEĞİŞİKLİK 2: GestureDetector, Scaffold'un body'si içine alındı.
      // Bu sayede, ekranda herhangi bir yere tıklandığında klavyenin
      // kapanması işlevselliği korunur.
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
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
                      bottom: BorderSide(
                        color: white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(sm),
                        decoration: BoxDecoration(
                          gradient: aiChatGradient,
                          borderRadius: BorderRadius.circular(radiusSmall),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: md),
                      Text('Gemini AI', style: appBarTitle),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChatHistoryScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(sm),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(radiusSmall),
                          ),
                          child: Icon(
                            Icons.history,
                            color: white.withOpacity(0.7),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: sm),
                      Container(
                        padding: const EdgeInsets.all(sm),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(radiusSmall),
                        ),
                        child: Icon(
                          Icons.more_vert,
                          color: white.withOpacity(0.7),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                // Chat Messages
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: md),
                    child: _messages.isEmpty
                        ? _buildWelcomeScreen()
                        : ListView.builder(
                            // `reverse: true` listenin alttan başlamasını sağlar.
                            // Yeni mesajlar eklendikçe yukarı doğru kayar. Bu, sohbet
                            // uygulamaları için standart ve doğru bir yaklaşımdır.
                            reverse: true,
                            itemCount: _messages.length,
                            padding: const EdgeInsets.only(top: lg, bottom: lg),
                            itemBuilder: (context, index) {
                              // Not: reverse: true kullandığımız için mesajları
                              // _messages.insert(0, ...) ile eklemek daha mantıklıdır.
                              // Bu sayede listenin 0. elemanı her zaman en yeni mesaj olur.
                              final message = _messages[index];
                              // Sadece en son AI mesajı için animasyon uygula
                              final bool isMostRecentAiMessage = index == 0 && !message.isUser;

                              return Messages(
                                isUser: message.isUser,
                                message: message.message,
                                date: DateFormat('HH:mm').format(message.date),
                                isAnimating: isMostRecentAiMessage,
                                onAnimatedTextFinished: onAnimatedTextFinished,
                              );
                            },
                          ),
                  ),
                ),

                // Modern Input Field
                Container(
                  padding: const EdgeInsets.fromLTRB(lg, lg, lg, lg),
                  decoration: BoxDecoration(
                    color: glassColor,
                    border: Border(
                      top: BorderSide(color: white.withOpacity(0.1), width: 1),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Container(
                          constraints: const BoxConstraints(
                            minHeight: 48,
                            maxHeight: 120,
                          ),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(radiusLarge),
                            border: Border.all(
                              color: white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: TextFormField(
                            controller: _userMessage,
                            maxLines: null,
                            minLines: 1,
                            style: promptText,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            decoration: InputDecoration(
                              hintText: 'Mesajınızı yazın...',
                              hintStyle: hintText,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: lg,
                                vertical: md,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: md),
                      GestureDetector(
                        onTap: (isLoading || _userMessage.text.trim().isEmpty)
                            ? null // Butonu devre dışı bırak
                            : sendMessage,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: _userMessage.text.trim().isNotEmpty
                                ? sendButtonGradient
                                : null,
                            color: _userMessage.text.trim().isEmpty
                                ? greyDark
                                : null,
                            borderRadius: BorderRadius.circular(radiusLarge),
                            boxShadow: _userMessage.text.trim().isNotEmpty
                                ? [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ]
                                : null,
                          ),
                          // DEĞİŞİKLİK 3: Yükleme göstergesini ortalamak için Center eklendi.
                          child: Center(
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        white,
                                      ),
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Icon(
                                    Icons.arrow_upward_rounded,
                                    color: white,
                                    size: 24,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: SingleChildScrollView( // İçeriğin küçük ekranlarda taşmasını önler
        padding: const EdgeInsets.all(md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(xl),
              decoration: BoxDecoration(
                gradient: aiChatGradient,
                shape: BoxShape.circle, // Daha modern bir görünüm için daire
                boxShadow: [
                  BoxShadow(
                    color: aiChatGradientStart.withOpacity(0.3),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: const Icon(Icons.auto_awesome, color: white, size: 48),
            ),
            const SizedBox(height: xl),
            Text(
              'Gemini AI\'a Hoş Geldiniz',
              style: appBarTitle.copyWith(fontSize: 28),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: md),
            Text(
              'Sorularınızı sormaya başlayın ve\nGemini AI\'ın gücünü keşfedin',
              style: messageText.copyWith(color: greyLight, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: xxl),
            Wrap(
              spacing: md,
              runSpacing: md,
              alignment: WrapAlignment.center,
              children: [
                _buildSamplePrompt('Kod yazmama yardım et'),
                _buildSamplePrompt('Hikaye anlat'),
                _buildSamplePrompt('Soru çöz'),
                _buildSamplePrompt('Fikirler ver'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSamplePrompt(String prompt) {
    return GestureDetector(
      onTap: () {
        _userMessage.text = prompt;
        // Metin kutusuna odaklan ve imleci sona taşı
        _userMessage.selection = TextSelection.fromPosition(
          TextPosition(offset: _userMessage.text.length),
        );
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: lg, vertical: md),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(radiusLarge),
          border: Border.all(color: white.withOpacity(0.1), width: 1),
        ),
        child: Text(
          prompt,
          style: messageText.copyWith(color: greyLight, fontSize: 14),
        ),
      ),
    );
  }
}