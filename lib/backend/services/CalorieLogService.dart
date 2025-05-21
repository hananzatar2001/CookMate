// mock_calorie_log_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class MockCalorieLogService {
  Future<QuerySnapshot<Map<String, dynamic>>> getLogsByUser(String userId) async {
    final fakeData = [
      {'Calories taken': 500},
      {'Calories taken': 500},
      {'Calories taken': 500},
    ];

    return _fakeQuerySnapshot(fakeData);
  }

  // Helper method to simulate a QuerySnapshot
  Future<QuerySnapshot<Map<String, dynamic>>> _fakeQuerySnapshot(List<Map<String, dynamic>> data) async {
    final docs = data.map((doc) => _FakeQueryDocumentSnapshot(doc)).toList();
    return _FakeQuerySnapshot(docs);
  }
}

// Fake classes to simulate Firestore snapshots
class _FakeQuerySnapshot implements QuerySnapshot<Map<String, dynamic>> {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> _docs;

  _FakeQuerySnapshot(this._docs);

  @override
  List<QueryDocumentSnapshot<Map<String, dynamic>>> get docs => _docs;

  // Implement other members if needed (can be left unimplemented for demo)
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeQueryDocumentSnapshot implements QueryDocumentSnapshot<Map<String, dynamic>> {
  final Map<String, dynamic> dataMap;

  _FakeQueryDocumentSnapshot(this.dataMap);

  @override
  Map<String, dynamic> data() => dataMap;

  @override
  dynamic operator [](Object key) => dataMap[key];

  // باقي التوابع يمكن تركها بدون تنفيذ
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

