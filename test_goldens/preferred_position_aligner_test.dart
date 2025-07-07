import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';
import 'package:follow_the_leader/follow_the_leader.dart';

import 'goldens/tools/ftl_gallery_scene.dart';
import 'goldens/tools/test_leader_and_follower_scaffold.dart';

void main() {
  group("Follower > preferred position aligner >", () {
    testGoldenScene("happy path", (tester) async {
      await Gallery(
        "Preferred Position Aligner - Happy Path",
        fileName: "follower_preferred-position-aligner_happy-path",
        layout: ftlGridGoldenSceneLayout,
        itemConstraints: const BoxConstraints.tightFor(width: 150, height: 150),
        itemSetup: (tester) async => tester.pump(),
      )
          .itemFromWidget(
            description: "Left",
            widget: _buildLeaderAndFollower(_left),
          )
          .itemFromWidget(
            description: "Top",
            widget: _buildLeaderAndFollower(_top),
          )
          .itemFromWidget(
            description: "Right",
            widget: _buildLeaderAndFollower(_right),
          )
          .itemFromWidget(
            description: "Bottom",
            widget: _buildLeaderAndFollower(_bottom),
          )
          .run(tester);
    });

    testGoldenScene("pushed on the cross-axis", (tester) async {
      await Gallery(
        "Preferred Position Aligner - Pushed on Cross-Axis",
        fileName: "follower_preferred-position-aligner_pushed-on-cross-axis",
        layout: ftlGridGoldenSceneLayout,
        itemConstraints: const BoxConstraints.tightFor(width: 150, height: 150),
        itemSetup: (tester) async => tester.pump(),
      )
          .itemFromWidget(
            description: "Left (Aligned Bottom)",
            widget: _buildLeaderAndFollower(
              const _PreferredPosition(
                side: PreferredPrimaryPosition.left,
                leaderCrossAxisAnchor: Alignment.bottomLeft,
                followerCrossAxisAnchor: Alignment.bottomRight,
              ),
              followerSize: const Size(20, 100),
            ),
          )
          .itemFromWidget(
            description: "Top (Aligned Right)",
            // Partial pixel alignment problem.
            tolerancePx: 50,
            widget: _buildLeaderAndFollower(
              const _PreferredPosition(
                side: PreferredPrimaryPosition.top,
                leaderCrossAxisAnchor: Alignment.topRight,
                followerCrossAxisAnchor: Alignment.bottomRight,
              ),
              followerSize: const Size(100, 20),
            ),
          )
          .itemFromWidget(
            description: "Right (Aligned Top)",
            // Partial pixel alignment problem.
            tolerancePx: 250,

            widget: _buildLeaderAndFollower(
              const _PreferredPosition(
                side: PreferredPrimaryPosition.right,
                leaderCrossAxisAnchor: Alignment.topRight,
                followerCrossAxisAnchor: Alignment.topLeft,
              ),
              followerSize: const Size(20, 100),
            ),
          )
          .itemFromWidget(
            description: "Bottom (Aligned Left)",
            widget: _buildLeaderAndFollower(
              const _PreferredPosition(
                side: PreferredPrimaryPosition.bottom,
                leaderCrossAxisAnchor: Alignment.bottomLeft,
                followerCrossAxisAnchor: Alignment.topLeft,
              ),
              followerSize: const Size(100, 20),
            ),
          )
          .run(tester);
    });

    testGoldenScene("forced to flip sides", (tester) async {
      await Gallery(
        "Preferred Position Aligner - Forced to Flip",
        fileName: "follower_preferred-position-aligner_forced-to-flip",
        layout: ftlGridGoldenSceneLayout,
        itemConstraints: const BoxConstraints.tightFor(width: 150, height: 150),
        itemSetup: (tester) async => tester.pump(),
      )
          .itemFromWidget(
            description: "Left (Inverted)",
            widget: _buildLeaderAndFollower(_left, leaderAlignment: const Alignment(-0.5, 0)),
          )
          .itemFromWidget(
            description: "Top (Inverted)",
            // Partial pixel alignment problem.
            tolerancePx: 100,
            widget: _buildLeaderAndFollower(_top, leaderAlignment: const Alignment(0, -0.5)),
          )
          .itemFromWidget(
            description: "Right (Inverted)",
            // Partial pixel alignment problem.
            tolerancePx: 100,
            widget: _buildLeaderAndFollower(_right, leaderAlignment: const Alignment(0.5, 0)),
          )
          .itemFromWidget(
            description: "Bottom (Inverted)",
            widget: _buildLeaderAndFollower(_bottom, leaderAlignment: const Alignment(0, 0.5)),
          )
          .run(tester);
    });

    testGoldenScene("not enough space on either side", (tester) async {
      const leaderSize = Size(100, 100);

      await Gallery(
        "Preferred Position Aligner - Not Enough Space on Either Side",
        fileName: "follower_preferred-position-aligner_not-enough-space-on-either-size",
        layout: ftlGridGoldenSceneLayout,
        itemConstraints: const BoxConstraints.tightFor(width: 150, height: 150),
        itemSetup: (tester) async => tester.pump(),
      )
          .itemFromWidget(
            description: "Left (Constrained)",
            widget: _buildLeaderAndFollower(_left, leaderSize: leaderSize),
          )
          .itemFromWidget(
            description: "Top (Constrained)",
            // Slight mismatch due to partial pixel positioning at center.
            tolerancePx: 250,
            widget: _buildLeaderAndFollower(_top, leaderSize: leaderSize),
          )
          .itemFromWidget(
            description: "Right (Constrained)",
            // Slight mismatch due to partial pixel positioning at center.
            tolerancePx: 250,
            widget: _buildLeaderAndFollower(_right, leaderSize: leaderSize),
          )
          .itemFromWidget(
            description: "Bottom (Constrained)",
            widget: _buildLeaderAndFollower(_bottom, leaderSize: leaderSize),
          )
          .run(tester);
    });
  });
}

