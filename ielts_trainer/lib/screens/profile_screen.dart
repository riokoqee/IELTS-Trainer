import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List history = [];
  bool isLoading = true;

  // 1. ДОБАВЛЯЕМ СПИСОК ЦВЕТОВ (ТОЧНО ТАКОЙ ЖЕ, КАК В РЕДАКТИРОВАНИИ)
  final List<Color> _avatarColors = [
    Colors.grey,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ]; // <--- НОВОЕ

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final user = Provider.of<UserProvider>(context, listen: false);
    if (user.userId == null) return;
    try {
      final res = await http.get(Uri.parse("$BASE_URL/history/${user.userId}"));
      if (res.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          history = jsonDecode(res.body);
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  // Подсчет среднего балла
  double get _averageScore {
    if (history.isEmpty) return 0.0;
    double sum = 0;
    for (var item in history) {
      sum += (item[1] as num).toDouble();
    }
    return double.parse((sum / history.length).toStringAsFixed(1));
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 220.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.deepPurple,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.deepPurple.shade700,
                            Colors.deepPurple.shade400,
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),

                          // 2. ЗАМЕНЯЕМ CIRCLE AVATAR НА НОВЫЙ С ЦВЕТАМИ
                          CircleAvatar(
                            radius: 45,
                            // Проверяем ID аватарки и ставим цвет
                            backgroundColor:
                                (user.avatarId >= 0 &&
                                    user.avatarId < _avatarColors.length)
                                ? _avatarColors[user.avatarId]
                                : Colors.grey,
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                          ), // <--- ИЗМЕНЕНО

                          const SizedBox(height: 10),
                          Text(
                            user.nickname,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user.email,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Блок статистики
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        _buildStatCard(
                          "Тестов сдано",
                          "${history.length}",
                          Icons.assignment_turned_in,
                          Colors.blueAccent,
                        ),
                        const SizedBox(width: 16),
                        _buildStatCard(
                          "Средний балл",
                          "$_averageScore",
                          Icons.star,
                          Colors.orangeAccent,
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      "История активности",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                ),

                // Список истории
                history.isEmpty
                    ? const SliverFillRemaining(
                        child: Center(
                          child: Text(
                            "Вы еще не проходили тесты",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final item = history[index];
                          final String testType = item[0];
                          final double score = (item[1] as num).toDouble();
                          final String date = item[2].toString().substring(
                            0,
                            10,
                          );

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getIconForType(testType),
                                  color: Colors.deepPurpleAccent,
                                ),
                              ),
                              title: Text(
                                testType,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(date),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getColorForScore(score),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  score.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }, childCount: history.length),
                      ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
              ],
            ),
    );
  }

  // Карточка статистики
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    if (type.contains("Reading")) return Icons.book;
    if (type.contains("Listening")) return Icons.headphones;
    if (type.contains("Writing")) return Icons.edit;
    if (type.contains("MOCK")) return Icons.timer;
    return Icons.article;
  }

  Color _getColorForScore(double score) {
    if (score >= 7.0) return Colors.green;
    if (score >= 5.0) return Colors.orange;
    return Colors.redAccent;
  }
}
