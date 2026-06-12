import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:follow_the_leader/follow_the_leader.dart';

void main() {
  group("Followers", () {
    // Regression test for a crash: "Null check operator used on a null value"
    // in FollowerLayer.addToScene.
    //
    // SnapshotWidget.toImageSync - used by Flutter's ZoomPageTransition on
    // Android, among others - rasterizes a subtree by painting it into a
    // temporary layer tree that's never attached to a PipelineOwner.
    // Re-parenting the retained FollowerLayer into that tree calls detach(),
    // which nulls _leaderHandle, and addToScene dereferenced the handle
    // unconditionally. In an app, this crashes any route that hosts a
    // Follower when it's pushed or popped with a snapshotting transition.
    testWidgets("survive SnapshotWidget rasterization while detached", (widgetTester) async {
      final link = LeaderLink();
      final snapshotController = SnapshotController(allowSnapshotting: false);

      await widgetTester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SnapshotWidget(
              controller: snapshotController,
              child: Stack(
                children: [
                  Positioned(
                    top: 100,
                    left: 100,
                    child: Leader(
                      link: link,
                      child: const SizedBox(width: 20, height: 20),
                    ),
                  ),
                  Follower.withOffset(
                    link: link,
                    offset: const Offset(0, -50),
                    showWhenUnlinked: false,
                    child: const SizedBox(width: 50, height: 50),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Pump a settled frame so the Follower links to the Leader and paints
      // its FollowerLayer. On the very first frame the follower defers
      // painting (the leader's layer isn't attached yet), so enabling
      // snapshotting immediately would rasterize a tree with no
      // FollowerLayer in it and the test would pass vacuously.
      await widgetTester.pump();

      // Rasterize the subtree the same way ZoomPageTransition does
      // mid-transition: the retained Leader/Follower layers get re-parented
      // into the snapshot's unattached layer tree, which detaches them.
      snapshotController.allowSnapshotting = true;
      await widgetTester.pump();

      expect(widgetTester.takeException(), isNull);
    });
  });
}
