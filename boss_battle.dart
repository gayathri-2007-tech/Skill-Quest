import 'package:flutter/material.dart';
import 'dart:async';
import '../theme.dart';
import '../models/achievement.dart';
import '../services/firebase_service.dart';

// ── Boss Questions (Code + Communication combined) ──────────────
final List<Map<String, dynamic>> _bossQuestions = [
  {
    'q': 'What does this function return?\n```\ndef mystery(n):\n    return n * (n + 1) // 2\n```\nExplain it like you\'re teaching a 12-year-old.',
    'opts': {'A': 'Sum of first n natural numbers', 'B': 'n squared divided by 2', 'C': 'Factorial of n', 'D': 'n multiplied by itself'},
    'correct': 'A',
  },
  {
    'q': 'A Big O of O(n²) algorithm runs too slowly for 10,000 inputs. Which explanation best communicates the problem to your manager?',
    'opts': {
      'A': 'It has quadratic time complexity and exceeds acceptable runtime thresholds',
      'B': 'For 10,000 items, it performs 100 million operations — it will take too long',
      'C': 'The nested loops cause exponential growth in execution time',
      'D': 'The algorithm is inefficient due to poor asymptotic behavior',
    },
    'correct': 'B',
  },
  {
    'q': 'What\'s wrong with this code?\n```\nfor i in range(10):\n    list = []\n    list.append(i)\nprint(list)\n```',
    'opts': {'A': 'List is reset inside the loop every iteration', 'B': 'Range is wrong', 'C': 'Missing return statement', 'D': 'append() is not a valid method'},
    'correct': 'A',
  },
  {
    'q': 'You need to explain "recursion" to a non-technical HR person. Which is best?',
    'opts': {
      'A': 'Recursion is when a function calls itself with a smaller input until a base case is reached',
      'B': 'Think of it like Russian dolls — each doll opens to reveal a smaller one, until the tiniest one stops',
      'C': 'It\'s a loop that uses the call stack instead of iteration',
      'D': 'A method that invokes itself through stack-based memoization',
    },
    'correct': 'B',
  },
  {
    'q': 'What does this code print?\n```\nx = [1, 2, 3]\ny = x\ny.append(4)\nprint(x)\n```',
    'opts': {'A': '[1, 2, 3]', 'B': '[1, 2, 3, 4]', 'C': 'Error', 'D': '[4]'},
    'correct': 'B',
  },
  {
    'q': 'Your team\'s code review catches a bug at 2 AM before launch. How do you communicate this to the client?',
    'opts': {
      'A': 'We found a critical defect in the system integration layer requiring immediate remediation',
      'B': 'We found a bug before launch — we\'re fixing it now and will update you in 30 minutes',
      'C': 'There\'s an error in the code. We might delay the launch',
      'D': 'The QA pipeline identified an edge case failure in the deployment artifact',
    },
    'correct': 'B',
  },
  {
    'q': 'Which data structure is best for "undo" functionality in a text editor?',
    'opts': {'A': 'Queue', 'B': 'Linked List', 'C': 'Stack', 'D': 'Binary Tree'},
    'correct': 'C',
  },
  {
    'q': 'A teammate writes unclear variable names like "x", "tmp2", "flag3". How do you raise this without damaging morale?',
    'opts': {
      'A': 'Their code is bad and unprofessional — say so in the review',
      'B': 'Silently rename everything yourself',
      'C': 'Suggest: "Could we use descriptive names here? It\'ll help everyone including future-you!"',
      'D': 'Escalate directly to the manager',
    },
    'correct': 'C',
  },
  {
    'q': 'What is the output?\n```\nprint(bool("") or bool("hello"))\n```',
    'opts': {'A': 'False', 'B': 'True', 'C': 'None', 'D': 'Error'},
    'correct': 'B',
  },
  {
    'q': 'Explain what an API is to someone who has never coded.',
    'opts': {
      'A': 'An Application Programming Interface that exposes endpoints for data exchange',
      'B': 'A waiter at a restaurant — you order from the menu (API), and it brings back what the kitchen (server) makes',
      'C': 'A bridge between two software systems that transmits structured data',
      'D': 'A communication protocol between front-end and back-end components',
    },
    'correct': 'B',
  },
];

