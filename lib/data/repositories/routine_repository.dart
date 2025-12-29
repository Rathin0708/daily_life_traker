import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/routine_models.dart';
import 'package:uuid/uuid.dart';

class RoutineRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // --- Templates ---

  Future<void> saveTemplate(RoutineTemplate template) async {
    await _firestore
        .collection('templates')
        .doc(template.id.isEmpty ? _uuid.v4() : template.id)
        .set(template.toMap());
  }

  Stream<List<RoutineTemplate>> getUserTemplates(String userId) {
    return _firestore
        .collection('templates')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RoutineTemplate.fromMap(doc.data()))
            .toList());
  }

  // --- Daily Logs ---

  Future<void> saveDailyLog(DailyLog log) async {
    await _firestore
        .collection('daily_logs')
        .doc(log.id)
        .set(log.toMap());
  }

  Future<DailyLog?> getDailyLog(String userId, DateTime date) async {
    // Start and end of the day
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = await _firestore
        .collection('daily_logs')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return DailyLog.fromMap(query.docs.first.data());
    }
    return null;
  }

  Stream<List<DailyLog>> getMonthlyLogs(String userId, int year, int month) {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 1);

    return _firestore
        .collection('daily_logs')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThan: Timestamp.fromDate(endOfMonth))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DailyLog.fromMap(doc.data()))
            .toList());
  }

  Future<List<DailyLog>> getAllLogs(String userId) async {
    final query = await _firestore
        .collection('daily_logs')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .get();

    return query.docs.map((doc) => DailyLog.fromMap(doc.data())).toList();
  }
}
