import 'package:flutter/material.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/home/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Pre-initialize storage service
  await StorageService.getInstance();
  runApp(const EmpathIQApp());
}

class EmpathIQApp extends StatelessWidget {
  const EmpathIQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EmpathIQ - 同理心与社交读心引擎',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
