class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final int currentStreak;
  final int longestStreak;
  final double averageFollowScore;
  final int level;
  final int experience;
  
  // New Hunter System Fields
  final int hunterRank; // 1=E, 2=D, 3=C, 4=B, 5=A, 6=S, 7=Monarch
  final int strength;
  final int intelligence;
  final int agility;
  final int discipline;
  final int willpower;
  final int penaltyCount; // Number of penalty zone activations
  final DateTime? penaltyActivatedAt; // When penalty zone was activated
  final int penaltyEscapeTasksRequired; // How many extra tasks needed to exit penalty

  AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.averageFollowScore = 0.0,
    this.level = 1,
    this.experience = 0,
    // New Hunter fields
    this.hunterRank = 1, // E-rank initially
    this.strength = 0,
    this.intelligence = 0,
    this.agility = 0,
    this.discipline = 0,
    this.willpower = 0,
    this.penaltyCount = 0,
    this.penaltyActivatedAt,
    this.penaltyEscapeTasksRequired = 0,
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
      // New Hunter fields
      'hunterRank': hunterRank,
      'strength': strength,
      'intelligence': intelligence,
      'agility': agility,
      'discipline': discipline,
      'willpower': willpower,
      'penaltyCount': penaltyCount,
      'penaltyActivatedAt': penaltyActivatedAt?.toIso8601String(),
      'penaltyEscapeTasksRequired': penaltyEscapeTasksRequired,
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
      // New Hunter fields
      hunterRank: map['hunterRank'] ?? 1,
      strength: map['strength'] ?? 0,
      intelligence: map['intelligence'] ?? 0,
      agility: map['agility'] ?? 0,
      discipline: map['discipline'] ?? 0,
      willpower: map['willpower'] ?? 0,
      penaltyCount: map['penaltyCount'] ?? 0,
      penaltyActivatedAt: map['penaltyActivatedAt'] != null 
          ? DateTime.parse(map['penaltyActivatedAt']) 
          : null,
      penaltyEscapeTasksRequired: map['penaltyEscapeTasksRequired'] ?? 0,
    );
  }
}
