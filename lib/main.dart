import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/main_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TokoKu',
      debugShowCheckedModeBanner: false,
      theme: getAppTheme(),
      home: const MainLayout(),
    );
  }
}
