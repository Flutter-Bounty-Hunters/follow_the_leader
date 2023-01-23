import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:follow_the_leader/follow_the_leader.dart';

void main() {
  group("Leaders", () {
    testWidgets("build in a widget tree", (widgetTester) async {
      final link = LeaderLink();
      await _pumpScaffold(
        widgetTester: widgetTester,
        child: Center(
          child: Leader(
            link: link,
            child: Container(
              width: 25,
              height: 25,
              color: Colors.red,
            ),
          ),
        ),
      );

      // Reaching this point without an error is the success condition.
    });

    testWidgets("build without a child", (widgetTester) async {
      final link = LeaderLink();
      await _pumpScaffold(
        widgetTester: widgetTester,
        child: Center(
          child: Leader(
            link: link,
          ),
        ),
      );

      // Reaching this point without an error is the success condition.
    });
  });

  group("Followers", () {
    testWidgets("build in a widget tree", (widgetTester) async {
      final link = LeaderLink();
      await _pumpScaffold(
        widgetTester: widgetTester,
        child: Stack(
          children: [
            Center(
              child: Leader(
                link: link,
                child: Container(
                  width: 25,
                  height: 25,
                  color: Colors.red,
                ),
              ),
            ),
            Follower.withOffset(
              link: link,
              offset: const Offset(0, -50),
              child: Container(
                width: 50,
                height: 50,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      );

      // Reaching this point without an error is the success condition.
    });

    testWidgets("build without a child", (widgetTester) async {
      final link = LeaderLink();
      await _pumpScaffold(
        widgetTester: widgetTester,
        child: Stack(
          children: [
            Center(
              child: Leader(
                link: link,
              ),
            ),
            Follower.withOffset(
              link: link,
              offset: const Offset(0, -50),
            ),
          ],
        ),
      );

      // Reaching this point without an error is the success condition.
    });
  });
}

Future<void> _pumpScaffold({
  required WidgetTester widgetTester,
  required Widget child,
}) async {
  await widgetTester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: child,
      ),
    ),
  );
}