Widget _buildLeaderAndFollower(
  _PreferredPosition position, {
  Size leaderSize = const Size(10, 10),
  Alignment leaderAlignment = Alignment.center,
  Size followerSize = const Size(20, 20),
}) {
  return buildLeaderAndFollowerWithAligner(
    leaderSize: leaderSize,
    leaderAlignment: leaderAlignment,
    followerSize: followerSize,
    aligner: PreferredPositionAligner(
      followerPosition: position.side,
      leaderCrossAxisAnchor: position.leaderCrossAxisAnchor,
      followerCrossAxisAnchor: position.followerCrossAxisAnchor,
    ),
  );
}

const _left = _PreferredPosition(
  side: PreferredPrimaryPosition.left,
  leaderCrossAxisAnchor: Alignment.centerLeft,
  followerCrossAxisAnchor: Alignment.centerRight,
);

const _top = _PreferredPosition(
  side: PreferredPrimaryPosition.top,
  leaderCrossAxisAnchor: Alignment.topCenter,
  followerCrossAxisAnchor: Alignment.bottomCenter,
);

const _right = _PreferredPosition(
  side: PreferredPrimaryPosition.right,
  leaderCrossAxisAnchor: Alignment.centerRight,
  followerCrossAxisAnchor: Alignment.centerLeft,
);

const _bottom = _PreferredPosition(
  side: PreferredPrimaryPosition.bottom,
  leaderCrossAxisAnchor: Alignment.bottomCenter,
  followerCrossAxisAnchor: Alignment.topCenter,
);

class _PreferredPosition {
  const _PreferredPosition({
    required this.side,
    required this.leaderCrossAxisAnchor,
    required this.followerCrossAxisAnchor,
  });

  final PreferredPrimaryPosition side;
  final Alignment leaderCrossAxisAnchor;
  final Alignment followerCrossAxisAnchor;
}
