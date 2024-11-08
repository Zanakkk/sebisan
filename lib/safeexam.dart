import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:webview_flutter/webview_flutter.dart';

class SafeExamPage extends StatefulWidget {
  @override
  _SafeExamPageState createState() => _SafeExamPageState();
}

class _SafeExamPageState extends State<SafeExamPage> {
  static const platform = MethodChannel('com.example.sebisan/locktask');
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    _startLockTask();
    // Inisialisasi WebViewController
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Dapat digunakan untuk update loading bar jika diperlukan
            print("Loading progress: $progress%");
          },
          onPageStarted: (String url) {
            print("Page started loading: $url");
          },
          onPageFinished: (String url) {
            print("Page finished loading: $url");
          },
          onHttpError: (HttpResponseError error) {
            print("HTTP error: ${error.response}");
          },
          onWebResourceError: (WebResourceError error) {
            print("Resource error: ${error.description}");
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              print("Navigation blocked to ${request.url}");
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://sibiti-smansa.my.id/'));
  }

  Future<void> _startLockTask() async {
    try {
      await platform.invokeMethod('startLockTask');
    } on PlatformException catch (e) {
      print("Failed to start lock task mode: ${e.message}");
    }
  }

  Future<void> _stopLockTask() async {
    try {
      await platform.invokeMethod('stopLockTask');
    } on PlatformException catch (e) {
      print("Failed to stop lock task mode: ${e.message}");
    }
  }

  void _showPasswordDialog(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Password'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Password',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                String enteredPassword = passwordController.text;
                // Ganti "your_password" dengan password yang benar
                if (enteredPassword == "1234") {
                  _stopLockTask;
                } else {
                  print('salah');
                }
                Navigator.of(context)
                    .pop(); // Tutup dialog setelah memeriksa password
              },
              child: const Text('Submit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Exam Browser'),
        actions: [
          IconButton(
              onPressed: () {
                _showPasswordDialog(context);
              },
              icon: Icon(Icons.settings))
        ],
      ),
      body: WebViewWidget(controller: controller),
      floatingActionButton: FloatingActionButton(
        onPressed:
            _stopLockTask, // Menggunakan _stopLockTask untuk menonaktifkan Lock Task Mode
        child: const Icon(Icons.lock_open),
      ),
    );
  }
}
