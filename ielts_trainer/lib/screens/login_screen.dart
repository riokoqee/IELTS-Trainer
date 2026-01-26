// lib/screens/login_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/user_provider.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _nickController = TextEditingController();

  Future<void> _submit() async {
    final endpoint = isLogin ? "/login" : "/register";
    final body = {
      "email": _emailController.text,
      "password": _passController.text,
      if (!isLogin) "nickname": _nickController.text,
    };

    try {
      final response = await http.post(
        Uri.parse("$BASE_URL$endpoint"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          if (!mounted) return;
          Provider.of<UserProvider>(context, listen: false).setUser(
            data['user_id'],
            data.containsKey('nickname')
                ? data['nickname']
                : _nickController.text,
            _emailController.text,
            avatarStr: data['avatar'],
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Ошибка входа")));
      }
    } catch (e) {
      // Fallback для теста без сервера
      if (!mounted) return;
      Provider.of<UserProvider>(
        context,
        listen: false,
      ).setUser(1, "TestUser", "test@gmail.com");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "IELTS TRAINER",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurpleAccent,
                  ),
                ),
                const SizedBox(height: 40),
                if (!isLogin)
                  TextField(
                    controller: _nickController,
                    decoration: const InputDecoration(
                      labelText: "Никнейм",
                      border: OutlineInputBorder(),
                    ),
                  ),
                if (!isLogin) const SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Почта",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Пароль",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(isLogin ? "ВОЙТИ" : "РЕГИСТРАЦИЯ"),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(
                    isLogin ? "Нет аккаунта? Создать" : "Есть аккаунт? Войти",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
