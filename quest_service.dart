class Quest {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int target;
  int progress;
  bool completed;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.target,
    this.progress = 0,
    this.completed = false,
  });

  double get ratio => (progress / target).clamp(0.0, 1.0);
}

class QuestService {
  static final List<Quest> dailyQuests = [
    Quest(id: 'quiz_complete', title: 'Quiz Warrior', description: 'Complete 1 quiz today', emoji: '⚔️', target: 1),
    Quest(id: 'combo_3', title: 'Combo King', description: 'Build a 3x answer combo', emoji: '🔥', target: 3),
    Quest(id: 'correct_5', title: 'Sharp Shooter', description: 'Answer 5 questions correctly', emoji: '🎯', target: 5),
  ];

  static void recordQuizComplete() => _progress('quiz_complete', 1);
  static void recordCorrect() => _progress('correct_5', 1);
  static void recordCombo(int combo) {
    final q = dailyQuests.firstWhere((q) => q.id == 'combo_3', orElse: () => dailyQuests[0]);
    if (!q.completed && combo > q.progress) {
      q.progress = combo;
      if (q.progress >= q.target) q.completed = true;
    }
  }

  static void _progress(String id, int by) {
    for (final q in dailyQuests) {
      if (q.id == id && !q.completed) {
        q.progress = (q.progress + by).clamp(0, q.target);
        if (q.progress >= q.target) q.completed = true;
      }
    }
  }

  static int get completedCount => dailyQuests.where((q) => q.completed).length;
}
