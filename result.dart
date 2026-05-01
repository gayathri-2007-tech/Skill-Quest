import 'package:flutter/material.dart';
import '../theme.dart';
import 'dashboard.dart';

class ResultPage extends StatefulWidget {
  final int score;
  final int total;
  final List<String> mistakes;
  final int maxCombo;

  const ResultPage({
    Key? key,
    required this.score,
    required this.total,
    required this.mistakes,
    this.maxCombo = 0,
  }) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  int get accuracy => widget.total == 0 ? 0 : ((widget.score / widget.total) * 100).round().clamp(0, 100);

  String get grade {
    if (accuracy >= 90) return '🏆 LEGENDARY';
    if (accuracy >= 70) return '⭐ GREAT';
    if (accuracy >= 50) return '👍 GOOD';
    return '📚 KEEP GOING';
  }

  Color get gradeColor {
    if (accuracy >= 90) return SQ.gold;
    if (accuracy >= 70) return SQ.green;
    if (accuracy >= 50) return SQ.blue;
    return SQ.purple3;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SQ.bg,
      body: Column(children: [
        _header(),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(children: [
            // Badge
            ScaleTransition(scale: _anim, child: Container(
              width: 130, height: 130,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: gradeColor.withValues(alpha: 0.15),
                border: Border.all(color: gradeColor, width: 5),
                boxShadow: [BoxShadow(color: gradeColor.withValues(alpha: 0.4), blurRadius: 40)]),
              child: const Center(child: Text('🎯', style: TextStyle(fontSize: 60))),
            )),
            const SizedBox(height: 24),
            Text(grade, style: TextStyle(color: gradeColor, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1)),
            const SizedBox(height: 8),
            Text('Quiz Complete!', style: const TextStyle(color: SQ.text2, fontSize: 16)),
            const SizedBox(height: 40),

            // Stats row
            Row(children: [
              _stat('SCORE', '${widget.score}', SQ.blue),
              _stat('ACCURACY', '$accuracy%', accuracy >= 70 ? SQ.green : SQ.gold),
              _stat('MAX COMBO', '${widget.maxCombo}x', SQ.orange),
              _stat('MISTAKES', '${widget.mistakes.length}', widget.mistakes.isEmpty ? SQ.green : SQ.red),
            ]),
            const SizedBox(height: 32),

            // Mistakes review
            if (widget.mistakes.isNotEmpty) ...[
              Container(width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: SQ.surface, borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: SQ.border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.warning_amber_rounded, color: SQ.orange, size: 18),
                    const SizedBox(width: 8),
                    const Text('REVIEW THESE', style: TextStyle(color: SQ.text, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ]),
                  const SizedBox(height: 16),
                  ...widget.mistakes.take(3).map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Icon(Icons.circle, color: SQ.red, size: 6),
                      const SizedBox(width: 10),
                      Expanded(child: Text(m.length > 80 ? '${m.substring(0, 80)}…' : m,
                          style: const TextStyle(color: SQ.text2, fontSize: 13, height: 1.4))),
                    ]),
                  )),
                ]),
              ),
              const SizedBox(height: 32),
            ],

            // Actions
            SizedBox(width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => Dashboard())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SQ.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('CONTINUE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('PLAY AGAIN', style: TextStyle(color: SQ.blue, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ]),
        )),
      ]),
    );
  }

  Widget _header() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(color: SQ.bg2, border: Border(bottom: BorderSide(color: SQ.border))),
      child: Row(children: [
        const Text('LESSON SUMMARY', style: TextStyle(color: SQ.text2, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const Spacer(),
        IconButton(onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: SQ.text3)),
      ]),
    );
  }

  Widget _stat(String label, String val, Color color) {
    return Expanded(child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(color: SQ.surface, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: SQ.border)),
      child: Column(children: [
        Text(val, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: SQ.text3, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ]),
    ));
  }
}
