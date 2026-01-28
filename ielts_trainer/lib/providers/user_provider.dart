import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  // Основной объект пользователя (нужен для Home Screen и баллов)
  User? _user;

  // Твои старые поля
  String _email = "";
  String _avatarStr = "😀";

  // --- ГЕТТЕРЫ ---
  // Этот геттер нужен, чтобы Home Screen мог написать: userProvider.user.lastScore
  User? get user => _user;

  // Геттеры для удобства (совместимость со старым кодом)
  int? get userId => _user?.id;
  String get nickname => _user?.nickname ?? "Guest";
  String get email => _email;
  String get avatarStr => _avatarStr;
  double? get lastScore => _user?.lastScore;

  // --- МЕТОДЫ ---

  // 1. Основной метод входа (принимает модель User из API)
  void setUserFromModel(User newUser) {
    _user = newUser;
    // Если у тебя username это email, можно сохранить его и отдельно
    _email = newUser.username ?? "";
    notifyListeners();
  }

  // 2. ТВОЙ СТАРЫЙ МЕТОД (адаптированный)
  // Используется, если ты вручную задаешь данные (например, при регистрации)
  void setUser(int id, String name, String mail, {String? avatarStr}) {
    // Создаем объект User, чтобы все экраны работали
    _user = User(
      id: id,
      nickname: name,
      username: mail,
      lastScore: _user?.lastScore, // Сохраняем балл, если он уже был
    );

    _email = mail;
    if (avatarStr != null) {
      _avatarStr = avatarStr;
    }
    notifyListeners();
  }

  // 3. ТВОЙ МЕТОД ОБНОВЛЕНИЯ ПРОФИЛЯ
  // Обновляет и локальную переменную аватарки, и объект User
  void updateLocalUser(String newName, String newAvatarStr) {
    _avatarStr = newAvatarStr;

    // Обновляем ник внутри объекта User
    if (_user != null) {
      _user = User(
        id: _user!.id,
        username: _user!.username,
        nickname: newName,
        lastScore: _user!.lastScore,
      );
    }
    notifyListeners();
  }

  // 4. НОВЫЙ МЕТОД ДЛЯ ОБНОВЛЕНИЯ БАЛЛОВ (ПОСЛЕ ТЕСТА)
  void updateUserScore(double newScore) {
    if (_user != null) {
      _user = User(
        id: _user!.id,
        username: _user!.username,
        nickname: _user!.nickname,
        lastScore: newScore,
      );
      notifyListeners();
    }
  }

  // 5. ВЫХОД
  void logout() {
    _user = null;
    _email = "";
    _avatarStr = "😀";
    notifyListeners();
  }
}
