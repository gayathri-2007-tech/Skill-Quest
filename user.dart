// models/user.dart
class UserData {
  // ─── Core XP ────────────────────────────────────────────────────────────────
  static int xp = 0;

  static Map<String, int> skillXP = {
    "Programming": 0, "Aptitude": 0, "Communication": 0,
  };
  static Map<String, int> skillAttempts = {
    "Programming": 0, "Aptitude": 0, "Communication": 0,
  };
  static Map<String, int> skillCorrect = {
    "Programming": 0, "Aptitude": 0, "Communication": 0,
  };

  // ─── FEATURE 1: Mistake Pattern Detection ───────────────────────────────────
  // Full log: {skill, question, yourAnswer, correctAnswer, timestamp, attemptNumber}
  static List<Map<String, dynamic>> mistakeLog = [];
  // How many times each question was answered wrong
  static Map<String, int> mistakeFrequency = {};

  static void recordMistake(
      String skill, String question, String yourAnswer, String correctAnswer) {
    mistakeLog.add({
      'skill': skill,
      'question': question,
      'yourAnswer': yourAnswer,
      'correctAnswer': correctAnswer,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    mistakeFrequency[question] = (mistakeFrequency[question] ?? 0) + 1;
  }

  /// Top repeated mistakes for a skill, sorted by frequency
  static List<Map<String, dynamic>> topMistakesForSkill(String skill, {int limit = 3}) {
    final skillMistakes = mistakeLog.where((m) => m['skill'] == skill).toList();
    final Map<String, Map<String, dynamic>> deduped = {};
    for (var m in skillMistakes) {
      final q = m['question'] as String;
      deduped[q] = {...m, 'frequency': mistakeFrequency[q] ?? 1};
    }
    final sorted = deduped.values.toList()
      ..sort((a, b) => (b['frequency'] as int).compareTo(a['frequency'] as int));
    return sorted.take(limit).toList();
  }

  /// Detected error pattern label (heuristic keyword analysis)
  static String mistakePatternLabel(String skill) {
    final mistakes = mistakeLog.where((m) => m['skill'] == skill).toList();
    if (mistakes.isEmpty) return 'No patterns yet';
    int conceptual = 0, calculation = 0, vocabulary = 0;
    for (var m in mistakes) {
      final q = (m['question'] as String).toLowerCase();
      if (q.contains('what is') || q.contains('define') || q.contains('means'))
        vocabulary++;
      else if (q.contains('solve') || q.contains('calculate') ||
          q.contains('=') || q.contains('+') || q.contains('*'))
        calculation++;
      else
        conceptual++;
    }
    if (calculation >= conceptual && calculation >= vocabulary) return 'Calculation errors';
    if (vocabulary >= conceptual) return 'Definition / vocabulary gaps';
    return 'Conceptual misunderstanding';
  }

  // ─── FEATURE 2: Weak Area + Targeted Practice ───────────────────────────────
  // Key: "skill::question" → {correct, total}
  static Map<String, Map<String, int>> questionStats = {};

  static void recordQuestionResult(String skill, String question, bool correct) {
    final key = '$skill::$question';
    questionStats[key] ??= {'correct': 0, 'total': 0};
    questionStats[key]!['total'] = (questionStats[key]!['total'] ?? 0) + 1;
    if (correct) {
      questionStats[key]!['correct'] = (questionStats[key]!['correct'] ?? 0) + 1;
    }
  }

  /// Questions that need targeted practice (accuracy < 60%), sorted worst first
  static List<Map<String, dynamic>> targetedPracticeItems(String skill) {
    List<Map<String, dynamic>> weak = [];
    questionStats.forEach((key, stats) {
      if (!key.startsWith('$skill::')) return;
      final total = stats['total'] ?? 0;
      if (total == 0) return;
      final acc = (stats['correct'] ?? 0) / total;
      if (acc < 0.6) {
        weak.add({
          'question': key.replaceFirst('$skill::', ''),
          'accuracy': (acc * 100).round(),
          'attempts': total,
        });
      }
    });
    weak.sort((a, b) => (a['accuracy'] as int).compareTo(b['accuracy'] as int));
    return weak.take(3).toList();
  }

  // ─── FEATURE 3: Second Attempt Learning Rate ────────────────────────────────
  // skill → [accuracy0, accuracy1, ...] per attempt
  static Map<String, List<double>> attemptAccuracy = {
    "Programming": [], "Aptitude": [], "Communication": [],
  };
  static Map<String, List<int>> attemptScores = {
    "Programming": [], "Aptitude": [], "Communication": [],
  };

  static void recordAttempt(String skill, int score, double accuracy) {
    attemptScores[skill] ??= [];
    attemptAccuracy[skill] ??= [];
    attemptScores[skill]!.add(score);
    attemptAccuracy[skill]!.add(accuracy);
  }

  /// % improvement from first attempt to latest
  static double learningRate(String skill) {
    final scores = attemptAccuracy[skill] ?? [];
    if (scores.length < 2) return 0.0;
    final first = scores.first;
    final latest = scores.last;
    if (first == 0) return latest * 100;
    return ((latest - first) / first) * 100;
  }

  static String learningTrend(String skill) {
    final scores = attemptAccuracy[skill] ?? [];
    if (scores.length < 2) return 'First attempt — baseline set';
    final rate = learningRate(skill);
    if (rate > 20) return 'Rapidly improving 🚀';
    if (rate > 5) return 'Steadily improving 📈';
    if (rate > -5) return 'Holding steady ➡️';
    return 'Needs attention 📉';
  }

  static int attemptCount(String skill) => (attemptScores[skill] ?? []).length;

  // ─── FEATURE 4: Exam Temperament Analysis ───────────────────────────────────
  // Last quiz timings per skill: [{questionIndex, timeSpent (0–10s), correct}]
  static Map<String, List<Map<String, dynamic>>> lastQuizTimings = {};

  static void recordAnswerTiming(
      String skill, int questionIndex, int timeSpentSeconds, bool correct) {
    lastQuizTimings[skill] ??= [];
    lastQuizTimings[skill]!.add({
      'qi': questionIndex,
      'time': timeSpentSeconds,
      'correct': correct,
    });
  }

  static void clearTimings(String skill) {
    lastQuizTimings[skill] = [];
  }

  static double avgResponseTime(String skill) {
    final t = lastQuizTimings[skill] ?? [];
    if (t.isEmpty) return 0;
    final sum = t.fold<int>(0, (s, e) => s + (e['time'] as int));
    return sum / t.length;
  }

  /// Temperament label based on speed × accuracy matrix
  static String temperamentLabel(String skill) {
    final t = lastQuizTimings[skill] ?? [];
    if (t.isEmpty) return 'No data yet';
    final avg = avgResponseTime(skill);
    final accuracy = accuracyForSkill(skill);
    if (avg <= 4 && accuracy >= 70) return 'Sharp & Decisive ⚡';
    if (avg <= 4 && accuracy < 70) return 'Hasty — slow down 🐇';
    if (avg > 7 && accuracy >= 70) return 'Careful & Thorough 🦉';
    if (avg > 7 && accuracy < 70) return 'Overthinking it 🤔';
    return 'Balanced Approach ⚖️';
  }

  /// % of answers given in ≤2s (panic/rushed answers)
  static int panicIndex(String skill) {
    final t = lastQuizTimings[skill] ?? [];
    if (t.isEmpty) return 0;
    final rushed = t.where((e) => (e['time'] as int) <= 2).length;
    return ((rushed / t.length) * 100).round();
  }

  // ─── FEATURE 5: Skill Decay / Smart Revision ────────────────────────────────
  static Map<String, int> lastQuizTimestamp = {
    "Programming": 0, "Aptitude": 0, "Communication": 0,
  };

  static void markQuizPlayed(String skill) {
    lastQuizTimestamp[skill] = DateTime.now().millisecondsSinceEpoch;
  }

  static int daysSinceLastQuiz(String skill) {
    final ts = lastQuizTimestamp[skill] ?? 0;
    if (ts == 0) return 999;
    final diff = DateTime.now().millisecondsSinceEpoch - ts;
    return (diff / (1000 * 60 * 60 * 24)).floor();
  }

  /// 0 = fresh, 100 = heavily decayed
  static int decayScore(String skill) {
    final days = daysSinceLastQuiz(skill);
    final accuracy = accuracyForSkill(skill);
    final dayDecay = (days * 10).clamp(0, 70);
    final accDecay = accuracy == 0 ? 0 : ((100 - accuracy) * 0.3).round().clamp(0, 30);
    return (dayDecay + accDecay).clamp(0, 100) as int;
  }

  static String revisionUrgency(String skill) {
    final decay = decayScore(skill);
    if (decay >= 70) return 'Revise now 🔴';
    if (decay >= 40) return 'Due for revision 🟡';
    if (decay >= 10) return 'Good shape 🟢';
    return 'Fresh ✨';
  }

  static List<String> revisionPriority() {
    final skills = ["Programming", "Aptitude", "Communication"];
    return skills..sort((a, b) => decayScore(b).compareTo(decayScore(a)));
  }

  // ─── Shared helpers ──────────────────────────────────────────────────────────
  static void addSkillXP(String skill, int points, int correct, int total) {
    xp += points;
    skillXP[skill] = (skillXP[skill] ?? 0) + points;
    skillAttempts[skill] = (skillAttempts[skill] ?? 0) + total;
    skillCorrect[skill] = (skillCorrect[skill] ?? 0) + correct;
  }

  static int accuracyForSkill(String skill) {
    final attempts = skillAttempts[skill] ?? 0;
    final correct = skillCorrect[skill] ?? 0;
    if (attempts == 0) return 0;
    return ((correct / attempts) * 100).round();
  }

  static String skillLevel(String skill) {
    final v = skillXP[skill] ?? 0;
    if (v >= 200) return "Master";
    if (v >= 100) return "Expert";
    if (v >= 50) return "Journeyman";
    if (v >= 20) return "Apprentice";
    return "Novice";
  }

  static int xpForNextLevel(String skill) {
    final v = skillXP[skill] ?? 0;
    if (v >= 200) return 200;
    if (v >= 100) return 200;
    if (v >= 50) return 100;
    if (v >= 20) return 50;
    return 20;
  }

  static int xpLevelStart(String skill) {
    final v = skillXP[skill] ?? 0;
    if (v >= 200) return 200;
    if (v >= 100) return 100;
    if (v >= 50) return 50;
    if (v >= 20) return 20;
    return 0;
  }
}
