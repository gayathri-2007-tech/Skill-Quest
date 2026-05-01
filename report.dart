import 'package:flutter/material.dart';
import '../models/user.dart';
import '../theme.dart';
import '../widgets/app_grid_painter.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/report_widgets.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({Key? key}) : super(key: key);

  int get totalAttempts => UserData.skillAttempts.values.fold(0, (sum, v) => sum + v);
  int get totalCorrect => UserData.skillCorrect.values.fold(0, (sum, v) => sum + v);
  int get totalXP => UserData.xp;

  int get overallAccuracy {
    if (totalAttempts == 0) return 0;
    return ((totalCorrect / totalAttempts) * 100).round();
  }

  List<Map<String, dynamic>> get skillSummaries {
    return UserData.skillXP.keys.map((skill) {
      final xp = UserData.skillXP[skill] ?? 0;
      final attempts = UserData.skillAttempts[skill] ?? 0;
      final correct = UserData.skillCorrect[skill] ?? 0;
      final accuracy = attempts == 0 ? 0 : ((correct / attempts) * 100).round();
      return {
        'skill': skill,
        'xp': xp,
        'attempts': attempts,
        'accuracy': accuracy,
        'level': UserData.skillLevel(skill),
        'trend': UserData.learningTrend(skill),
        'revision': UserData.revisionUrgency(skill),
      };
    }).toList();
  }

  Widget _metricCard(String title, String value, String subtitle, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: SQ.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: SQ.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: SQ.text3, fontSize: 12, letterSpacing: 1.5)),
            SizedBox(height: 12),
            Text(value, style: TextStyle(color: color, fontSize: 30, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(subtitle, style: TextStyle(color: SQ.text2, fontSize: 11, height: 1.4)),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(title, style: TextStyle(color: SQ.blue, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
          Spacer(),
          Container(width: 60, height: 2, decoration: BoxDecoration(color: SQ.border, borderRadius: BorderRadius.circular(4))),
        ],
      ),
    );
  }

  Widget _skillCard(Map<String, dynamic> summary) {
    return Container(
      margin: EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SQ.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SQ.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(summary['skill'], style: TextStyle(color: SQ.text, fontSize: 16, fontWeight: FontWeight.w900)),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: SQ.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(summary['level'], style: TextStyle(color: SQ.blue, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _smallBadge('XP', summary['xp'].toString(), SQ.gold),
              SizedBox(width: 10),
              _smallBadge('ATT', summary['attempts'].toString(), SQ.purple3),
              SizedBox(width: 10),
              _smallBadge('ACC', '${summary['accuracy']}%', SQ.green),
            ],
          ),
          SizedBox(height: 14),
          Text('Trend: ${summary['trend']}', style: TextStyle(color: SQ.text2, fontSize: 12, height: 1.4)),
          SizedBox(height: 6),
          Text('Revision: ${summary['revision']}', style: TextStyle(color: SQ.text2, fontSize: 12, height: 1.4)),
        ],
      ),
    );
  }

  Widget _smallBadge(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: SQ.text3, fontSize: 10, letterSpacing: 1.5)),
            SizedBox(height: 6),
            Text(value, style: TextStyle(color: SQ.text, fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildMistakeList(String skill) {
    final mistakes = UserData.topMistakesForSkill(skill);
    if (mistakes.isEmpty) {
      return Text('No mistakes logged yet for $skill.', style: TextStyle(color: SQ.text2, fontSize: 12));
    }
    return Column(
      children: mistakes.map((item) {
        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: SQ.surface2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: SQ.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['question'], style: TextStyle(color: SQ.text, fontSize: 13, fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: [
                  _tag('Your answer: ${item['yourAnswer'] ?? 'N/A'}', SQ.orange),
                  _tag('Correct: ${item['correctAnswer'] ?? 'N/A'}', SQ.green),
                  _tag('×${item['frequency'] ?? 1}', SQ.purple3),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SQ.bg,
      body: Stack(
        children: [
          CustomPaint(painter: AppGridPainter(), child: SizedBox.expand()),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: SQ.surface2,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: SQ.border),
                          ),
                          child: Icon(Icons.arrow_back, color: SQ.text2, size: 20),
                        ),
                      ),
                      SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PERFORMANCE REPORT', style: TextStyle(color: SQ.blue, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('Your latest learning insights', style: TextStyle(color: SQ.text, fontSize: 18, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          ReportMetricCard(title: 'TOTAL XP', value: '$totalXP', subtitle: 'Accumulated rewards', color: SQ.gold),
                          SizedBox(width: 12),
                          ReportMetricCard(title: 'ACCURACY', value: '${overallAccuracy}%', subtitle: 'Quiz success rate', color: SQ.green),
                        ]),
                        SizedBox(height: 12),
                        Row(children: [
                          ReportMetricCard(title: 'ATTEMPTS', value: '$totalAttempts', subtitle: 'Total quiz questions answered', color: SQ.purple3),
                          SizedBox(width: 12),
                          ReportMetricCard(title: 'SKILLS', value: '${skillSummaries.length}', subtitle: 'Tracked skill areas', color: SQ.blue),
                        ]),
                        SizedBox(height: 24),
                        SectionHeader(title: 'SKILL SUMMARY'),
                        ...skillSummaries.map((summary) => ReportSkillCard(
                              skill: summary['skill'],
                              level: summary['level'],
                              xp: summary['xp'],
                              attempts: summary['attempts'],
                              accuracy: summary['accuracy'],
                            )).toList(),
                        SizedBox(height: 20),
                        SectionHeader(title: 'MISTAKE PATTERNS'),
                        Text('Review your highest-impact errors below. This report highlights recurring gaps and the questions you should revisit first.',
                          style: TextStyle(color: SQ.text2, fontSize: 12, height: 1.5)),
                        SizedBox(height: 14),
                        ...UserData.skillXP.keys.map((skill) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(skill, style: TextStyle(color: SQ.text, fontSize: 14, fontWeight: FontWeight.w700)),
                              SizedBox(height: 10),
                              _buildMistakeList(skill),
                              SizedBox(height: 20),
                            ],
                          );
                        }).toList(),
                        _sectionHeader('REVISION RECOMMENDATIONS'),
                        _recommendationTile('Top skill to revise', UserData.revisionPriority().first, SQ.orange),
                        SizedBox(height: 12),
                        _recommendationTile('Best current temperament', UserData.temperamentLabel('Programming'), SQ.green),
                        SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _recommendationTile(String label, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SQ.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SQ.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Text(value[0], style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold))),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: SQ.text3, fontSize: 11, letterSpacing: 1.5)),
                SizedBox(height: 6),
                Text(value, style: TextStyle(color: SQ.text, fontSize: 14, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

