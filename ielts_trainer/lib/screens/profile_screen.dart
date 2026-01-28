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
  List<dynamic> history = [];
  bool isLoading = true;

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
      print("History Error: $e");
      setState(() => isLoading = false);
    }
  }

  // Подсчет среднего балла
  double get _averageScore {
    if (history.isEmpty) return 0.0;
    double sum = 0;
    int validTests = 0;

    for (var item in history) {
      // ИСПОЛЬЗУЕМ КЛЮЧ 'score' ВМЕСТО ИНДЕКСА [1]
      final scoreVal = item['score'];
      if (scoreVal != null) {
        sum += (scoreVal as num).toDouble();
        validTests++;
      }
    }

    if (validTests == 0) return 0.0;
    return double.parse((sum / validTests).toStringAsFixed(1));
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
                // --- ШАПКА ПРОФИЛЯ ---
                SliverAppBar(
                  expandedHeight: 240.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.deepPurple,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepPurple.shade800,
                            Colors.deepPurple.shade400,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Text(
                              user.avatarStr,
                              style: const TextStyle(fontSize: 55),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            user.nickname,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
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

                // --- СТАТИСТИКА ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        _buildStatCard(
                          "Тестов сдано",
                          "${history.length}",
                          Icons.done_all,
                          Colors.blue,
                        ),
                        const SizedBox(width: 16),
                        _buildStatCard(
                          "Средний балл",
                          "$_averageScore",
                          Icons.star,
                          Colors.orange,
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
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),

                // --- СПИСОК ИСТОРИИ ---
                history.isEmpty
                    ? const SliverFillRemaining(
                        child: Center(
                          child: Text(
                            "История пуста",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final item = history[index];

                          // ИСПОЛЬЗУЕМ КЛЮЧИ СЛОВАРЯ (DICT)
                          final String testType = item['test_type'] ?? "Тест";
                          final double score =
                              (item['score'] as num?)?.toDouble() ?? 0.0;

                          // Обработка даты
                          String dateStr = "Недавно";
                          if (item['date'] != null) {
                            // Обычно дата приходит как строка ISO или DateTime
                            dateStr = item['date'].toString().split('T')[0];
                          }

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
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  _getIconForType(testType),
                                  color: Colors.deepPurple,
                                ),
                              ),
                              title: Text(
                                testType,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(dateStr),
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
              color: Colors.black12,
              blurRadius: 8,
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
    if (type.contains("Reading")) return Icons.menu_book;
    if (type.contains("Listening")) return Icons.headphones;
    if (type.contains("Writing")) return Icons.edit;
    if (type.contains("Speaking")) return Icons.mic;
    return Icons.assignment;
  }

  Color _getColorForScore(double score) {
    if (score >= 7.5) return Colors.green;
    if (score >= 6.0) return Colors.blue;
    if (score >= 4.5) return Colors.orange;
    return Colors.red;
  }
}
