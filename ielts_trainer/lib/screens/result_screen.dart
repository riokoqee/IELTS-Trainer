import 'package:flutter/material.dart';
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {
  final double overallScore; // В одиночном тесте это просто балл за тест
  final double listeningScore;
  final double readingScore;
  final double writingScore;
  final double speakingScore;
  final bool isMock;
  final int correctCount;
  final int totalCount;
  final String
  testType; // Добавил, чтобы знать, какой именно одиночный тест (Reading/Listening)

  const ResultScreen({
    super.key,
    required this.overallScore,
    required this.listeningScore,
    required this.readingScore,
    required this.writingScore,
    required this.speakingScore,
    required this.isMock,
    required this.correctCount,
    required this.totalCount,
    required this.testType,
  });

  @override
  Widget build(BuildContext context) {
    // Получаем цвета текущей темы (темная или светлая)
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // Фон берется из темы (в темной теме будет темным, в светлой - светлым)
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
              const SizedBox(height: 20),

              Text(
                isMock ? "Full Mock Test Complete!" : "$testType Completed",
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),

              const SizedBox(height: 10),
              Text(
                "Here is your result",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),

              const SizedBox(height: 40),

              // --- КАРТОЧКА С ГЛАВНЫМ БАЛЛОМ ---
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  shape: BoxShape
                      .circle, // Круг для одиночного, или можно оставить квадрат
                  color: Colors.deepPurple,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      overallScore.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Band Score",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- ЛОГИКА ОТОБРАЖЕНИЯ: MOCK vs SINGLE ---
              if (isMock) ...[
                // === ЕСЛИ MOCK TEST: ПОКАЗЫВАЕМ ТАБЛИЦУ ПО СКИЛЛАМ ===
                _buildSkillRow(
                  context,
                  "Listening",
                  listeningScore,
                  Colors.blue,
                ),
                _buildSkillRow(context, "Reading", readingScore, Colors.green),
                _buildSkillRow(context, "Writing", writingScore, Colors.orange),
                _buildSkillRow(
                  context,
                  "Speaking",
                  speakingScore,
                  Colors.redAccent,
                ),
              ] else ...[
                // === ЕСЛИ ОДИНОЧНЫЙ ТЕСТ: ПОКАЗЫВАЕМ ПРАВИЛЬНЫЕ ОТВЕТЫ ===
                // (Только для Reading и Listening, так как в Speaking/Writing нет правильных ответов "из N")
                if (testType.contains("Reading") ||
                    testType.contains("Listening"))
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.cardColor, // Цвет карточки из темы
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          context,
                          "Correct",
                          "$correctCount",
                          Colors.green,
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        _buildStatItem(
                          context,
                          "Total",
                          "$totalCount",
                          Colors.blue,
                        ),
                      ],
                    ),
                  ),

                // Если это Writing или Speaking, можно вывести доп. сообщение
                if (testType.contains("Writing") ||
                    testType.contains("Speaking"))
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Great job! Keep practicing to improve your score.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
              ],

              const SizedBox(height: 40),

              // --- КНОПКА ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "GO TO HOME",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Виджет для строки навыка (Mock Test)
  Widget _buildSkillRow(
    BuildContext context,
    String skill,
    double score,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String displayScore = score > 0 ? score.toStringAsFixed(1) : "-";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.bar_chart, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            skill,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              displayScore,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Виджет для статистики (Single Test)
  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
