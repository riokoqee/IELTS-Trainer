import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final user = Provider.of<UserProvider>(context);
    final isDark = theme.isDark;

    // Цвета для карточек, зависящие от темы
    final cardColor = isDark ? Colors.grey[850] : Colors.white;
    final iconColor = Colors.deepPurpleAccent;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Настройки",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader("Внешний вид"),
          Card(
            color: cardColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              secondary: Icon(
                isDark ? Icons.nightlight_round : Icons.wb_sunny,
                color: isDark ? Colors.yellow : Colors.orange,
              ),
              title: Text(
                isDark ? "Темная тема" : "Светлая тема",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text("Переключить оформление"),

              // --- НАСТРОЙКИ ЦВЕТОВ ПЕРЕКЛЮЧАТЕЛЯ ---

              // Цвет кружочка, когда включено (Темная тема)
              activeThumbColor: Colors.deepPurpleAccent,
              // Цвет дорожки, когда включено
              activeTrackColor: Colors.deepPurple.withOpacity(0.5),

              // Цвет кружочка, когда выключено (Светлая тема) - теперь он фиолетовый!
              inactiveThumbColor: Colors.deepPurple,
              // Цвет дорожки, когда выключено
              inactiveTrackColor: Colors.deepPurple.withOpacity(0.3),

              // ---------------------------------------
              value: theme.isDark,
              onChanged: (v) => theme.toggleTheme(),
            ),
          ),

          const SizedBox(height: 25),

          _buildSectionHeader("Аккаунт"),
          Card(
            color: cardColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.person, color: iconColor),
                  title: Text(user.nickname),
                  subtitle: Text(user.email),
                  trailing: const Icon(
                    Icons.edit,
                    size: 20,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.lock, color: iconColor),
                  title: const Text("Сменить пароль"),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          _buildSectionHeader("Приложение"),
          Card(
            color: cardColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline, color: iconColor),
                  title: const Text("О приложении"),
                  subtitle: const Text("Версия 1.0.0 (Beta)"),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text(
                    "Выйти из аккаунта",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    _showLogoutDialog(context, user);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, UserProvider user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Выход"),
        content: const Text("Вы уверены, что хотите выйти?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Отмена"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // close dialog
              user.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text("Выйти", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
