class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final int currentStreak;
  final int longestStreak;
  final double averageFollowScore;
  final int level;
  final int experience;

  AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.averageFollowScore = 0.0,
    this.level = 1,
    this.experience = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'averageFollowScore': averageFollowScore,
      'level': level,
      'experience': experience,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      averageFollowScore: (map['averageFollowScore'] ?? 0).toDouble(),
      level: map['level'] ?? 1,
      experience: map['experience'] ?? 0,
    );
  }
}
