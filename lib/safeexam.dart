// ignore_for_file: empty_catches, library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sebisan/HomePage.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class SafeExamPage extends StatefulWidget {
  const SafeExamPage({required this.link, super.key});

  final String link;

  @override
  _SafeExamPageState createState() => _SafeExamPageState();
}

class _SafeExamPageState extends State<SafeExamPage> {
  static const platform = MethodChannel('com.example.sebisan/locktask');
  late final WebViewController controller;
  bool _isLocked = true; // To track if the exam is in lock mode

  final bool _isLoading = false; // Menandakan apakah sedang dalam proses submit
  @override
  void initState() {
    super.initState();
    _startLockTask();

    // Initialize WebViewController
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // You can use this to update a loading bar if needed
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            // Inject JavaScript to disable text selection and copying
            controller.runJavaScript("""
              document.body.style.userSelect = 'none';
              document.body.style.webkitUserSelect = 'none';
              document.body.style.msUserSelect = 'none';
              document.body.style.pointerEvents = 'auto';
              window.getSelection().removeAllRanges();
            """);
          },
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            // Block navigation to certain URLs if needed (example: YouTube)
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.link));
  }

  Future<void> _startLockTask() async {
    try {
      await platform.invokeMethod('startLockTask');
    } on PlatformException {}
  }

  // Stop lock task to allow the user to exit
  Future<void> _stopLockTask() async {
    try {
      await platform.invokeMethod('stopLockTask');
      setState(() {
        _isLocked = false; // Unlock the exam
      });
    } on PlatformException {}
  }

  // Show a dialog to enter the password for exit

  Future<void> _showExitPasswordDialog(String exitcode) async {
    // API endpoint
    const String url = 'https://sibiti-smansa-prodlike.my.id/api/seb-exam/exit';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'exitCode': exitcode,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Check if the response contains 'data' and 'isExit'
        if (responseData.containsKey('data') &&
            responseData['data']['isExit'] == true) {
          // Stop lock task and navigate to HomePage
          _stopLockTask(); // Ensure this function is properly defined

          setState(() {
            _isLocked = false; // Update lock status
          });

          // Ensure the widget is still mounted before navigating
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(), // Navigate to HomePage
              ),
            );
          }
        } else {
          // Optionally, show an error message to the user
        }
      } else {
        // You can show an error message if the API fails
      }
    } catch (e) {
    } finally {
      // Clean up or additional logic can be placed here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Safe Exam',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        actions: [
          // Button to trigger the password dialog
          IconButton(
            icon: const Icon(
              Icons.exit_to_app,
              color: Colors.black,
            ),
            onPressed: () {
              if (_isLocked) {
                final TextEditingController passwordController =
                    TextEditingController();

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Enter EXITCODE'),
                      content: TextField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          hintText: 'EXITCODE',
                        ),
                      ),
                      actions: [
                        if (_isLoading) const CircularProgressIndicator(),
                        if (!_isLoading)
                          TextButton(
                            onPressed: () {
                              String enteredPassword = passwordController.text;
                              _showExitPasswordDialog(enteredPassword);
                              Navigator.of(context)
                                  .pop(); // Tutup dialog setelah memeriksa password
                            },
                            child: const Text('Submit'),
                          ),
                      ],
                    );
                  },
                );
              } else {
                Navigator.pop(context); // Exit the exam if unlocked
              }
            },
          ),
        ],
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
