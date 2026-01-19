import 'package:flutter/material.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/user_model.dart';
import '../core/utils/hunter_stats_calculator.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  AppUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthViewModel(this._repository) {
    _repository.authStateChanges.listen((user) async {
      if (user != null) {
        _currentUser = await _repository.getCurrentUser();
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await _repository.signInWithEmail(email, password);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    _setLoading(true);
    try {
      await _repository.signUpWithEmail(email, password, name);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      await _repository.signInWithGoogle();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
  }

  Future<void> addExperience(int amount, {Map<String, int>? statIncreases}) async {
    if (_currentUser == null) return;

    int newExp = _currentUser!.experience + amount;
    int newLevel = _currentUser!.level;
    int newHunterRank = _currentUser!.hunterRank;

    // Level up logic: Level * 1000 EXP for next level
    int expNeeded = newLevel * 1000;
    while (newExp >= expNeeded) {
      newExp -= expNeeded;
      newLevel++;
      expNeeded = newLevel * 1000;
    }
    
    // Calculate new hunter rank based on level
    newHunterRank = HunterStatsCalculator.calculateHunterRank(newLevel);
    
    // Update stats if provided
    int newStrength = _currentUser!.strength;
    int newIntelligence = _currentUser!.intelligence;
    int newAgility = _currentUser!.agility;
    int newDiscipline = _currentUser!.discipline;
    int newWillpower = _currentUser!.willpower;
    
    if (statIncreases != null) {
      newStrength += statIncreases['strength'] ?? 0;
      newIntelligence += statIncreases['intelligence'] ?? 0;
      newAgility += statIncreases['agility'] ?? 0;
      newDiscipline += statIncreases['discipline'] ?? 0;
      newWillpower += statIncreases['willpower'] ?? 0;
    }

    await _repository.updateUserStats(
      level: newLevel, 
      experience: newExp,
      hunterRank: newHunterRank,
      strength: newStrength,
      intelligence: newIntelligence,
      agility: newAgility,
      discipline: newDiscipline,
      willpower: newWillpower,
    );
    
    // Update local state and notify
    _currentUser = AppUser(
      uid: _currentUser!.uid,
      email: _currentUser!.email,
      displayName: _currentUser!.displayName,
      currentStreak: _currentUser!.currentStreak,
      longestStreak: _currentUser!.longestStreak,
      averageFollowScore: _currentUser!.averageFollowScore,
      level: newLevel,
      experience: newExp,
      hunterRank: newHunterRank,
      strength: newStrength,
      intelligence: newIntelligence,
      agility: newAgility,
      discipline: newDiscipline,
      willpower: newWillpower,
      penaltyCount: _currentUser!.penaltyCount,
      penaltyActivatedAt: _currentUser!.penaltyActivatedAt,
      penaltyEscapeTasksRequired: _currentUser!.penaltyEscapeTasksRequired,
    );
    notifyListeners();
  }

  Future<void> updateStreak(int currentStreak) async {
    if (_currentUser == null) return;

    int longest = _currentUser!.longestStreak;
    if (currentStreak > longest) {
      longest = currentStreak;
    }

    await _repository.updateUserStreak(currentStreak: currentStreak, longestStreak: longest);

    _currentUser = AppUser(
      uid: _currentUser!.uid,
      email: _currentUser!.email,
      displayName: _currentUser!.displayName,
      currentStreak: currentStreak,
      longestStreak: longest,
      averageFollowScore: _currentUser!.averageFollowScore,
      level: _currentUser!.level,
      experience: _currentUser!.experience,
    );
    notifyListeners();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
