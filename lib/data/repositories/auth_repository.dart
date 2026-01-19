import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> _ensureInitialized() async {
    await _googleSignIn.initialize();
  }

  Future<AppUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return AppUser.fromMap(doc.data()!);
    }
    return null;
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUpWithEmail(String email, String password, String name) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    
    // Create user document
    final appUser = AppUser(
      uid: cred.user!.uid,
      email: email,
      displayName: name,
    );
    
    await _firestore.collection('users').doc(cred.user!.uid).set(appUser.toMap());
    
    return cred;
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _ensureInitialized();

      // Trigger the Google Authentication flow
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // Obtain the auth details (e.g. idToken)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: null, 
        idToken: googleAuth.idToken,
      );

      final cred = await _auth.signInWithCredential(credential);

      // Check if user exists in firestore
      final doc = await _firestore.collection('users').doc(cred.user!.uid).get();
      if (!doc.exists) {
        final appUser = AppUser(
          uid: cred.user!.uid,
          email: cred.user!.email ?? '',
          displayName: cred.user!.displayName,
        );
        await _firestore.collection('users').doc(cred.user!.uid).set(appUser.toMap());
      }

      return cred;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> updateUserStats({
    required int level, 
    required int experience, 
    int? currentXP, 
    int? nextLevelXP,
    int? hunterRank, 
    int? strength, 
    int? intelligence, 
    int? agility, 
    int? discipline, 
    int? willpower
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    Map<String, dynamic> updateData = {
      'level': level,
      'experience': experience,
    };
    
    // Add XP fields if provided
    if (currentXP != null) updateData['currentXP'] = currentXP;
    if (nextLevelXP != null) updateData['nextLevelXP'] = nextLevelXP;
    
    // Add optional Hunter stats if provided
    if (hunterRank != null) updateData['hunterRank'] = hunterRank;
    if (strength != null) updateData['strength'] = strength;
    if (intelligence != null) updateData['intelligence'] = intelligence;
    if (agility != null) updateData['agility'] = agility;
    if (discipline != null) updateData['discipline'] = discipline;
    if (willpower != null) updateData['willpower'] = willpower;
    
    await _firestore.collection('users').doc(user.uid).update(updateData);
  }

  Future<void> updateUserStreak({
    required int currentStreak, 
    required int longestStreak, 
    int? hunterRank, 
    DateTime? penaltyActivatedAt, 
    int? penaltyEscapeTasksRequired, 
    int? penaltyCount,
    int? currentXP,
    int? nextLevelXP
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    Map<String, dynamic> updateData = {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
    };
    
    // Add XP fields if provided
    if (currentXP != null) updateData['currentXP'] = currentXP;
    if (nextLevelXP != null) updateData['nextLevelXP'] = nextLevelXP;
    
    // Add optional Hunter fields if provided
    if (hunterRank != null) updateData['hunterRank'] = hunterRank;
    if (penaltyActivatedAt != null) updateData['penaltyActivatedAt'] = penaltyActivatedAt.toIso8601String();
    if (penaltyEscapeTasksRequired != null) updateData['penaltyEscapeTasksRequired'] = penaltyEscapeTasksRequired;
    if (penaltyCount != null) updateData['penaltyCount'] = penaltyCount;
    
    await _firestore.collection('users').doc(user.uid).update(updateData);
  }
}