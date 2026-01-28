import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'active_test_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем провайдер пользователя
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    // Определяем тему (темная или светлая) для настройки цветов
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // --- ПРИВЕТСТВИЕ ---
              Text(
                "С возвращением,",
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                user?.nickname ?? 'Студент',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),

              const SizedBox(height: 30),

              // --- КАРТОЧКА ПОСЛЕДНЕГО РЕЗУЛЬТАТА ---
              // (Заменила собой Mock Test)
              _buildLastResultCard(context, user?.lastScore),

              const SizedBox(height: 30),

              // --- ЗАГОЛОВОК СЕКЦИЙ ---
              Text(
                "Практика по секциям",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              // --- СЕТКА КНОПОК ---
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.1,
                children: [
                  _buildSectionCard(
                    context,
                    title: "Listening",
                    icon: Icons.headphones,
                    color: Colors.blue,
                    onTap: () => _startTest(context, "Listening", false),
                  ),
                  _buildSectionCard(
                    context,
                    title: "Reading",
                    icon: Icons.menu_book,
                    color: Colors.green,
                    onTap: () => _startTest(context, "Reading", false),
                  ),
                  _buildSectionCard(
                    context,
                    title: "Writing",
                    icon: Icons.edit,
                    color: Colors.orange,
                    onTap: () => _startTest(context, "Writing", false),
                  ),
                  _buildSectionCard(
                    context,
                    title: "Speaking",
                    icon: Icons.mic,
                    color: Colors.redAccent,
                    onTap: () => _startTest(context, "Speaking", false),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Виджет карточки результата
  Widget _buildLastResultCard(BuildContext context, double? score) {
    // Если балла нет, показываем прочерк
    final String displayScore = score != null ? score.toStringAsFixed(1) : "-";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // --- ИСПРАВЛЕНИЕ ЗДЕСЬ: Оборачиваем текст в Expanded ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Последний результат",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  // Добавляем защиту от слишком длинного текста
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: 5),
                Text(
                  "Overall Band Score",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),

          const SizedBox(width: 10), // Отступ между текстом и оценкой

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              displayScore,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Виджет кнопки секции
  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    // Обязательно используем Material для корректной работы InkWell
    return Material(
      color: Theme.of(context).cardColor,
      elevation: 2,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: color.withOpacity(0.2),
        highlightColor: color.withOpacity(0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _startTest(BuildContext context, String type, bool isMock) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveTestScreen(testType: type, isMock: isMock),
      ),
    );
  }
}
