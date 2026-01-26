import 'package:flutter/material.dart';
import 'main_screen.dart';

class ResultScreen extends StatelessWidget {
  final double score;
  final String testType;

  const ResultScreen({super.key, required this.score, required this.testType});

  // Определяем уровень английского по баллу
  String get _getLevel {
    if (score >= 8.5) return "Expert (C2)";
    if (score >= 7.0) return "Proficient (C1)";
    if (score >= 5.5) return "Upper-Intermediate (B2)";
    if (score >= 4.0) return "Intermediate (B1)";
    return "Beginner (A1-A2)";
  }

  // Определяем цвет круга
  Color get _getColor {
    if (score >= 7.0) return Colors.green;
    if (score >= 5.0) return Colors.orange;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Тест завершен!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Секция: $testType",
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // Большой круг с оценкой
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).cardColor,
                  border: Border.all(
                    color: _getColor.withOpacity(0.5),
                    width: 10,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      score.toString(),
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: _getColor,
                      ),
                    ),
                    const Text(
                      "Band Score",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Text(
                _getLevel,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _getColor,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Хорошая работа! Продолжай тренироваться, чтобы улучшить результат.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Возвращаемся на главный экран и удаляем историю навигации
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MainScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "НА ГЛАВНУЮ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
