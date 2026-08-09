import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'themes/app_theme.dart';

class KasKuApp extends StatelessWidget {
  const KasKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KasKu',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
