import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../providers/user_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  final TextEditingController _passController = TextEditingController();
  String _selectedAvatarStr = "😀"; // Текущий выбранный эмодзи
  bool _isLoading = false;

  // НАШ НОВЫЙ СПИСОК ЭМОДЗИ (Можешь добавить свои!)
  final List<String> _emojis = [
    "😀", "😎", "🧐", "🥳", "🥶", "🤡",
    "👾", "🤖", "👽", "👻", "☠️", "💩",
    "🐶", "🐱", "🦊", "🦁", "🐯", "🦄",
    "😼", "🐳", // <--- ДОБАВИЛИ НОВЫЕ СЮДА
    "🍎", "🍔", "🍕", "🍩", "⚽", "🎮",
  ];

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false);
    _nameController = TextEditingController(text: user.nickname);
    _selectedAvatarStr = user.avatarStr;
    // Если вдруг текущего эмодзи нет в нашем списке, добавляем его, чтобы не потерялся
    if (!_emojis.contains(_selectedAvatarStr)) {
      _emojis.insert(0, _selectedAvatarStr);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    final user = Provider.of<UserProvider>(context, listen: false);

    try {
      final body = {
        "user_id": user.userId,
        "nickname": _nameController.text,
        "avatar_str": _selectedAvatarStr, // Отправляем строку
        "password": _passController.text,
      };

      final res = await http.post(
        Uri.parse("$BASE_URL/update_profile"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        // Обновляем данные внутри приложения сразу
        user.updateLocalUser(_nameController.text, _selectedAvatarStr);
        if (!mounted) return;
        Navigator.pop(context); // Возвращаемся назад
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Профиль обновлен!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception("Ошибка сервера: ${res.statusCode}");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text("Редактирование профиля")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Выберите аватар",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),

            // СЕТКА ЭМОДЗИ
            Center(
              child: Wrap(
                spacing: 15,
                runSpacing: 15,
                alignment: WrapAlignment.center,
                children: _emojis.map((emoji) {
                  final isSelected = _selectedAvatarStr == emoji;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAvatarStr = emoji),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Colors.deepPurpleAccent
                              : Colors.transparent,
                          width: 3,
                        ),
                        color: isSelected
                            ? Colors.deepPurpleAccent.withOpacity(0.1)
                            : Colors.transparent,
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: isDark
                            ? Colors.grey[800]
                            : Colors.grey[200],
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 40),

            const Text(
              "Никнейм",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Новый пароль (необязательно)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Оставьте пустым, если не меняете",
                prefixIcon: Icon(Icons.lock),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "СОХРАНИТЬ ИЗМЕНЕНИЯ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
