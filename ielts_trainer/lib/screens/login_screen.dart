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
    // 1. Очищаем пробелы по краям (на случай если автокоррекция добавила пробел)
    final email = _emailController.text.trim();
    final password = _passController.text.trim();
    final nickname = _nickController.text.trim();

    // 2. Проверка на пустоту
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Заполните все поля!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // --- НОВАЯ ПРОВЕРКА ПОЧТЫ ---
    // Переводим в нижний регистр, чтобы GMAIL.COM тоже прошел проверку
    final emailLower = email.toLowerCase();

    if (!emailLower.endsWith('@gmail.com') &&
        !emailLower.endsWith('@mail.ru')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Принимаем только @gmail.com или @mail.ru"),
          backgroundColor: Colors.red,
        ),
      );
      return; // Останавливаем выполнение, на сервер не идем
    }
    // ----------------------------

    final endpoint = isLogin ? "/login" : "/register";
    final body = {
      "email": email, // Отправляем чистый email без пробелов
      "password": password,
      if (!isLogin) "nickname": nickname,
    };

    try {
      final response = await http.post(
        Uri.parse("$BASE_URL$endpoint"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!mounted) return;

        Provider.of<UserProvider>(context, listen: false).setUser(
          data['user_id'],
          data.containsKey('nickname') ? data['nickname'] : nickname,
          email,
          avatarStr: data['avatar'],
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else {
        String errorText = "Ошибка авторизации";
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['detail'] != null) {
            errorText = errorData['detail'];
          }
        } catch (_) {}

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorText), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ошибка соединения: $e"),
          backgroundColor: Colors.red,
        ),
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
