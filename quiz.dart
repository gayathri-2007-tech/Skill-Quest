import 'package:flutter/material.dart';
import 'dart:async';
import '../models/question.dart';
import '../services/quiz_service.dart';
import '../services/firebase_service.dart';
import '../services/quest_service.dart';
import '../models/achievement.dart';
import '../theme.dart';
import 'result.dart';

class QuizPage extends StatefulWidget {
  final String skill;
  const QuizPage({Key? key, required this.skill}) : super(key: key);
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
  // ── State ─────────────────────────────────────────────────────
  int index = 0, score = 0, combo = 0, maxCombo = 0;
  List<String> mistakes = [];
  String? selectedAnswer;
  bool answered = false;
  Set<String> eliminated = {};
  bool has5050 = true, hasSkip = true;
  int timeLeft = 15;
  Timer? _timer;
  Achievement? _pendingAchievement;
  late List<Question> questions;

  // ── Animations ────────────────────────────────────────────────
  late AnimationController _slideCtrl, _comboCtrl, _badgeCtrl;
  late Animation<double> _slideAnim, _comboAnim, _badgeAnim;



  @override
  void initState() {
    super.initState();
    questions = QuizService.getQuestions(widget.skill);

    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350))..forward();
    _slideAnim  = CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut);

    _comboCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _comboAnim  = CurvedAnimation(parent: _comboCtrl, curve: Curves.elasticOut);

    _badgeCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _badgeAnim  = CurvedAnimation(parent: _badgeCtrl, curve: Curves.elasticOut);

    _startTimer();
  }

  // ── Timer ─────────────────────────────────────────────────────
  void _startTimer() {
    _timer?.cancel();
    timeLeft = 15;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => timeLeft--);
      if (timeLeft <= 0) {
        _timer?.cancel();
        _timeUp();
      }
    });
  }

  void _timeUp() {
    if (answered) return;
    setState(() { answered = true; combo = 0; });
    Future.delayed(const Duration(milliseconds: 1200), _next);
  }

  // ── Answer ────────────────────────────────────────────────────
  void _answer(String key) {
    if (answered) return;
    _timer?.cancel();
    final bool correct = key == questions[index].correct;
    final int timeBonus   = (timeLeft * 0.5).round();
    final int mult        = combo >= 5 ? 3 : combo >= 3 ? 2 : 1;
    final int gained      = correct ? (10 + timeBonus) * mult : 0;

    setState(() {
      selectedAnswer = key;
      answered = true;
      if (correct) {
        score += gained;
        combo++;
        maxCombo = combo > maxCombo ? combo : maxCombo;
        QuestService.recordCorrect();
        QuestService.recordCombo(combo);
        if (timeLeft >= 12) _tryBadge('speed_answer');
        if (combo >= 3)     _tryBadge('combo_3');
        if (combo >= 5)     _tryBadge('combo_5');
      } else {
        combo = 0;
        mistakes.add(questions[index].question);
      }
    });

    if (correct) _comboCtrl.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 1300), _next);
  }

  void _tryBadge(String id) {
    final a = AchievementService.tryUnlock(id);
    if (a != null) setState(() => _pendingAchievement = a);
    _badgeCtrl.forward(from: 0);
  }

  void _use5050() {
    if (!has5050 || answered) return;
    final wrong = questions[index].options.keys
        .where((k) => k != questions[index].correct).toList()..shuffle();
    setState(() { has5050 = false; eliminated = {wrong[0], wrong[1]}; });
  }

  void _useSkip() {
    if (!hasSkip || answered) return;
    _timer?.cancel();
    setState(() { hasSkip = false; });
    _next();
  }

  void _next() {
    if (index < questions.length - 1) {
      setState(() {
        index++; selectedAnswer = null; answered = false;
        eliminated = {}; _pendingAchievement = null;
      });
      _slideCtrl.reset();
      _slideCtrl.forward();
      _startTimer();
    } else {
      _timer?.cancel();
      if (mistakes.isEmpty) AchievementService.tryUnlock('perfect_quiz');
      AchievementService.tryUnlock('first_quiz');
      if (widget.skill == 'CodeSpeak') AchievementService.tryUnlock('code_speak');
      QuestService.recordQuizComplete();
      FirebaseService.saveScore('Player', score, skill: widget.skill);
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => ResultPage(score: score, total: questions.length * 10, mistakes: mistakes, maxCombo: maxCombo),
      ));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _slideCtrl.dispose(); _comboCtrl.dispose(); _badgeCtrl.dispose();
    super.dispose();
  }

  // ── UI ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final q = questions[index];
    final double timerRatio  = timeLeft / 15;
    final Color  timerColor  = timeLeft > 8 ? SQ.green : timeLeft > 4 ? SQ.gold : SQ.red;
    final double progress    = (index + 1) / questions.length;

    return Scaffold(
      backgroundColor: SQ.bg,
      body: Stack(children: [
        Column(children: [
          _header(progress, timerRatio, timerColor),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: FadeTransition(
              opacity: _slideAnim,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (combo >= 2) _comboChip(),
                const SizedBox(height: 20),
                // Code block for CodeSpeak questions
                if (q.question.contains('```')) _codeBlock(q.question),
                if (!q.question.contains('```'))
                  Text(q.question, style: const TextStyle(color: SQ.text, fontSize: 22, fontWeight: FontWeight.w900, height: 1.4)),
                const SizedBox(height: 36),
                ..._options(q),
              ]),
            ),
          )),
          _powerBar(),
        ]),
        // Achievement popup
        if (_pendingAchievement != null) _achievementPopup(_pendingAchievement!),
      ]),
    );
  }

  Widget _header(double progress, double timerRatio, Color tc) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
      decoration: BoxDecoration(color: SQ.bg2, border: Border(bottom: BorderSide(color: SQ.border))),
      child: Column(children: [
        Row(children: [
          IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close, color: SQ.text3)),
          const SizedBox(width: 8),
          Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(value: progress, backgroundColor: SQ.border,
              valueColor: AlwaysStoppedAnimation(SQ.blue), minHeight: 8))),
          const SizedBox(width: 12),
          Text('${index + 1}/${questions.length}', style: TextStyle(color: SQ.text2, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          const SizedBox(width: 16),
          Icon(Icons.timer, color: tc, size: 16),
          const SizedBox(width: 8),
          Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: timerRatio, backgroundColor: SQ.surface,
              valueColor: AlwaysStoppedAnimation(tc), minHeight: 6))),
          const SizedBox(width: 8),
          Text('$timeLeft s', style: TextStyle(color: tc, fontSize: 12, fontWeight: FontWeight.w900)),
          const SizedBox(width: 16),
        ]),
      ]),
    );
  }

  Widget _comboChip() {
    final isLegend = combo >= 5;
    return ScaleTransition(scale: _comboAnim,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: (isLegend ? SQ.gold : SQ.blue).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isLegend ? SQ.gold : SQ.blue),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(isLegend ? '🔥' : '⚡', style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text('${combo}x COMBO  ·  ${isLegend ? '3x' : combo >= 3 ? '2x' : '1.5x'} XP',
            style: TextStyle(color: isLegend ? SQ.gold : SQ.blue,
              fontWeight: FontWeight.w900, fontSize: 13)),
        ]),
      ),
    );
  }

  Widget _codeBlock(String raw) {
    final parts = raw.split('```');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (parts[0].trim().isNotEmpty)
        Text(parts[0].trim(), style: const TextStyle(color: SQ.text, fontSize: 20, fontWeight: FontWeight.w900, height: 1.4)),
      const SizedBox(height: 16),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: SQ.surface2, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SQ.border2)),
        child: Text(parts.length > 1 ? parts[1].trim() : '',
          style: const TextStyle(color: SQ.green, fontFamily: 'monospace', fontSize: 14, height: 1.6)),
      ),
      if (parts.length > 2 && parts[2].trim().isNotEmpty) ...[
        const SizedBox(height: 12),
        Text(parts[2].trim(), style: const TextStyle(color: SQ.text2, fontSize: 16, height: 1.4)),
      ],
    ]);
  }

  List<Widget> _options(Question q) {
    return q.options.entries.map((entry) {
      final key = entry.key;
      final val = entry.value;
      if (eliminated.contains(key)) {
        return Padding(padding: const EdgeInsets.only(bottom: 12),
          child: Container(padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: SQ.surface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: SQ.border.withValues(alpha: 0.3))),
            child: Text(val, style: TextStyle(color: SQ.text3.withValues(alpha: 0.4),
              decoration: TextDecoration.lineThrough, fontSize: 15))));
      }
      final bool isSel    = selectedAnswer == key;
      final bool isRight  = answered && key == q.correct;
      final bool isWrong  = isSel && answered && key != q.correct;
      final Color accent  = isRight ? SQ.green : isWrong ? SQ.red : isSel ? SQ.blue : SQ.border2;
      final Color bg      = isRight ? SQ.green.withValues(alpha: 0.15) : isWrong ? SQ.red.withValues(alpha: 0.12) : isSel ? SQ.blue.withValues(alpha: 0.12) : SQ.surface;

      return Padding(padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(onTap: () => _answer(key),
          child: AnimatedContainer(duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent, width: 2),
              boxShadow: (isRight || isWrong) ? [BoxShadow(color: accent.withValues(alpha: 0.25), blurRadius: 12)] : []),
            child: Row(children: [
              Container(width: 32, height: 32,
                decoration: BoxDecoration(color: accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accent.withValues(alpha: 0.6))),
                child: Center(child: Text(key, style: TextStyle(color: accent, fontWeight: FontWeight.w900)))),
              const SizedBox(width: 16),
              Expanded(child: Text(val, style: const TextStyle(color: SQ.text, fontSize: 15, fontWeight: FontWeight.w600))),
              if (isRight) Icon(Icons.check_circle_rounded, color: SQ.green),
              if (isWrong) Icon(Icons.cancel_rounded, color: SQ.red),
            ]),
          ),
        ),
      );
    }).toList();
  }

  Widget _powerBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 14, 40, 28),
      decoration: BoxDecoration(color: SQ.bg2, border: Border(top: BorderSide(color: SQ.border))),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _powerBtn('50 / 50', Icons.filter_2_rounded, SQ.purple, has5050, _use5050),
        const SizedBox(width: 24),
        _powerBtn('SKIP', Icons.skip_next_rounded, SQ.gold, hasSkip, _useSkip),
      ]),
    );
  }

  Widget _powerBtn(String label, IconData icon, Color color, bool available, VoidCallback onTap) {
    return GestureDetector(
      onTap: available && !answered ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: available && !answered ? 1.0 : 0.35,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13)),
          ]),
        ),
      ),
    );
  }

  Widget _achievementPopup(Achievement a) {
    return Positioned(
      top: 100, left: 0, right: 0,
      child: Center(child: ScaleTransition(scale: _badgeAnim,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: a.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: a.color, width: 2),
            boxShadow: [BoxShadow(color: a.color.withValues(alpha: 0.3), blurRadius: 30)],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(a.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('ACHIEVEMENT UNLOCKED', style: TextStyle(color: a.color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
              Text(a.title, style: const TextStyle(color: SQ.text, fontSize: 18, fontWeight: FontWeight.w900)),
            ]),
          ]),
        ),
      )),
    );
  }
}
