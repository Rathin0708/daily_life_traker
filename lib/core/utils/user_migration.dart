import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_model.dart';

class UserMigration {
  static Future<void> migrateUsers() async {
    final usersCollection = FirebaseFirestore.instance.collection('users');
    final snapshot = await usersCollection.get();
    
    for (final doc in snapshot.docs) {
      final userData = doc.data();
      
      // Check if user already has hunter fields
      if (userData.containsKey('hunterRank')) {
        continue; // Already migrated
      }
      
      // Create a new user object with default hunter values
      final migratedUser = AppUser(
        uid: userData['uid'] ?? doc.id,
        email: userData['email'] ?? '',
        displayName: userData['displayName'],
        currentStreak: userData['currentStreak'] ?? 0,
        longestStreak: userData['longestStreak'] ?? 0,
        averageFollowScore: (userData['averageFollowScore'] ?? 0).toDouble(),
        level: userData['level'] ?? 1,
        experience: userData['experience'] ?? 0,
        // New hunter fields with defaults
        hunterRank: 1, // E-rank initially
        strength: 0,
        intelligence: 0,
        agility: 0,
        discipline: 0,
        willpower: 0,
        penaltyCount: 0,
        penaltyActivatedAt: null,
        penaltyEscapeTasksRequired: 0,
      );
      
      // Update the user document with new fields
      await usersCollection.doc(doc.id).update(migratedUser.toMap());
      
      print('Migrated user: ${doc.id}');
    }
    
    print('User migration completed!');
  }
}