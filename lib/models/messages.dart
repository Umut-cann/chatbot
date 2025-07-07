import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/size.dart';
import '../utils/style.dart';

class Messages extends StatelessWidget {
  final bool isUser;
  final String message;
  final String date;
  final Function onAnimatedTextFinished;
  final bool isAnimating; // Animasyonun aktif olup olmadığını kontrol eder
  final isAnimated = ValueNotifier(false);

  Messages({
    Key? key,
    required this.isUser,
    required this.message,
    required this.date,
    required this.onAnimatedTextFinished,
    this.isAnimating = false, // Varsayılan olarak animasyon kapalı
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: lg,
        left: isUser ? 48 : 0,
        right: isUser ? 0 : 48,
      ),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: aiChatGradient,
                borderRadius: BorderRadius.circular(radiusSmall),
              ),
              child: const Icon(Icons.auto_awesome, color: white, size: 16),
            ),
            const SizedBox(width: sm),
          ],

          Flexible(
            child: Container(
              padding: const EdgeInsets.all(md),
              decoration: BoxDecoration(
                gradient: isUser ? userChatGradient : null,
                color: isUser ? null : surfaceColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(radiusMedium),
                  topRight: const Radius.circular(radiusMedium),
                  bottomLeft:
                      isUser
                          ? const Radius.circular(radiusMedium)
                          : const Radius.circular(xs),
                  bottomRight:
                      isUser
                          ? const Radius.circular(xs)
                          : const Radius.circular(radiusMedium),
                ),
                border:
                    !isUser
                        ? Border.all(color: white.withOpacity(0.1), width: 1)
                        : null,
                boxShadow: [
                  BoxShadow(
                    color:
                        isUser
                            ? primary.withOpacity(0.2)
                            : Colors.black.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isUser)
                    GestureDetector(
                      onLongPress: () async {
                        await Clipboard.setData(ClipboardData(text: message));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Metin kopyalandı',
                              style: messageText.copyWith(
                                color: backgroundDark,
                              ),
                            ),
                            backgroundColor: white,
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(radiusSmall),
                            ),
                          ),
                        );
                      },
                      child: isAnimating
                          ? AnimatedTextKit(
                              animatedTexts: [
                                TyperAnimatedText(
                                  message,
                                  textStyle: messageText,
                                  speed: const Duration(milliseconds: 40),
                                ),
                              ],
                              isRepeatingAnimation: false,
                              totalRepeatCount: 1,
                              onFinished: () {
                                isAnimated.value = true;
                                onAnimatedTextFinished();
                              },
                            )
                          : Text(
                              message,
                              style: messageText,
                            ),
                    ),

                  if (isUser) Text(message, style: messageText),

                  const SizedBox(height: xs),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        date,
                        style: dateText.copyWith(
                          color: isUser ? white.withOpacity(0.7) : greyLight,
                        ),
                      ),
                      if (isUser) ...[
                        const SizedBox(width: xs),
                        Icon(
                          Icons.done_all,
                          size: 12,
                          color: white.withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (isUser) ...[
            const SizedBox(width: sm),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: userChatGradient,
                borderRadius: BorderRadius.circular(radiusSmall),
              ),
              child: const Icon(Icons.person, color: white, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}
