import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sebisan/safeexam.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safe Exam Browser',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SafeExamPage (),
      debugShowCheckedModeBanner: false,
    );
  }
}


