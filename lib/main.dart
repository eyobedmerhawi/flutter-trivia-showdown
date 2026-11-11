import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const TriviaShowdownApp());
}

class TriviaShowdownApp extends StatelessWidget {
  const TriviaShowdownApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trivia Showdown',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TriviaScreen(),
    );
  }
}

String cleanText(String text) {
  return text
      .replaceAll('&quot;', '"')
      .replaceAll('&#039;', "'")
      .replaceAll('&#39;', "'")
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&nbsp;', ' ');
}

class TriviaQuestion {
  final String question;
  final String correctAnswer;
  final List<String> options;

  TriviaQuestion({
    required this.question,
    required this.correctAnswer,
    required this.options,
  });

  factory TriviaQuestion.fromJson(Map<String, dynamic> json) {
    final correct = cleanText(json['correct_answer'] as String);

    final options = [
      correct,
      ...(json['incorrect_answers'] as List<dynamic>).map(
        (answer) => cleanText(answer as String),
      ),
    ]..shuffle(Random());

    return TriviaQuestion(
      question: cleanText(json['question'] as String),
      correctAnswer: correct,
      options: options,
    );
  }
}

class TriviaScreen extends StatefulWidget {
  const TriviaScreen({super.key});

  @override
  State<TriviaScreen> createState() => _TriviaScreenState();
}

class _TriviaScreenState extends State<TriviaScreen> {
  static const String apiUrl =
      'https://opentdb.com/api.php?amount=5&category=9&difficulty=easy&type=multiple';

  List<TriviaQuestion> questions = [];
  int currentIndex = 0;
  int score = 0;
  int roundId = 0;

  String? selectedAnswer;
  String? errorMessage;

  bool isLoading = true;
  bool isFinished = false;
  bool isSyncing = false;
  bool isSynced = false;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    final requestId = ++roundId;

    setState(() {
      isLoading = true;
      errorMessage = null;
      questions = [];
      currentIndex = 0;
      score = 0;
      selectedAnswer = null;
      isFinished = false;
      isSyncing = false;
      isSynced = false;
    });

    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('HTTP error: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['response_code'] != 0) {
        throw Exception('Trivia API error: ${data['response_code']}');
      }

      final results = data['results'] as List<dynamic>;

      if (results.length != 5) {
        throw Exception('Expected five trivia questions.');
      }

      final loadedQuestions = results
          .map((item) => TriviaQuestion.fromJson(item as Map<String, dynamic>))
          .toList();

      if (!mounted || requestId != roundId) return;

      setState(() {
        questions = loadedQuestions;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted || requestId != roundId) return;

      setState(() {
        errorMessage = 'Could not load questions.\n$error';
        isLoading = false;
      });
    }
  }

  void selectAnswer(String answer) {
    if (selectedAnswer != null || isFinished) return;

    setState(() {
      selectedAnswer = answer;

      if (answer == questions[currentIndex].correctAnswer) {
        score++;
      }
    });
  }

  void nextQuestion() {
    if (selectedAnswer == null) return;

    setState(() {
      if (currentIndex < questions.length - 1) {
        currentIndex++;
        selectedAnswer = null;
      } else {
        isFinished = true;
      }
    });
  }

  Color? answerColor(String answer) {
    if (selectedAnswer == null) return null;

    if (answer == questions[currentIndex].correctAnswer) {
      return Colors.green.shade200;
    }

    if (answer == selectedAnswer) {
      return Colors.red.shade200;
    }

    return null;
  }

  Future<void> syncScore() async {
    if (!isFinished || isSyncing || isSynced) return;

    final currentRoundId = roundId;

    setState(() {
      isSyncing = true;
    });

    // Classroom simulation only. No real backend request is sent.
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted || currentRoundId != roundId) return;

    setState(() {
      isSyncing = false;
      isSynced = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Simulated score submission: $score / ${questions.length}. '
          'No backend request was sent.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trivia Showdown'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: isLoading
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading trivia questions...'),
                  ],
                )
              : errorMessage != null
              ? buildErrorScreen()
              : isFinished
              ? buildResultsScreen()
              : buildQuestionScreen(),
        ),
      ),
    );
  }

  Widget buildErrorScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.wifi_off, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        Text(errorMessage!, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: loadQuestions,
          child: const Text('Try Again'),
        ),
      ],
    );
  }

  Widget buildQuestionScreen() {
    final question = questions[currentIndex];

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Question ${currentIndex + 1} of ${questions.length}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: (currentIndex + 1) / questions.length),
          const SizedBox(height: 20),
          Text(
            'Score: $score',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 30),
          Text(
            question.question,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          ...question.options.map(
            (answer) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                onPressed: selectedAnswer == null
                    ? () => selectAnswer(answer)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: answerColor(answer),
                  disabledBackgroundColor: answerColor(answer),
                  foregroundColor: Colors.black87,
                  disabledForegroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 12,
                  ),
                ),
                child: Text(answer, textAlign: TextAlign.center),
              ),
            ),
          ),
          if (selectedAnswer != null) ...[
            const SizedBox(height: 16),
            Text(
              selectedAnswer == question.correctAnswer
                  ? 'Correct!'
                  : 'Incorrect! The correct answer is '
                        '${question.correctAnswer}.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: selectedAnswer == question.correctAnswer
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: nextQuestion,
              child: Text(
                currentIndex == questions.length - 1
                    ? 'See Results'
                    : 'Next Question',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildResultsScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
        const SizedBox(height: 20),
        const Text(
          'Round Complete!',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Text(
          'Final Score: $score / ${questions.length}',
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 30),
        FilledButton.icon(
          onPressed: isSyncing || isSynced ? null : syncScore,
          icon: isSyncing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.cloud_upload),
          label: Text(
            isSyncing
                ? 'Simulating sync...'
                : isSynced
                ? 'Simulation Complete'
                : 'Simulate Score Sync',
          ),
        ),
        if (isSynced) ...[
          const SizedBox(height: 12),
          const Text(
            'Score processed locally. No cloud write occurred.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.green),
          ),
        ],
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: loadQuestions,
          child: const Text('Play Again'),
        ),
      ],
    );
  }
}
