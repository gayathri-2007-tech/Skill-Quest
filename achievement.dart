import 'package:flutter/material.dart';
import '../theme.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final Color color;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.color,
  });
}

class AchievementService {
  static const List<Achievement> all = [
    Achievement(id: 'first_quiz',    title: 'First Blood',    description: 'Complete your first quiz',       emoji: '🎯', color: SQ.blue),
    Achievement(id: 'combo_3',       title: 'On Fire',        description: 'Hit a 3x combo',                 emoji: '🔥', color: SQ.orange),
    Achievement(id: 'combo_5',       title: 'Unstoppable',    description: 'Hit a 5x combo',                 emoji: '⚡', color: SQ.gold),
    Achievement(id: 'perfect_quiz',  title: 'Flawless',       description: 'Zero mistakes in a quiz',        emoji: '💎', color: SQ.blue),
    Achievement(id: 'boss_slain',    title: 'Boss Slayer',    description: 'Defeat a Boss Battle',           emoji: '🏆', color: SQ.gold),
    Achievement(id: 'speed_answer',  title: 'Speed Demon',    description: 'Answer in under 3 seconds',      emoji: '💨', color: SQ.purple),
    Achievement(id: 'code_speak',    title: 'Translator',     description: 'Complete a Code+Speak quiz',     emoji: '🗣️', color: SQ.green),
    Achievement(id: 'all_quests',    title: 'Quest Master',   description: 'Complete all daily quests',      emoji: '🌟', color: SQ.gold),
  ];

  static final Set<String> _unlocked = {'first_login'};

  static bool isUnlocked(String id) => _unlocked.contains(id);

  /// Returns the Achievement if newly unlocked, null if already had it.
  static Achievement? tryUnlock(String id) {
    if (_unlocked.contains(id)) return null;
    _unlocked.add(id);
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<Achievement> get unlocked =>
      all.where((a) => _unlocked.contains(a.id)).toList();
}
