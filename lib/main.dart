import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:sebisan/web.dart';

import 'HomePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safe Exam Browser',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Platform.isAndroid ? const HomePage() : const WindowsSafeExamPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
