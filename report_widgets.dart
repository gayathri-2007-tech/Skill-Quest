import 'package:flutter/material.dart';
import '../theme.dart';

class ReportMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const ReportMetricCard({Key? key, required this.title, required this.value, required this.subtitle, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}

class ReportSkillCard extends StatelessWidget {
  final String skill;
  final String level;
  final int xp;
  final int attempts;
  final int accuracy;

  const ReportSkillCard({Key? key, required this.skill, required this.level, required this.xp, required this.attempts, required this.accuracy}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              Text(skill, style: TextStyle(color: SQ.text, fontSize: 16, fontWeight: FontWeight.w900)),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: SQ.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(level, style: TextStyle(color: SQ.blue, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              ReportTag(label: 'XP', value: xp.toString(), color: SQ.gold),
              SizedBox(width: 10),
              ReportTag(label: 'ATT', value: attempts.toString(), color: SQ.purple3),
              SizedBox(width: 10),
              ReportTag(label: 'ACC', value: '$accuracy%', color: SQ.green),
            ],
          ),
        ],
      ),
    );
  }
}

class ReportTag extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const ReportTag({Key? key, required this.label, required this.value, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}
