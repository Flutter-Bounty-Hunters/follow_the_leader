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

    testWidgets("build when the Leader comes and goes", (widgetTester) async {
      final showLeader = ValueNotifier<bool>(false);
      final link = LeaderLink();

      await _pumpScaffold(
        widgetTester: widgetTester,
        child: Stack(
          children: [
            Center(
              child: ValueListenableBuilder(
                  valueListenable: showLeader,
                  builder: (context, value, child) {
                    // Don't build the Leader. Make the Follower and orphan.
                    if (!showLeader.value) {
                      return const SizedBox();
                    }

                    // Build the Leader.
                    return Leader(
                      link: link,
                    );
                  }),
            ),
            Follower.withOffset(
              link: link,
              offset: const Offset(0, -50),
            ),
          ],
        ),
      );

      // Switch the value to show the Leader and rebuild.
      showLeader.value = true;
      await widgetTester.pumpAndSettle();

      // Switch the value to get rid of the Leader and rebuild.
      showLeader.value = false;
      await widgetTester.pumpAndSettle();

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
