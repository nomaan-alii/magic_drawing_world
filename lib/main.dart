import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magic Drawing World',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: kFont),
      home: const SplashScreen(),
    );
  }
}