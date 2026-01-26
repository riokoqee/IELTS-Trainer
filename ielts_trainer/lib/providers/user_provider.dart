import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  int? userId;
  String nickname = "Guest";
  String email = "";
  int avatarId = 0; // Новое поле: ID выбранной аватарки (0 по умолчанию)

  void setUser(int id, String name, String mail, {String? avatarStr}) {
    userId = id;
    nickname = name;
    email = mail;
    // Пытаемся превратить строку из БД в число, если не выйдет - будет 0
    avatarId = int.tryParse(avatarStr ?? "0") ?? 0;
    notifyListeners();
  }

  // Метод для быстрого обновления без перелогина
  void updateLocalUser(String newName, int newAvatarId) {
    nickname = newName;
    avatarId = newAvatarId;
    notifyListeners();
  }

  void logout() {
    userId = null;
    nickname = "Guest";
    avatarId = 0;
    notifyListeners();
  }
}
