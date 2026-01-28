import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart'; // Версия 5.2.0
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
  int _secondsRemaining = 0;
  Timer? _timer;
  late TestData _currentTestData;
  final TextEditingController _writingController = TextEditingController();

  Map<int, int> _selectedAnswers = {};
  Map<int, String> _textAnswers = {};

  List<String> _sectionSequence = [];
  int _currentSectionIndex = 0;

  // --- СЧЕТЧИКИ ---
  int _totalCorrectAnswers = 0;
  int _totalQuestionsCount = 0;

  int _listeningCorrectCount = 0;
  int _readingCorrectCount = 0;

  List<double> _writingScores = [];
  List<double> _speakingScores = [];

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _audioStartedOnce = false;

  late final AudioRecorder _audioRecorder;
  bool _isRecording = false;
  String? _recordedPath;
  bool _isAttemptFinished = false;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _buildSequence();
    _initSection();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });
    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted && widget.isMock && _currentTestData.type == 'Listening') {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  void _buildSequence() {
    if (widget.isMock) {
      _sectionSequence = [
        'Listening Part 1',
        'Listening Part 2',
        'Listening Part 3',
        'Listening Part 4',
        'Reading Part 1',
        'Reading Part 2',
        'Reading Part 3',
        'Writing Task 1',
        'Writing Task 2',
        'Speaking Part 1',
        'Speaking Part 2',
        'Speaking Part 3',
      ];
    } else if (widget.testType == 'Reading') {
      _sectionSequence = ['Reading Part 1', 'Reading Part 2', 'Reading Part 3'];
    } else if (widget.testType == 'Listening') {
      _sectionSequence = [
        'Listening Part 1',
        'Listening Part 2',
        'Listening Part 3',
        'Listening Part 4',
      ];
    } else if (widget.testType == 'Writing') {
      _sectionSequence = ['Writing Task 1', 'Writing Task 2'];
    } else if (widget.testType == 'Speaking') {
      _sectionSequence = [
        'Speaking Part 1',
        'Speaking Part 2',
        'Speaking Part 3',
      ];
    } else {
      _sectionSequence = [widget.testType];
    }
  }

  void _initSection() {
    String typeToLoad = _sectionSequence[_currentSectionIndex];
    String? prevType;
    if (_currentSectionIndex > 0) {
      prevType = _sectionSequence[_currentSectionIndex - 1];
    }

    _currentTestData = getTestByName(typeToLoad);

    _audioPlayer.stop();
    _audioStartedOnce = false;
    if (_currentTestData.audioPath != null) {
      _audioPlayer.setSource(
        AssetSource('audio/${_currentTestData.audioPath}'),
      );
    }

    _isRecording = false;
    _recordedPath = null;
    _isAttemptFinished = false;

    String currentMainType = _getMainType(typeToLoad);
    String prevMainType = prevType != null ? _getMainType(prevType) : "";

    bool shouldResetTimer =
        (_currentSectionIndex == 0) || (currentMainType != prevMainType);

    if (shouldResetTimer) {
      _timer?.cancel();
      if (currentMainType == 'Listening') {
        _secondsRemaining = 30 * 60;
      } else if (currentMainType == 'Reading') {
        _secondsRemaining = 60 * 60;
      } else if (currentMainType == 'Writing') {
        _secondsRemaining = 60 * 60;
      } else if (currentMainType == 'Speaking') {
        _secondsRemaining = 14 * 60;
      } else {
        _secondsRemaining = 60 * 60;
      }
      _startTimer();
    }

    _writingController.clear();
    _selectedAnswers.clear();
    _textAnswers.clear();
  }

  String _getMainType(String fullTitle) {
    if (fullTitle.contains('Listening')) return 'Listening';
    if (fullTitle.contains('Reading')) return 'Reading';
    if (fullTitle.contains('Writing')) return 'Writing';
    if (fullTitle.contains('Speaking')) return 'Speaking';
    return 'Unknown';
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        if (_isRecording) _stopRecording();
        _submitSection();
      }
    });
  }

  Future<void> _startRecording() async {
    if (_isAttemptFinished) return;
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/speaking_${_currentSectionIndex}.m4a';
        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() {
          _isRecording = true;
          _recordedPath = null;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _recordedPath = path;
        _isAttemptFinished = true;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  void _goToPreviousSection() {
    if (_currentSectionIndex > 0) {
      setState(() => _currentSectionIndex--);
      _initSection();
    }
  }

  void _onNextPressed() {
    if (_isRecording) {
      _stopRecording().then((_) => _submitSection());
    } else {
      bool isLastSection = _currentSectionIndex >= _sectionSequence.length - 1;
      if (isLastSection) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Завершение теста"),
            content: const Text("Вы уверены, что хотите завершить тест?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("ОТМЕНА"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _submitSection();
                },
                child: const Text("ЗАВЕРШИТЬ"),
              ),
            ],
          ),
        );
      } else {
        _submitSection();
      }
    }
  }

  Future<void> _submitSection() async {
    final user = Provider.of<UserProvider>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String currentType = _currentTestData.type;

      if (currentType == 'Speaking') {
        if (_recordedPath == null) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Ничего не записано, пропуск..."),
              backgroundColor: Colors.orange,
            ),
          );
          _speakingScores.add(0.0);
          _handleNextStep();
          return;
        }

        var request = http.MultipartRequest(
          'POST',
          Uri.parse("$BASE_URL/submit_speaking"),
        );
        request.fields['user_id'] = (user.userId ?? 1).toString();
        request.fields['test_type'] = _currentTestData.title;
        request.files.add(
          await http.MultipartFile.fromPath('audio', _recordedPath!),
        );

        var streamedRes = await request.send();
        var res = await http.Response.fromStream(streamedRes);
        Navigator.pop(context);

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          _speakingScores.add((data['score'] as num).toDouble());
        } else {
          _speakingScores.add(0.0);
        }
      } else {
        Map<String, dynamic> answersToSend = {};
        if (currentType == 'Writing') {
          answersToSend["writing_text"] = _writingController.text;
        } else {
          answersToSend["mcq_answers"] = _selectedAnswers.map(
            (k, v) => MapEntry(k.toString(), v),
          );
          answersToSend["text_answers"] = _textAnswers.map(
            (k, v) => MapEntry(k.toString(), v),
          );
        }

        final res = await http.post(
          Uri.parse("$BASE_URL/submit_test"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "user_id": user.userId ?? 1,
            "test_type": _currentTestData.title,
            "answers": answersToSend,
          }),
        );
        Navigator.pop(context);

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (currentType == 'Writing') {
            _writingScores.add((data['score'] as num).toDouble());
          } else {
            int correct = data['correct'] as int;
            int total = data['total'] as int;

            _totalCorrectAnswers += correct;
            _totalQuestionsCount += total;

            if (currentType == 'Listening') _listeningCorrectCount += correct;
            if (currentType == 'Reading') _readingCorrectCount += correct;
          }
        } else {
          if (currentType == 'Writing') _writingScores.add(0.0);
        }
      }
      _handleNextStep();
    } catch (e) {
      Navigator.pop(context);
      _handleNextStep();
    }
  }

  void _handleNextStep() {
    if (_currentSectionIndex < _sectionSequence.length - 1) {
      setState(() => _currentSectionIndex++);
      _initSection();
    } else {
      _finishFullTest();
    }
  }

  void _finishFullTest() {
    _timer?.cancel();
    _audioPlayer.stop();
    _audioRecorder.dispose();

    double bandListening = _calculateIELTSBand(
      _listeningCorrectCount,
      isReading: false,
    );
    double bandReading = _calculateIELTSBand(
      _readingCorrectCount,
      isReading: true,
    );

    double bandWriting = _calculateAverage(_writingScores);
    double bandSpeaking = _calculateAverage(_speakingScores);

    double overall;

    if (widget.isMock) {
      double sum = bandListening + bandReading + bandWriting + bandSpeaking;
      overall = sum / 4;
    } else {
      if (widget.testType == 'Listening')
        overall = bandListening;
      else if (widget.testType == 'Reading')
        overall = bandReading;
      else if (widget.testType == 'Writing')
        overall = bandWriting;
      else if (widget.testType == 'Speaking')
        overall = bandSpeaking;
      else
        overall = 0.0;
    }

    overall = (overall * 2).round() / 2;

    Provider.of<UserProvider>(context, listen: false).updateUserScore(overall);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          overallScore: overall,
          listeningScore: bandListening,
          readingScore: bandReading,
          writingScore: bandWriting,
          speakingScore: bandSpeaking,
          isMock: widget.isMock,
          correctCount: _totalCorrectAnswers,
          totalCount: _totalQuestionsCount,
          testType: widget.isMock ? "Full Mock Test" : widget.testType,
        ),
      ),
    );
  }

  double _calculateAverage(List<double> scores) {
    if (scores.isEmpty) return 0.0;
    double sum = scores.reduce((a, b) => a + b);
    return sum / scores.length;
  }

  double _calculateIELTSBand(int correctCount, {required bool isReading}) {
    if (isReading) {
      // ACADEMIC READING
      if (correctCount == 40) return 9.0;
      if (correctCount >= 38) return 8.5;
      if (correctCount >= 36) return 8.0;
      if (correctCount >= 33) return 7.5;
      if (correctCount >= 29) return 7.0;
      if (correctCount >= 25) return 6.5;
      if (correctCount >= 23) return 6.0;
      if (correctCount >= 19) return 5.5;
      if (correctCount >= 16) return 5.0;
      if (correctCount >= 13) return 4.5;
      if (correctCount >= 10) return 4.0;
      if (correctCount >= 7) return 3.5;
      if (correctCount >= 4) return 3.0;
      if (correctCount >= 2) return 2.0;
      if (correctCount == 1) return 1.0;
      return 0.0;
    } else {
      // LISTENING
      if (correctCount == 40) return 9.0;
      if (correctCount == 39) return 8.5;
      if (correctCount == 38) return 8.0;
      if (correctCount >= 36) return 7.5;
      if (correctCount >= 33) return 7.0;
      if (correctCount >= 30) return 6.5;
      if (correctCount >= 25) return 6.0;
      if (correctCount >= 20) return 5.5;
      if (correctCount >= 17) return 5.0;
      if (correctCount >= 15) return 4.5;
      if (correctCount >= 10) return 4.0;
      if (correctCount >= 7) return 3.5;
      if (correctCount >= 4) return 3.0;
      if (correctCount >= 2) return 2.0;
      if (correctCount == 1) return 1.0;
      return 0.0;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _audioRecorder.dispose();
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
    bool isListening = _currentTestData.type == 'Listening';
    bool isWriting = _currentTestData.type == 'Writing';
    bool isSpeaking = _currentTestData.type == 'Speaking';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Testing"),
        automaticallyImplyLeading: false,
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
            if (isListening) _buildAudioPlayer(),

            if (!isListening)
              Expanded(
                flex: (isWriting || isSpeaking) ? 1 : 2,
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
                        Container(
                          padding: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.deepPurpleAccent.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            _currentTestData.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _currentTestData.contentText,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                        if (_currentTestData.imagePath != null) ...[
                          const SizedBox(height: 12),
                          Center(
                            child: Image.asset(
                              'assets/images/${_currentTestData.imagePath}',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 10),
            if (!isListening) const Divider(),

            Expanded(
              flex: 3,
              child: isSpeaking
                  ? _buildSpeakingArea()
                  : (isWriting ? _buildWritingArea() : _buildQuestionsList()),
            ),

            const SizedBox(height: 10),
            SizedBox(
              height: 50,
              child: Row(
                children: [
                  // --- ВОТ ЗДЕСЬ ИЗМЕНЕНИЕ ---
                  // Кнопка НАЗАД показывается, если:
                  // 1. Это не первая секция
                  // 2. Это НЕ Mock тест
                  // 3. Текущая секция НЕ Speaking
                  if (_currentSectionIndex > 0 &&
                      !widget.isMock &&
                      _currentTestData.type != 'Speaking') ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _goToPreviousSection,
                        child: const Text("НАЗАД"),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _onNextPressed,
                      child: Text(
                        (_currentSectionIndex < _sectionSequence.length - 1)
                            ? "СЛЕДУЮЩАЯ ЧАСТЬ"
                            : "ЗАВЕРШИТЬ ТЕСТ",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // (Остальные виджеты: _buildAudioPlayer, _buildWritingArea, _buildSpeakingArea, _buildQuestionsList - без изменений, они включены в код выше)
  Widget _buildAudioPlayer() {
    if (widget.isMock) {
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
            ElevatedButton.icon(
              onPressed: _audioStartedOnce
                  ? null
                  : () async {
                      setState(() {
                        _audioStartedOnce = true;
                      });
                      await _audioPlayer.resume();
                    },
              icon: Icon(_isPlaying ? Icons.volume_up : Icons.play_arrow),
              label: Text(
                _isPlaying
                    ? "Audio Playing"
                    : (_audioStartedOnce ? "Finished" : "Start Audio"),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.deepPurple,
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
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
                onPressed: () async {
                  if (_isPlaying)
                    await _audioPlayer.pause();
                  else
                    await _audioPlayer.resume();
                },
              ),
              Expanded(
                child: Slider(
                  value: _position.inSeconds.toDouble(),
                  max: _duration.inSeconds.toDouble(),
                  activeColor: Colors.white,
                  inactiveColor: Colors.white38,
                  onChanged: (v) async {
                    await _audioPlayer.seek(Duration(seconds: v.toInt()));
                  },
                ),
              ),
              Text(
                "${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')}",
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWritingArea() {
    return TextField(
      controller: _writingController,
      maxLines: null,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
      decoration: const InputDecoration(
        hintText: "Type your essay here...",
        border: OutlineInputBorder(),
        filled: true,
      ),
    );
  }

  Widget _buildSpeakingArea() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mic,
            size: 80,
            color: _isAttemptFinished
                ? Colors.grey.withOpacity(0.5)
                : (_isRecording ? Colors.red : Colors.deepPurple),
          ),
          const SizedBox(height: 20),
          Text(
            _isRecording
                ? "Recording..."
                : (_isAttemptFinished ? "Saved." : "Press Mic"),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _isAttemptFinished
                ? null
                : (_isRecording ? _stopRecording : _startRecording),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isRecording ? Colors.red : Colors.deepPurple,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(24),
            ),
            child: Icon(
              _isRecording ? Icons.stop : Icons.fiber_manual_record,
              size: 40,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsList() {
    if (_currentTestData.questions.isEmpty) return const SizedBox.shrink();
    return ListView.builder(
      itemCount: _currentTestData.questions.length,
      itemBuilder: (context, index) {
        final Question q = _currentTestData.questions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${q.id}. ${q.text}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                if (q.isInput)
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter answer",
                      isDense: true,
                    ),
                    onChanged: (val) {
                      _textAnswers[q.id] = val;
                    },
                  )
                else
                  ...List.generate(q.options.length, (optIndex) {
                    return RadioListTile<int>(
                      title: Text(q.options[optIndex]),
                      value: optIndex,
                      groupValue: _selectedAnswers[q.id],
                      activeColor: Colors.deepPurpleAccent,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
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
