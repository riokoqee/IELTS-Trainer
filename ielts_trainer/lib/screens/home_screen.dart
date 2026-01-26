// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'active_test_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Привет, ${user.nickname}!",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.deepPurpleAccent),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Последний результат:", style: TextStyle(fontSize: 16)),
                  Text(
                    "7.5",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text("Практика по секциям:", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  _btn(context, "Listening", Icons.headphones),
                  _btn(context, "Reading", Icons.book),
                  _btn(context, "Writing", Icons.edit),
                  _btn(context, "Speaking", Icons.mic),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _btn(BuildContext context, String title, IconData icon) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _SectionTestsScreen(sectionName: title),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.deepPurpleAccent),
            const SizedBox(height: 10),
            Text(title),
          ],
        ),
      ),
    );
  }
}

// Внутренний виджет выбора теста в секции
class _SectionTestsScreen extends StatelessWidget {
  final String sectionName;
  const _SectionTestsScreen({required this.sectionName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(sectionName)),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (ctx, i) => ListTile(
          title: Text("Test ${i + 1}"),
          subtitle: const Text("Сложность: Средняя"),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ActiveTestScreen(testType: sectionName, isMock: false),
              ),
            );
          },
        ),
      ),
    );
  }
}
