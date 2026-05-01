// services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class FirebaseService {
  static Future<void> saveScore(
    String name,
    int score, {
    String skill = '',
    int accuracy = 0,
    int mistakes = 0,
  }) async {
    await FirebaseFirestore.instance.collection("scores").add({
      "name": name,
      "score": score,
      "skill": skill,
      "skillLevel": skill.isNotEmpty ? UserData.skillLevel(skill) : '',
      "accuracy": accuracy,
      "mistakes": mistakes,
      "temperament": skill.isNotEmpty ? UserData.temperamentLabel(skill) : '',
      "learningTrend": skill.isNotEmpty ? UserData.learningTrend(skill) : '',
      "time": DateTime.now(),
    });
  }
}
