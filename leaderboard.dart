import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';
import 'login.dart' show LoginPage;

class LeaderboardPage extends StatelessWidget {
  final bool showBackButton;
  const LeaderboardPage({Key? key, this.showBackButton = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          if (showBackButton)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              decoration: BoxDecoration(
                color: SQ.bg2,
                border: Border(bottom: BorderSide(color: SQ.border, width: 1)),
              ),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back_ios_new_rounded, color: SQ.text2, size: 20),
                ),
                SizedBox(width: 24),
                Text("WORLD LEAGUE",
                    style: TextStyle(
                        color: SQ.text, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ]),
            ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("scores")
                  .orderBy("score", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      CircularProgressIndicator(color: SQ.blue, strokeWidth: 4),
                      SizedBox(height: 16),
                      Text("FETCHING SCORES...",
                          style: TextStyle(
                              color: SQ.text3, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    ]),
                  );
                }

                var docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.hub_rounded, size: 60, color: SQ.border2),
                      SizedBox(height: 24),
                      Text("NO SCORES YET",
                          style: TextStyle(
                              color: SQ.text3, fontSize: 12, letterSpacing: 3, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text("Complete a quiz to appear here",
                          style: TextStyle(color: SQ.text3, fontSize: 12)),
                    ]),
                  );
                }

                return SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top 3 podium
                      if (docs.length >= 3) ...[
                        Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(child: _podiumCard(docs[1], 2, SQ.purple3)),
                              SizedBox(width: 12),
                              Expanded(child: _podiumCard(docs[0], 1, SQ.gold)),
                              SizedBox(width: 12),
                              Expanded(child: _podiumCard(docs[2], 3, SQ.green)),
                            ],
                          ),
                        ),
                      ],

                      // Section header
                      Row(children: [
                        Container(
                          width: 3, height: 14,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [SQ.blue, SQ.purple],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text("TOP PERFORMERS",
                            style: TextStyle(
                                color: SQ.text2, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold)),
                      ]),
                      SizedBox(height: 12),

                      ...List.generate(docs.length, (i) => _leaderRow(docs[i], i)),
                      SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _podiumCard(doc, int pos, Color color) {
    String rank = pos == 1 ? "GOLD" : pos == 2 ? "SILVER" : "BRONZE";
    double h = pos == 1 ? 160 : 130;
    return Container(
      height: h,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SQ.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 20, offset: Offset(0, 8))
        ],
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text("#$pos",
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
        SizedBox(height: 10),
        Text(doc["name"].toString().toUpperCase(),
            style: TextStyle(color: SQ.text, fontSize: 13, fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        SizedBox(height: 4),
        Text("${doc["score"]} XP",
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        SizedBox(height: 6),
        Text(rank,
            style: TextStyle(color: SQ.text3, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2)),
      ]),
    );
  }

  Widget _leaderRow(doc, int i) {
    bool isTop3 = i < 3;
    Color color = i == 0 ? SQ.gold : i == 1 ? SQ.purple3 : i == 2 ? SQ.green : SQ.text3;

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SQ.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isTop3 ? color.withValues(alpha: 0.3) : SQ.border, width: 1),
      ),
      child: Row(children: [
        SizedBox(
          width: 32,
          child: Text("${i + 1}",
              textAlign: TextAlign.center,
              style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900)),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(doc["name"].toString().toUpperCase(),
                style: TextStyle(color: SQ.text, fontSize: 14, fontWeight: FontWeight.w800)),
            Text("Score: ${doc["skill"] ?? "General"}",
                style: TextStyle(color: SQ.text3, fontSize: 10, letterSpacing: 1)),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text("${doc["score"]}",
              style: TextStyle(color: SQ.blue, fontSize: 18, fontWeight: FontWeight.w900)),
          Text("XP",
              style: TextStyle(color: SQ.text3, fontSize: 9, fontWeight: FontWeight.bold)),
        ]),
      ]),
    );
  }
}
