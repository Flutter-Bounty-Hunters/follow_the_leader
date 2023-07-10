import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:follow_the_leader/src/follower.dart';
import 'package:follow_the_leader/src/leader_link.dart';
import 'package:follow_the_leader/src/leader.dart';

void main() {
  group('follow the leader', () {
    testWidgets('hit tests followers', (tester) async {
      tester.view
        ..physicalSize = const Size(400, 400)
        ..devicePixelRatio = 1.0;

      bool tapped = false;
      final _link = LeaderLink();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(builder: (context) {
              return Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Leader(
                      link: _link,
                      child: Container(color: Colors.red, width: 50, height: 50),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Follower.withOffset(
                      link: _link,
                      boundary: ScreenFollowerBoundary(
                        screenSize: MediaQuery.of(context).size,
                        devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
                      ),
                      leaderAnchor: Alignment.bottomRight,
                      followerAnchor: Alignment.topLeft,
                      offset: const Offset(50, 50),
                      child: GestureDetector(
                        onTap: () {
                          tapped = true;
                        },
                        child: Container(
                          color: Colors.blue,
                          width: 50,
                          height: 50,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap at the follower position
      // Leader width + offset + half of the follower width.
      await tester.tapAt(const Offset(125, 125));
      await tester.pump();

      // This golden matcher is available for easy verification if this test fails.
      // await expectLater(find.byType(MaterialApp), matchesGoldenFile("deleteme.png"));

      // Ensure the callback was called.
      expect(tapped, isTrue);
    });
  });
}
