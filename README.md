# Trivia Showdown 🎮

A Flutter trivia game powered by the Open Trivia Database REST API. Players answer five randomly selected multiple-choice questions, receive immediate feedback, and track their scores.

## Features

- **Live API Integration:** Fetches five general-knowledge questions from Open Trivia Database.
- **Interactive Gameplay:** Shuffles answer choices and displays one question at a time.
- **Instant Feedback:** Highlights correct answers green and incorrect selections red.
- **Score Tracking:** Calculates the player's final score out of five.
- **Error Handling:** Displays connection errors and allows users to retry.
- **Replay:** Starts a new round with freshly fetched questions.
- **Score Sync Simulation:** Demonstrates an asynchronous score-submission workflow without requiring a backend.

## Tech Stack

- Flutter
- Dart
- REST API
- HTTP package
- JSON parsing
- Stateful widgets

## How It Works

1. The application sends an HTTP GET request to Open Trivia Database.
2. The API returns JSON containing five trivia questions.
3. The app validates the response and converts the JSON into Dart question objects.
4. Answer choices are shuffled before being displayed.
5. Players select one answer per question and receive immediate feedback.
6. The final screen displays the score and offers replay or simulated score submission.

## API Endpoint

```text
https://opentdb.com/api.php?amount=5&category=9&difficulty=easy&type=multiple
```

The app checks the HTTP status code and API response code before processing the results.

## Getting Started

### Requirements

- Flutter SDK
- Dart SDK
- Android emulator or physical device
- Internet connection

### Installation

Clone the repository:

```bash
git clone https://github.com/eyobedmerhawi/flutter-trivia-showdown.git
cd flutter-trivia-showdown
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

## Testing

The application was tested for:

| Test | Result |
|---|---|
| Fetching five live questions | Passed |
| Answer selection and score tracking | Passed |
| Completing multiple rounds | Passed |
| Final score display | Passed |
| Replay functionality | Passed |
| Simulated score submission | Passed |
| Offline error handling | Passed |
| Recovery after reconnecting | Passed |

## Screenshots

Screenshots of the gameplay, answer feedback, final score, and score-sync simulation will be added here.

## Future Improvements

- Add difficulty and category selection.
- Implement a real cloud leaderboard.
- Save previous scores and gameplay history.
- Add a countdown timer for each question.
- Improve the user interface with animations.

## Important Note

The score-sync feature is currently a classroom simulation. It demonstrates asynchronous state changes but does not write scores to a real backend.

## Author

Developed by [Eyobed Gebregziabher](https://github.com/eyobedmerhawi).

Originally created as part of CSC 4360 — Mobile App Development at Georgia State University.