import '../models/question.dart';

// Фейковые данные для теста
final List<TestData> allTests = [
  // --- 1. LISTENING ---
  TestData(
    type: 'Listening',
    title: 'Section 1: Hotel Reservation',
    contentText: '''
(Audio Transcript)
Receptionist: Good morning, City Hotel. How can I help you?
Guest: Hello, I would like to book a room for next week.
Receptionist: Sure. What is the exact date of your arrival?
Guest: The 15th of March.
Receptionist: And for how many nights?
Guest: Just for 3 nights.
    ''',
    questions: [
      Question(
        id: 101,
        text: "When will the guest arrive?",
        options: ["12th March", "15th March", "20th March"],
        correctOptionIndex: 1,
      ),
      Question(
        id: 102,
        text: "How many nights will he stay?",
        options: ["2 nights", "3 nights", "5 nights"],
        correctOptionIndex: 1,
      ),
    ],
  ),

  // --- 2. READING ---
  TestData(
    type: 'Reading',
    title: 'The History of Gold in Dubai',
    contentText: '''
Dubai is often known as the City of Gold. The history of the gold trade in Dubai is deeply rooted in its heritage. In the 1940s, Dubai was a small trading port...
(Imagine a long text about trade routes, India, and Iran here).
Today, the Gold Souk involves over 300 retailers trading exclusively in jewelry.
    ''',
    questions: [
      Question(
        id: 201,
        text: "What is Dubai often called?",
        options: ["City of Sand", "City of Gold", "City of Future"],
        correctOptionIndex: 1,
      ),
      Question(
        id: 202,
        text: "How many retailers are in the Gold Souk?",
        options: ["Over 200", "Exactly 300", "Over 300"],
        correctOptionIndex: 2,
      ),
    ],
  ),

  // --- 3. WRITING ---
  TestData(
    type: 'Writing',
    title: 'Task 2: Technology in Education',
    contentText:
        'Some people believe that technology has made education easier, while others think it has made it more complicated. Discuss both views and give your opinion.',
    questions: [], // В Writing нет вопросов с вариантами
  ),
];

TestData getTestByName(String type) {
  // Ищем точное совпадение по типу
  return allTests.firstWhere(
    (element) => element.type == type,
    orElse: () => allTests[0],
  );
}
