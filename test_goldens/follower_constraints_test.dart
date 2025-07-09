import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';
import 'package:follow_the_leader/follow_the_leader.dart';
import 'package:super_keyboard/super_keyboard.dart';
import 'package:super_keyboard/super_keyboard_test.dart';

import 'goldens/tools/ftl_gallery_scene.dart';
import 'goldens/tools/test_leader_and_follower_scaffold.dart';

void main() {
  group("Follower > boundary constraints >", () {
    testGoldenScene("screen", (tester) async {
      await Gallery(
        "Boundary Constraints (screen)",
        fileName: "follower_boundary-constraints_screen",
        layout: ftlGridGoldenSceneLayout,
        itemConstraints: const BoxConstraints.tightFor(width: 300, height: 300),
        itemSetup: (tester) async => tester.pump(),
      )
          .itemFromWidget(
            description: "Top/Left",
            widget: _buildLeaderAndFollower(const Alignment(-1.5, -1.5), followerAlignTopLeft),
          )
          .itemFromWidget(
            description: "Top",
            widget: _buildLeaderAndFollower(const Alignment(0, -1.5), followerAlignTop),
          )
          .itemFromWidget(
            description: "Top/Right",
            widget: _buildLeaderAndFollower(const Alignment(1.5, -1.5), followerAlignTopRight),
          )
          .itemFromWidget(
            description: "Left",
            widget: _buildLeaderAndFollower(const Alignment(-1.5, 0), followerAlignLeft),
          )
          .itemFromWidget(
            description: "Right",
            widget: _buildLeaderAndFollower(const Alignment(1.5, 0), followerAlignRight),
          )
          .itemFromWidget(
            description: "Bottom/Left",
            widget: _buildLeaderAndFollower(const Alignment(-1.5, 1.5), followerAlignBottomLeft),
          )
          .itemFromWidget(
            description: "Bottom/Right",
            widget: _buildLeaderAndFollower(const Alignment(1.5, 1.5), followerAlignBottomRight),
          )
          .itemFromWidget(
            description: "Bottom",
            widget: _buildLeaderAndFollower(const Alignment(0, 1.5), followerAlignBottom),
          )
          .run(tester);
    });

    testGoldenSceneOnIOS("software keyboard", (tester) async {
      await Gallery(
        "Boundary Constraints (keyboard)",
        fileName: "follower_boundary-constraints_keyboard",
        layout: ftlGridGoldenSceneLayout,
        // Item is the size of an iPhone 16 (DIP).
        itemConstraints: const BoxConstraints.tightFor(width: 393, height: 852),
        itemSetup: (tester) async => tester.pump(),
      )
          .itemFromWidget(
            description: "Unconstrained",
            widget: SoftwareKeyboardHeightSimulator(
              tester: tester,
              initialKeyboardState: KeyboardState.open,
              renderSimulatedKeyboard: true,
              child: const ColoredBox(color: Color(0xff020817)),
              // child: _buildLeaderAndFollower(
              //   Alignment.center,
              //   followerAlignBottom,
              //   leaderSize: const Size(25, 25),
              //   followerSize: const Size(50, 50),
              //   boundary: const KeyboardFollowerBoundary(),
              // ),
            ),
          )
          .itemFromWidget(
            description: "Near Keyboard",
            widget: SoftwareKeyboardHeightSimulator(
              tester: tester,
              initialKeyboardState: KeyboardState.open,
              renderSimulatedKeyboard: true,
              child: const ColoredBox(color: Color(0xff020817)),
              // child: _buildLeaderAndFollower(
              //   const Alignment(0, 0.15),
              //   followerAlignBottom,
              //   leaderSize: const Size(25, 25),
              //   followerSize: const Size(50, 50),
              //   boundary: const KeyboardFollowerBoundary(),
              // ),
            ),
          )
          .itemFromWidget(
            description: "Behind Keyboard",
            widget: SoftwareKeyboardHeightSimulator(
              tester: tester,
              initialKeyboardState: KeyboardState.open,
              renderSimulatedKeyboard: true,
              child: const ColoredBox(color: Color(0xff020817)),
              // child: _buildLeaderAndFollower(
              //   const Alignment(0, 0.5),
              //   followerAlignBottom,
              //   leaderSize: const Size(25, 25),
              //   followerSize: const Size(50, 50),
              //   boundary: const KeyboardFollowerBoundary(),
              // ),
            ),
          )
          .run(tester);
    });

    testGoldenScene("widget bounds", (tester) async {
      final widgetBoundary = WidgetFollowerBoundary(
        boundaryKey: GlobalKey(debugLabel: "widget-boundary"),
      );

      await Gallery(
        "Boundary Constraints (widget)",
        fileName: "follower_boundary-constraints_widget",
        layout: ftlGridGoldenSceneLayout,
        itemConstraints: const BoxConstraints.tightFor(width: 300, height: 300),
        itemSetup: (tester) async => tester.pump(),
      )
          .itemFromWidget(
            description: "Top/Left",
            widget: _buildLeaderAndFollower(
              const Alignment(-1, -1),
              followerAlignBottomRight,
              boundary: widgetBoundary,
            ),
          )
          .itemFromWidget(
            description: "Top",
            widget: _buildLeaderAndFollower(
              const Alignment(0, -1),
              followerAlignBottom,
              boundary: widgetBoundary,
            ),
          )
          .itemFromWidget(
            description: "Top/Right",
            widget: _buildLeaderAndFollower(
              const Alignment(1, -1),
              followerAlignBottomLeft,
              boundary: widgetBoundary,
            ),
          )
          .itemFromWidget(
            description: "Left",
            widget: _buildLeaderAndFollower(
              const Alignment(-1, 0),
              followerAlignRight,
              boundary: widgetBoundary,
            ),
          )
          .itemFromWidget(
            description: "Right",
            widget: _buildLeaderAndFollower(
              const Alignment(1, 0),
              followerAlignLeft,
              boundary: widgetBoundary,
            ),
          )
          .itemFromWidget(
            description: "Bottom/Left",
            widget: _buildLeaderAndFollower(
              const Alignment(-1, 1),
              followerAlignTopRight,
              boundary: widgetBoundary,
            ),
          )
          .itemFromWidget(
            description: "Bottom",
            widget: _buildLeaderAndFollower(
              const Alignment(0, 1),
              followerAlignTop,
              boundary: widgetBoundary,
            ),
          )
          .itemFromWidget(
            description: "Bottom/Right",
            widget: _buildLeaderAndFollower(
              const Alignment(1, 1),
              followerAlignTopLeft,
              boundary: widgetBoundary,
            ),
          )
          .run(tester);
    });
  });
}

Widget _buildLeaderAndFollower(
  Alignment leaderAlignment,
  FollowerAlignment followerAlignment, {
  Size leaderSize = const Size(10, 10),
  Size followerSize = const Size(20, 20),
  FollowerBoundary boundary = const ScreenFollowerBoundary(),
}) {
  return buildLeaderAndFollowerWithOffset(
    leaderAlignment: leaderAlignment,
    leaderSize: leaderSize,
    followerAlignment,
    followerSize: followerSize,
    boundary: boundary,
  );
}
