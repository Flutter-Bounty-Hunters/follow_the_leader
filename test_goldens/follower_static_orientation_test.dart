import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

import 'goldens/tools/ftl_gallery_scene.dart';
import 'goldens/tools/test_leader_and_follower_scaffold.dart';

void main() {
  group("Follower > static orientation >", () {
    testGoldenScene("with plenty of space", (tester) async {
      await Gallery(
        "Static Alignment",
        fileName: "follower_static-alignment",
        layout: ftlGridGoldenSceneLayout,
        itemConstraints: const BoxConstraints.tightFor(width: 150, height: 150),
        itemSetup: (tester) async => tester.pump(),
      )
          .itemFromWidget(
            description: "Top/Left",
            widget: buildLeaderAndFollowerWithOffset(followerAlignTopLeft),
          )
          .itemFromWidget(
            description: "Top",
            // Partial pixel alignment problem.
            tolerancePx: 80,
            widget: buildLeaderAndFollowerWithOffset(followerAlignTop),
          )
          .itemFromWidget(
            description: "Top/Right",
            // Partial pixel alignment problem.
            tolerancePx: 80,
            widget: buildLeaderAndFollowerWithOffset(followerAlignTopRight),
          )
          .itemFromWidget(
            description: "Left",
            widget: buildLeaderAndFollowerWithOffset(followerAlignLeft),
          )
          .itemFromWidget(
            description: "Center",
            // Partial pixel alignment problem.
            tolerancePx: 50,
            widget: buildLeaderAndFollowerWithOffset(followerAlignCenter),
          )
          .itemFromWidget(
            description: "Right",
            // Partial pixel alignment problem.
            tolerancePx: 80,
            widget: buildLeaderAndFollowerWithOffset(followerAlignRight),
          )
          .itemFromWidget(
            description: "Bottom/Left",
            widget: buildLeaderAndFollowerWithOffset(followerAlignBottomLeft),
          )
          .itemFromWidget(
            description: "Bottom",
            // Partial pixel alignment problem.
            tolerancePx: 80,
            widget: buildLeaderAndFollowerWithOffset(followerAlignBottom),
          )
          .itemFromWidget(
            description: "Bottom/Right",
            // Partial pixel alignment problem.
            tolerancePx: 80,
            widget: buildLeaderAndFollowerWithOffset(followerAlignBottomRight),
          )
          .run(tester);
    });
  });
}
