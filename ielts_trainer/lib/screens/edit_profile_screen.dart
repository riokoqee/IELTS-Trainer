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
  int _selectedAvatarId = 0;
  bool _isLoading = false;

  // Список цветов для аватарок (заглушка вместо картинок)
  final List<Color> _avatarColors = [
    Colors.grey,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false);
    _nameController = TextEditingController(text: user.nickname);
    _selectedAvatarId = user.avatarId;
    // Защита: если ID аватарки больше, чем у нас есть цветов
    if (_selectedAvatarId >= _avatarColors.length) _selectedAvatarId = 0;
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    final user = Provider.of<UserProvider>(context, listen: false);

    try {
      final body = {
        "user_id": user.userId,
        "nickname": _nameController.text,
        "avatar_id": _selectedAvatarId,
        "password":
            _passController.text, // Если пустой, сервер его проигнорирует
      };

      final res = await http.post(
        Uri.parse("$BASE_URL/update_profile"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        // Обновляем данные внутри приложения сразу
        user.updateLocalUser(_nameController.text, _selectedAvatarId);
        if (!mounted) return;
        Navigator.pop(context); // Возвращаемся назад
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Профиль обновлен!")));
      } else {
        throw Exception("Ошибка сервера");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Не удалось сохранить изменения")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Редактирование")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Выберите аватар",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),
            // Сетка аватарок
            Center(
              child: Wrap(
                spacing: 15,
                runSpacing: 15,
                children: List.generate(_avatarColors.length, (index) {
                  final isSelected = _selectedAvatarId == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAvatarId = index),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: Colors.deepPurpleAccent,
                                width: 3,
                              )
                            : null,
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: _avatarColors[index],
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 30),

            const Text("Никнейм"),
            const SizedBox(height: 5),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 20),

            const Text("Новый пароль (необязательно)"),
            const SizedBox(height: 5),
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Оставьте пустым, если не меняете",
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("СОХРАНИТЬ"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
