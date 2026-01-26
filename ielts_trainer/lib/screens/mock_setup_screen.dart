// lib/screens/mock_setup_screen.dart
import 'package:flutter/material.dart';
import 'active_test_screen.dart';

class MockSetupScreen extends StatelessWidget {
  const MockSetupScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const ActiveTestScreen(testType: "MOCK FULL", isMock: true),
          ),
        ),
        child: const Text(
          "НАЧАТЬ ПОЛНЫЙ MOCK TEST\n(Таймер включен)",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