class BossBattlePage extends StatefulWidget {
  const BossBattlePage({Key? key}) : super(key: key);
  @override
  _BossBattleState createState() => _BossBattleState();
}

class _BossBattleState extends State<BossBattlePage> with TickerProviderStateMixin {
  int index = 0, lives = 3, bossHp = 100, score = 0;
  bool answered = false, gameOver = false, victory = false;
  String? selected;
  int timeLeft = 10;
  Timer? _timer;

  late AnimationController _bossShakeCtrl, _entryCtrl;

  @override
  void initState() {
    super.initState();
    _bossShakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    timeLeft = 10;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => timeLeft--);
      if (timeLeft <= 0) { _timer?.cancel(); _answer(null); }
    });
  }

  void _answer(String? key) {
    if (answered || gameOver) return;
    _timer?.cancel();
    final bool correct = key == _bossQuestions[index]['correct'];
    setState(() {
      selected  = key;
      answered  = true;
      if (correct) {
        bossHp -= 10;
        score  += 15 + timeLeft;
        _bossShakeCtrl.forward(from: 0);
      } else {
        lives--;
        if (lives <= 0) gameOver = true;
      }
    });
    Future.delayed(const Duration(milliseconds: 1400), _next);
  }

  void _next() {
    if (gameOver) { setState(() {}); return; }
    if (bossHp <= 0 || index >= _bossQuestions.length - 1) {
      setState(() => victory = true);
      AchievementService.tryUnlock('boss_slain');
      FirebaseService.saveScore('Player', score, skill: 'Boss');
      return;
    }
    setState(() { index++; answered = false; selected = null; });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bossShakeCtrl.dispose(); _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (victory || gameOver) return _endScreen();
    final q = _bossQuestions[index];
    final Color tc = timeLeft > 6 ? SQ.green : timeLeft > 3 ? SQ.gold : SQ.red;

    return Scaffold(
      backgroundColor: const Color(0xFF0A000F),
      body: Column(children: [
        // Boss header
        _bossHeader(tc),
        // Question
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: SQ.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8),
                border: Border.all(color: SQ.red.withValues(alpha: 0.4))),
              child: Text('⚔️  BOSS CHALLENGE ${index + 1}/10',
                style: TextStyle(color: SQ.red, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2))),
            const SizedBox(height: 20),
            _renderQuestion(q['q'] as String),
            const SizedBox(height: 32),
            ...(q['opts'] as Map<String, String>).entries.map((e) => _option(e.key, e.value, q['correct'] as String)),
          ]),
        )),
      ]),
    );
  }

  Widget _bossHeader(Color tc) {
    final double hpRatio = bossHp / 100;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
      decoration: const BoxDecoration(color: Color(0xFF14001F)),
      child: Column(children: [
        Row(children: [
          IconButton(onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white38)),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('FINAL BOSS', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 3, fontWeight: FontWeight.bold)),
            const Text('CODE MASTER', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          ])),
          // Lives
          Row(children: List.generate(3, (i) =>
            Padding(padding: const EdgeInsets.only(left: 4),
              child: Icon(Icons.favorite, color: i < lives ? SQ.red : Colors.white12, size: 22)))),
        ]),
        const SizedBox(height: 12),
        // Boss HP bar
        Row(children: [
          const Text('👾', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('BOSS HP', style: TextStyle(color: SQ.red, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
              const Spacer(),
              Text('$bossHp / 100', style: TextStyle(color: SQ.red, fontSize: 11, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 4),
            ClipRRect(borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: hpRatio, backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation(Color(0xFFFF3366)), minHeight: 10)),
          ])),
        ]),
        const SizedBox(height: 10),
        // Timer
        Row(children: [
          const SizedBox(width: 32),
          Icon(Icons.timer, color: tc, size: 14),
          const SizedBox(width: 6),
          Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: timeLeft / 10, backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(tc), minHeight: 5))),
          const SizedBox(width: 8),
          Text('$timeLeft s', style: TextStyle(color: tc, fontSize: 11, fontWeight: FontWeight.bold)),
        ]),
      ]),
    );
  }

  Widget _renderQuestion(String raw) {
    if (!raw.contains('```')) {
      return Text(raw, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, height: 1.4));
    }
    final parts = raw.split('```');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (parts[0].trim().isNotEmpty)
        Text(parts[0].trim(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, height: 1.4)),
      const SizedBox(height: 12),
      Container(width: double.infinity, padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF1A002A), borderRadius: BorderRadius.circular(10),
          border: Border.all(color: SQ.purple.withValues(alpha: 0.5))),
        child: Text(parts[1].trim(), style: const TextStyle(color: Color(0xFF7AFFB2), fontFamily: 'monospace', fontSize: 13, height: 1.6))),
      if (parts.length > 2 && parts[2].trim().isNotEmpty) ...[
        const SizedBox(height: 12),
        Text(parts[2].trim(), style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.4)),
      ],
    ]);
  }

  Widget _option(String key, String val, String correct) {
    final bool isSel   = selected == key;
    final bool isRight = answered && key == correct;
    final bool isWrong = isSel && answered && key != correct;
    final Color accent = isRight ? SQ.green : isWrong ? SQ.red : isSel ? SQ.purple : Colors.white24;

    return Padding(padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(onTap: () => _answer(key),
        child: AnimatedContainer(duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isRight ? SQ.green.withValues(alpha: 0.15) : isWrong ? SQ.red.withValues(alpha: 0.12) : const Color(0xFF1A002A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent, width: 2),
            boxShadow: (isRight || isWrong) ? [BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 12)] : [],
          ),
          child: Row(children: [
            Container(width: 28, height: 28,
              decoration: BoxDecoration(color: accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6),
                border: Border.all(color: accent.withValues(alpha: 0.7))),
              child: Center(child: Text(key, style: TextStyle(color: accent, fontWeight: FontWeight.w900, fontSize: 13)))),
            const SizedBox(width: 14),
            Expanded(child: Text(val, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))),
            if (isRight) const Icon(Icons.check_circle_rounded, color: SQ.green, size: 22),
            if (isWrong) const Icon(Icons.cancel_rounded, color: SQ.red, size: 22),
          ]),
        ),
      ),
    );
  }

  Widget _endScreen() {
    return Scaffold(
      backgroundColor: victory ? const Color(0xFF001020) : const Color(0xFF150000),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(victory ? '🏆' : '💀', style: const TextStyle(fontSize: 80)),
        const SizedBox(height: 24),
        Text(victory ? 'BOSS DEFEATED!' : 'YOU FELL...',
          style: TextStyle(color: victory ? SQ.gold : SQ.red, fontSize: 36, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        Text(victory ? 'Code Master has been slain!' : 'Better luck next time, warrior.',
          style: const TextStyle(color: Colors.white54, fontSize: 16)),
        if (victory) ...[
          const SizedBox(height: 8),
          Text('Score: $score XP  •  Achievement: Boss Slayer 🏆',
            style: TextStyle(color: SQ.gold, fontWeight: FontWeight.bold)),
        ],
        const SizedBox(height: 48),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
            decoration: BoxDecoration(
              color: victory ? SQ.gold : SQ.red,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: (victory ? SQ.gold : SQ.red).withValues(alpha: 0.4), blurRadius: 24)],
            ),
            child: Text(victory ? 'CLAIM GLORY' : 'TRY AGAIN',
              style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w900))),
        ),
      ])),
    );
  }
}
