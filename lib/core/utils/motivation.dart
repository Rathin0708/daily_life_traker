import 'dart:math';

class DailyMotivation {
  static const List<String> _quotes = [
    "Discipline is the bridge between goals and accomplishment.",
    "We are what we repeatedly do. Excellence, then, is not an act, but a habit.",
    "The secret of your future is hidden in your daily routine.",
    "Motivation gets you going, but discipline keeps you growing.",
    "Success is nothing more than a few simple disciplines, practiced every day.",
    "Don't stop when you're tired. Stop when you're done.",
    "Your future self will thank you for the work you do today.",
  ];

  static String get randomQuote => _quotes[Random().nextInt(_quotes.length)];
}
