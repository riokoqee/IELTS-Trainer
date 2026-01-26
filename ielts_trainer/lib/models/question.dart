class Question {
  final int id;
  final String text; // Текст вопроса
  final List<String> options; // Варианты ответов ["Yes", "No", "Not Given"]
  final int correctOptionIndex; // Индекс правильного ответа (0, 1 или 2...)

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctOptionIndex,
  });
}

class TestData {
  final String type; // 'Reading', 'Listening' и т.д.
  final String title;
  final String contentText; // Текст для чтения или транскрипт
  final List<Question> questions;

  TestData({
    required this.type,
    required this.title,
    required this.contentText,
    required this.questions,
  });
}
