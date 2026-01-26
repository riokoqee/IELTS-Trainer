import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/user_provider.dart';
import '../data/mock_data.dart';
import '../models/question.dart';
import 'result_screen.dart';

class ActiveTestScreen extends StatefulWidget {
  final String testType;
  final bool isMock;

  const ActiveTestScreen({
    super.key,
    required this.testType,
    required this.isMock,
  });

  @override
  State<ActiveTestScreen> createState() => _ActiveTestScreenState();
}

class _ActiveTestScreenState extends State<ActiveTestScreen> {
  // Таймер
  int _secondsRemaining = 0;
  Timer? _timer;

  // Данные теста
  late TestData _currentTestData;
  final TextEditingController _writingController = TextEditingController();

  // Ответы текущей секции
  Map<int, int> _selectedAnswers = {};

  // Для MOCK режима
  final List<String> _mockOrder = ['Listening', 'Reading', 'Writing'];
  int _currentMockIndex = 0;
  List<double> _mockScores = []; // Копим баллы за секции

  // Для плеера
  bool _isPlaying = false;
  double _sliderValue = 0.0;

  @override
  void initState() {
    super.initState();
    _initSection();
  }

  // Настройка текущей секции (вызывается при старте и при переходе)
  void _initSection() {
    String typeToLoad = widget.isMock
        ? _mockOrder[_currentMockIndex]
        : widget.testType;
    _currentTestData = getTestByName(typeToLoad);

    // Установка времени в зависимости от секции
    if (_currentTestData.type == 'Listening')
      _secondsRemaining = 30 * 60; // 30 мин
    else if (_currentTestData.type == 'Reading')
      _secondsRemaining = 60 * 60; // 60 мин
    else if (_currentTestData.type == 'Writing')
      _secondsRemaining = 60 * 60; // 60 мин
    else
      _secondsRemaining = 60 * 60;

    // Сброс полей
    _writingController.clear();
    _selectedAnswers.clear();
    _isPlaying = false;
    _sliderValue = 0.0;

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel(); // Сброс старого таймера
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
        // Анимация плеера
        if (_isPlaying && _sliderValue < 1.0) {
          setState(() => _sliderValue += 0.001);
        } else if (_sliderValue >= 1.0) {
          setState(() {
            _isPlaying = false;
            _sliderValue = 1.0;
          });
        }
      } else {
        _submitSection(); // Время вышло - сдаем секцию
      }
    });
  }

  // Отправка текущей секции на сервер
  Future<void> _submitSection() async {
    _timer?.cancel();
    final user = Provider.of<UserProvider>(context, listen: false);

    // Сбор ответов
    Map<String, dynamic> answersToSend = {};
    if (_currentTestData.type == 'Writing') {
      answersToSend["writing_text"] = _writingController.text;
    } else {
      answersToSend["mcq_answers"] = _selectedAnswers.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }

    try {
      // Показываем индикатор загрузки
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final res = await http.post(
        Uri.parse("$BASE_URL/submit_test"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": user.userId ?? 1,
          "test_type": _currentTestData.type, // Отправляем как отдельный тест
          "answers": answersToSend,
        }),
      );

      Navigator.pop(context); // Убираем загрузку

      double score = 0.0;
      if (res.statusCode == 200) {
        score = jsonDecode(res.body)['score'];
      }
      _mockScores.add(score); // Сохраняем балл

      // Логика перехода
      if (widget.isMock && _currentMockIndex < 2) {
        // Если это Мок и еще не последняя секция -> Идем дальше
        _showNextSectionDialog();
      } else {
        // Иначе -> Финиш
        double finalScore = widget.isMock
            ? (_mockScores.reduce((a, b) => a + b) /
                  _mockScores.length) // Среднее для Мок
            : score;

        // Округляем до 0.5 (как в IELTS)
        finalScore = (finalScore * 2).round() / 2;

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              score: finalScore,
              testType: widget.isMock ? "MOCK FULL" : widget.testType,
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Убираем загрузку при ошибке
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Ошибка отправки данных")));
    }
  }

  void _showNextSectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text("Секция ${_mockOrder[_currentMockIndex]} завершена!"),
        content: Text("Следующая секция: ${_mockOrder[_currentMockIndex + 1]}"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _currentMockIndex++;
              });
              _initSection(); // Загружаем следующую часть
            },
            child: const Text("НАЧАТЬ СЛЕДУЮЩУЮ"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _writingController.dispose();
    super.dispose();
  }

  String get _timerText {
    final h = _secondsRemaining ~/ 3600;
    final m = (_secondsRemaining % 3600) ~/ 60;
    final s = _secondsRemaining % 60;
    return "${h > 0 ? '$h:' : ''}${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    bool isWriting = _currentTestData.type == 'Writing';
    bool isListening = _currentTestData.type == 'Listening';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isMock ? "MOCK: ${_currentTestData.type}" : widget.testType,
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                _timerText,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. КОНТЕНТ (ПЛЕЕР или ТЕКСТ)
            if (isListening)
              _buildAudioPlayer()
            else
              Expanded(
                flex: isWriting ? 1 : 2,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentTestData.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _currentTestData.contentText,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 10),
            if (!isListening) const Divider(),

            // 2. ВОПРОСЫ или ВВОД
            Expanded(
              flex: 3,
              child: isWriting ? _buildWritingArea() : _buildQuestionsList(),
            ),

            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitSection, // Кнопка вызывает отправку
                child: Text(
                  (widget.isMock && _currentMockIndex < 2)
                      ? "СЛЕДУЮЩАЯ СЕКЦИЯ"
                      : "ЗАВЕРШИТЬ ТЕСТ",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets ---

  Widget _buildAudioPlayer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.headphones, size: 50, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            _currentTestData.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: () => setState(() => _isPlaying = !_isPlaying),
              ),
              Expanded(
                child: Slider(
                  value: _sliderValue,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white38,
                  onChanged: (v) => setState(() => _sliderValue = v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWritingArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Your Answer:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Expanded(
          child: TextField(
            controller: _writingController,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            decoration: const InputDecoration(
              hintText: "Type your essay here...",
              border: OutlineInputBorder(),
              filled: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionsList() {
    return ListView.builder(
      itemCount: _currentTestData.questions.length,
      itemBuilder: (context, index) {
        final Question q = _currentTestData.questions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${index + 1}. ${q.text}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(q.options.length, (optIndex) {
                  return RadioListTile<int>(
                    title: Text(q.options[optIndex]),
                    value: optIndex,
                    groupValue: _selectedAnswers[q.id],
                    activeColor: Colors.deepPurpleAccent,
                    onChanged: (val) {
                      setState(() {
                        _selectedAnswers[q.id] = val!;
                      });
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
