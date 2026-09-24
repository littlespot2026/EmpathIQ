import 'package:flutter/material.dart';
import 'core/localization/app_locale.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/home/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.getInstance();
  await AppLocale.instance.init();
  runApp(const EmpathIQApp());
}

class EmpathIQApp extends StatelessWidget {
  const EmpathIQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppLocale.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'EmpathIQ - ${tr('app_slogan')}',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          locale: Locale(AppLocale.instance.currentCode),
          builder: (context, child) {
            return Directionality(
              textDirection: AppLocale.instance.textDirection,
              child: child!,
            );
          },
          home: const HomeScreen(),
        );
      },
    );
  }
}
