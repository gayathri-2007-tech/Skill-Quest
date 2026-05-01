import 'package:flutter/material.dart';
import '../theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [SQ.blue, SQ.purple],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: SQ.text2,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}

class InfoBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const InfoBadge({Key? key, required this.label, required this.value, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: SQ.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SQ.border),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: SQ.text3, fontSize: 9, letterSpacing: 2)),
            SizedBox(height: 6),
            Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

class SmallBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const SmallBadge({Key? key, required this.label, required this.value, required this.color}) : super(key: key);

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
