import 'package:flutter/material.dart';
import 'quiz.dart';
import 'leaderboard.dart';
import 'boss_battle.dart';
import 'login.dart' show LoginPage;
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import '../services/quest_service.dart';
import '../models/achievement.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SQ.bg,
      body: Row(children: [
        _sidebar(),
        Expanded(child: Column(children: [
          _topBar(),
          Expanded(child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: Container(key: ValueKey(_selectedIndex), child: _body()),
          )),
        ])),
      ]),
    );
  }

  // ── Sidebar ──────────────────────────────────────────────────
  Widget _sidebar() {
    return Container(
      width: 80,
      decoration: BoxDecoration(color: SQ.bg2, border: Border(right: BorderSide(color: SQ.border))),
      child: Column(children: [
        const SizedBox(height: 32),
        Icon(Icons.psychology_rounded, color: SQ.blue, size: 40),
        const SizedBox(height: 48),
        _sideIcon(0, Icons.home_rounded),
        _sideIcon(1, Icons.emoji_events_rounded),
        _sideIcon(2, Icons.analytics_rounded),
        _sideIcon(3, Icons.military_tech_rounded),
        const Spacer(),
        _sideIcon(-1, Icons.logout_rounded, isLogout: true),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _sideIcon(int index, IconData icon, {bool isLogout = false}) {
    final bool sel = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (isLogout) {
          FirebaseAuth.instance.signOut();
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
        } else {
          setState(() => _selectedIndex = index);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(12),
        decoration: sel ? BoxDecoration(color: SQ.blue.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12), border: Border.all(color: SQ.blue, width: 2)) : null,
        child: Icon(icon, color: sel ? SQ.blue : SQ.text3, size: 28),
      ),
    );
  }

  // ── Top Bar ───────────────────────────────────────────────────
  Widget _topBar() {
    final labels = ['MASTERY PATH', 'LEADERBOARD', 'ANALYTICS', 'ACHIEVEMENTS'];
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(color: SQ.bg2, border: Border(bottom: BorderSide(color: SQ.border))),
      child: Row(children: [
        Text(labels[_selectedIndex.clamp(0, 3)],
            style: TextStyle(color: SQ.text2, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const Spacer(),
        _badge('12 DAY 🔥', SQ.orange),
        const SizedBox(width: 12),
        _badge('1,240 XP 💎', SQ.blue),
        const SizedBox(width: 12),
        _badge('5 ❤️', SQ.red),
        const SizedBox(width: 20),
        CircleAvatar(radius: 18, backgroundColor: SQ.surface,
            child: Icon(Icons.person, color: SQ.text2)),
      ]),
    );
  }

  Widget _badge(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.withValues(alpha: 0.4))),
    child: Text(t, style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 12)),
  );

  // ── Body ──────────────────────────────────────────────────────
  Widget _body() {
    switch (_selectedIndex) {
      case 0: return SingleChildScrollView(child: _learningPath());
      case 1: return LeaderboardPage(showBackButton: false);
      case 2: return SingleChildScrollView(child: _analytics());
      case 3: return SingleChildScrollView(child: _achievementsTab());
      default: return SingleChildScrollView(child: _learningPath());
    }
  }

  // ── Learning Path ─────────────────────────────────────────────
  Widget _learningPath() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Left: skill path
        Expanded(flex: 3, child: Column(children: [
          _unitHeader(1, 'CORE LOGIC', 'Master the foundations of problem solving.', SQ.blue),
          _node(Icons.code_rounded, 'EASY', SQ.green, true, 'Programming', offset: 0),
          _node(Icons.functions_rounded, 'MEDIUM', SQ.blue, false, 'Programming', offset: 50),
          _node(Icons.schema_rounded, 'EASY', SQ.blue, false, 'Aptitude', offset: -50),
          _node(Icons.terminal_rounded, 'HARD', SQ.blue, false, 'Aptitude', offset: 0),
          const SizedBox(height: 16),
          // Boss Battle unlock button
          _bossNode(),
          const SizedBox(height: 48),
          _unitHeader(2, 'CODE + SPEAK', 'Bridge coding with communication.', SQ.purple),
          _node(Icons.record_voice_over_rounded, 'UNIQUE', SQ.purple, false, 'CodeSpeak', offset: 0),
          _node(Icons.translate_rounded, 'EXPLAIN', SQ.purple, false, 'CodeSpeak', offset: 60),
          const SizedBox(height: 48),
          _unitHeader(3, 'DATA STRUCTURES', 'Organize and express information clearly.', SQ.gold),
          _node(Icons.layers_rounded, 'EASY', SQ.gold, false, 'Programming', offset: -40),
          _node(Icons.reorder_rounded, 'MEDIUM', SQ.gold, false, 'Aptitude', offset: 40),
        ])),
        const SizedBox(width: 32),
        // Right: Daily Quests
        SizedBox(width: 280, child: _dailyQuestPanel()),
      ]),
    );
  }

  Widget _unitHeader(int num, String title, String sub, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 2)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('UNIT $num', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(color: SQ.text, fontSize: 20, fontWeight: FontWeight.w900)),
        Text(sub, style: const TextStyle(color: SQ.text2, fontSize: 12)),
      ]),
    );
  }

  Widget _node(IconData icon, String diff, Color color, bool done, String skill, {double offset = 0}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Transform.translate(
        offset: Offset(offset, 0),
        child: Column(children: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizPage(skill: skill))),
            child: Container(width: 80, height: 80,
              decoration: BoxDecoration(color: done ? color : SQ.surface, shape: BoxShape.circle,
                border: Border.all(color: done ? color : SQ.border2, width: 5),
                boxShadow: [BoxShadow(color: done ? color.withValues(alpha: 0.4) : Colors.transparent, blurRadius: 18, offset: const Offset(0, 6))]),
              child: Icon(icon, color: done ? Colors.white : SQ.text3, size: 36)),
          ),
          const SizedBox(height: 8),
          Text(diff, style: TextStyle(color: done ? color : SQ.text3, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ]),
      ),
    );
  }

  Widget _bossNode() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BossBattlePage())),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [const Color(0xFF3D0020), const Color(0xFF1A0035)]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: SQ.red.withValues(alpha: 0.7), width: 2),
          boxShadow: [BoxShadow(color: SQ.red.withValues(alpha: 0.3), blurRadius: 24)],
        ),
        child: Row(children: [
          Container(width: 56, height: 56,
            decoration: BoxDecoration(color: SQ.red.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14),
                border: Border.all(color: SQ.red.withValues(alpha: 0.6))),
            child: const Center(child: Text('👾', style: TextStyle(fontSize: 28)))),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('BOSS BATTLE', style: TextStyle(color: Color(0xFFFF3366), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const Text('CODE MASTER', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            Text('10 questions · 10 seconds each · 3 lives', style: TextStyle(color: SQ.text3, fontSize: 11)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: SQ.red, borderRadius: BorderRadius.circular(10)),
            child: const Text('FIGHT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13))),
        ]),
      ),
    );
  }

  // ── Daily Quests Panel ────────────────────────────────────────
  Widget _dailyQuestPanel() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 3, height: 16, decoration: BoxDecoration(color: SQ.gold, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        const Text('DAILY QUESTS', style: TextStyle(color: SQ.text2, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const Spacer(),
        Text('${QuestService.completedCount}/3', style: TextStyle(color: SQ.gold, fontSize: 11, fontWeight: FontWeight.bold)),
      ]),
      const SizedBox(height: 16),
      ...QuestService.dailyQuests.map(_questCard),
      const SizedBox(height: 24),
      // Quick-launch skill chooser
      const Text('QUICK PLAY', style: TextStyle(color: SQ.text3, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
      const SizedBox(height: 12),
      _quickPlay('⚙️ Programming', SQ.blue, 'Programming'),
      const SizedBox(height: 8),
      _quickPlay('🧮 Aptitude', SQ.purple3, 'Aptitude'),
      const SizedBox(height: 8),
      _quickPlay('🗣️ Communication', SQ.green, 'Communication'),
      const SizedBox(height: 8),
      _quickPlay('💡 Code + Speak', SQ.gold, 'CodeSpeak'),
    ]);
  }

  Widget _questCard(Quest q) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: q.completed ? SQ.green.withValues(alpha: 0.08) : SQ.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: q.completed ? SQ.green.withValues(alpha: 0.4) : SQ.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(q.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(child: Text(q.title, style: TextStyle(
              color: q.completed ? SQ.green : SQ.text, fontSize: 13, fontWeight: FontWeight.w800))),
          if (q.completed) const Icon(Icons.check_circle_rounded, color: SQ.green, size: 18),
        ]),
        const SizedBox(height: 6),
        Text(q.description, style: const TextStyle(color: SQ.text3, fontSize: 11)),
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: q.ratio, backgroundColor: SQ.border,
            valueColor: AlwaysStoppedAnimation(q.completed ? SQ.green : SQ.blue), minHeight: 5)),
        const SizedBox(height: 4),
        Text('${q.progress}/${q.target}', style: TextStyle(color: SQ.text3, fontSize: 10)),
      ]),
    );
  }

  Widget _quickPlay(String label, Color color, String skill) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizPage(skill: skill))),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Row(children: [
          Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
          const Spacer(),
          Icon(Icons.play_arrow_rounded, color: color, size: 18),
        ]),
      ),
    );
  }

  // ── Analytics ─────────────────────────────────────────────────
  Widget _analytics() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('PROGRESS ANALYTICS', style: TextStyle(color: SQ.text, fontSize: 28, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        const Text('Track your performance across all skill areas', style: TextStyle(color: SQ.text2, fontSize: 14)),
        const SizedBox(height: 32),
        Row(children: [
          _statCard('EASY', 45, 100, SQ.green),
          const SizedBox(width: 16),
          _statCard('MEDIUM', 12, 50, SQ.gold),
          const SizedBox(width: 16),
          _statCard('HARD', 3, 20, SQ.red),
        ]),
        const SizedBox(height: 32),
        _heatmap(),
        const SizedBox(height: 32),
        _skillBars(),
      ]),
    );
  }

  Widget _statCard(String label, int val, int max, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: SQ.surface, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SQ.border)),
      child: Column(children: [
        Stack(alignment: Alignment.center, children: [
          SizedBox(width: 80, height: 80, child: CircularProgressIndicator(
              value: val / max, strokeWidth: 7, color: color, backgroundColor: SQ.border)),
          Column(children: [
            Text('$val', style: TextStyle(color: SQ.text, fontSize: 20, fontWeight: FontWeight.w900)),
            Text('/$max', style: TextStyle(color: SQ.text3, fontSize: 11)),
          ]),
        ]),
        const SizedBox(height: 16),
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)),
      ]),
    ));
  }

  Widget _heatmap() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: SQ.surface, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SQ.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('ACTIVITY HEATMAP', style: TextStyle(color: SQ.text, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(height: 16),
        Wrap(spacing: 5, runSpacing: 5,
          children: List.generate(56, (i) => Container(width: 20, height: 20,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(3),
              color: i % 7 == 0 ? SQ.blue : i % 5 == 0 ? SQ.blue.withValues(alpha: 0.5) : i % 3 == 0 ? SQ.blue.withValues(alpha: 0.2) : SQ.surface2)))),
      ]),
    );
  }

  Widget _skillBars() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: SQ.surface, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SQ.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('SKILL LEVELS', style: TextStyle(color: SQ.text, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(height: 20),
        _skillBar('Programming', 0.65, SQ.blue),
        const SizedBox(height: 14),
        _skillBar('Aptitude', 0.40, SQ.gold),
        const SizedBox(height: 14),
        _skillBar('Communication', 0.55, SQ.green),
        const SizedBox(height: 14),
        _skillBar('Code + Speak', 0.20, SQ.purple),
      ]),
    );
  }

  Widget _skillBar(String label, double val, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(label, style: const TextStyle(color: SQ.text2, fontSize: 12, fontWeight: FontWeight.w600)),
        const Spacer(),
        Text('${(val * 100).round()}%', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(value: val, backgroundColor: SQ.border,
          valueColor: AlwaysStoppedAnimation(color), minHeight: 8)),
    ]);
  }

  // ── Achievements Tab ──────────────────────────────────────────
  Widget _achievementsTab() {
    final all = AchievementService.all;
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('ACHIEVEMENTS', style: TextStyle(color: SQ.text, fontSize: 28, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text('${AchievementService.unlocked.length}/${all.length} unlocked',
            style: const TextStyle(color: SQ.text2, fontSize: 14)),
        const SizedBox(height: 32),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260, mainAxisExtent: 130, crossAxisSpacing: 16, mainAxisSpacing: 16),
          itemCount: all.length,
          itemBuilder: (_, i) => _achievementCard(all[i]),
        ),
      ]),
    );
  }

  Widget _achievementCard(Achievement a) {
    final unlocked = AchievementService.isUnlocked(a.id);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: unlocked ? 1.0 : 0.35,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: unlocked ? a.color.withValues(alpha: 0.1) : SQ.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: unlocked ? a.color.withValues(alpha: 0.5) : SQ.border, width: unlocked ? 2 : 1),
          boxShadow: unlocked ? [BoxShadow(color: a.color.withValues(alpha: 0.2), blurRadius: 16)] : [],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(unlocked ? a.emoji : '🔒', style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(a.title, style: TextStyle(color: unlocked ? a.color : SQ.text3,
              fontSize: 13, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(a.description, style: const TextStyle(color: SQ.text3, fontSize: 11), maxLines: 2),
        ]),
      ),
    );
  }
}
