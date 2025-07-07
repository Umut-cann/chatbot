import 'package:flutter/material.dart';

import 'pages/chat_screen.dart';
import 'services/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive veritabanını başlat
  await DatabaseService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Gemini AI',
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}
