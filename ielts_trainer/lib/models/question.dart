class Question {
  final int id;
  final String text;
  final List<String> options;
  final int correctOptionIndex; // Для тестов (0, 1, 2...)
  final String? correctTextAnswer; // Для ввода слов (например, "brain dead")
  final bool isInput; // Если true, показываем поле ввода, а не галочки

  Question({
    required this.id,
    required this.text,
    this.options = const [],
    this.correctOptionIndex = -1,
    this.correctTextAnswer,
    this.isInput = false,
  });
}

class TestData {
  final String type; // 'Listening', 'Reading', 'Writing'
  final String title;
  final String contentText;
  final String? audioPath;
  final String? imagePath;
  final List<Question> questions;

  TestData({
    required this.type,
    required this.title,
    required this.contentText,
    this.audioPath,
    this.imagePath,
    required this.questions,
  });
}
