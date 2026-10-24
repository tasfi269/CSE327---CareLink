import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/ai_assistant/screens/ai_assistant_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CareLinkApp());
}

class CareLinkApp extends StatelessWidget {
  const CareLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareLink - AI Healthcare Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AIAssistantScreen(),
    );
  }
}
