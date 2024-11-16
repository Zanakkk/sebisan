// ignore_for_file: use_build_context_synchronously, unused_catch_clause, empty_catches, library_private_types_in_public_api, unused_element, file_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sebisan/safeexam.dart';
import 'package:http/http.dart' as http;

// Halaman 2 sebagai tujuan navigasi
class Halaman2 extends StatelessWidget {
  const Halaman2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman 2'),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text(
          'Anda berhasil ikut ujian!',
          style: TextStyle(
              fontSize: 24, color: Colors.green, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const platform = MethodChannel('com.example.sebisan/locktask');
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false; // Menandakan apakah sedang dalam proses submit
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
                } else {}
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

  Future<void> _stopLockTask() async {
    try {
      await platform.invokeMethod('stopLockTask');
    } on PlatformException catch (e) {}
  }

  Future<void> _startExam(String password) async {
    setState(() {
      _isLoading = true;
    });

    // API endpoint
    const String url =
        'https://sibiti-smansa-prodlike.my.id/api/seb-exam/start';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String link = responseData['link'];
        // Navigate to SafeExamPage with the link
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SafeExamPage(link: link),
          ),
        );
      } else {
        // You can show an error message if the API fails
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Safe Exam Browser SIBITI',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Title
                const Text(
                  'Welcome to Safe Exam Browser SIBITIa',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 80),

                // Text Field for input
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Enter your Exam Code',
                    hintStyle:
                        TextStyle(color: Colors.deepPurple.withOpacity(0.6)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide:
                          const BorderSide(color: Colors.deepPurple, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide:
                          const BorderSide(color: Colors.deepPurple, width: 2),
                    ),
                  ),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),

                // Loading indicator (showed when waiting for submit)
                if (_isLoading) const CircularProgressIndicator(),
                if (!_isLoading)
                  // Submit Button with airplane icon
                  ElevatedButton.icon(
                    onPressed: () {
                      _startExam(_controller.text);
                    },
                    icon:
                        const Icon(Icons.airplane_ticket, color: Colors.white),
                    label: const Text('Submit',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _stopLockTask,
        // Menggunakan _stopLockTask untuk menonaktifkan Lock Task Mode
        child: const Icon(Icons.lock_open),
      ),
    );
  }
}
