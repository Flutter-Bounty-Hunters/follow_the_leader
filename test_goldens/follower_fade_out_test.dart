import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';
import 'package:follow_the_leader/follow_the_leader.dart';

import 'goldens/tools/test_leader_and_follower_scaffold.dart';

void main() {
  group("Follower >", () {
    testGoldenScene("fades out beyond boundary", (tester) async {
      final boundaryType = _fadeOutBoundaryVariant.currentValue!;
      final boundaryName = boundaryType.name;

      final link = LeaderLink();
      final slideAnimation = AnimationController(
        vsync: tester,
        duration: const Duration(milliseconds: 300),
      );

      await Timeline(
        "Follower Fades Out When Leader Exceeds Boundary ($boundaryName)",
        fileName: "follower_fade-out_beyond-$boundaryName",
        windowSize: const Size(150, 150),
        itemScaffold: minimalTimelineItemScaffold,
        layout: const AnimationTimelineSceneLayout(
          rowBreakPolicy: AnimationTimelineRowBreak.beforeItemDescription("Start"),
        ),
      ) //
          .setupWithWidget(_buildScaffold(
            link,
            slideAnimation,
            maxLeaderAlignment: boundaryType.maxLeaderAlignment,
            boundary: boundaryType.boundary,
          ))
          .takePhoto("Start")
          .modifyScene((tester, _) async {
            slideAnimation.forward();
          }) //
          .takePhotos(13, const Duration(milliseconds: 50))
          .takePhoto("End")
          .modifyScene((tester, _) async {
            slideAnimation.reverse();
          }) //
          .takePhoto("Start")
          .takePhotos(7, const Duration(milliseconds: 50))
          .takePhoto("End")
          .run(tester);
    }, variant: _fadeOutBoundaryVariant);

    testGoldenScene("does not fade with partial overlap", (tester) async {
      final link = LeaderLink();
      final slideAnimation = AnimationController(
        vsync: tester,
        duration: const Duration(milliseconds: 300),
      );

      await Timeline(
        "Follower Does Not Fade When Leader Has Partial Overlap",
        fileName: "follower_fade-out_does-not-fade-with-partial-overlap",
        windowSize: const Size(150, 150),
        itemScaffold: minimalTimelineItemScaffold,
        layout: const AnimationTimelineSceneLayout(),
      ) //
          .setupWithWidget(_buildScaffold(
            link,
            slideAnimation,
            maxLeaderAlignment: const Alignment(0.37, 0),
            boundary: WidgetFollowerBoundary(boundaryKey: GlobalKey()),
          ))
          .takePhoto("Start")
          .modifyScene((tester, _) async {
            slideAnimation.forward();
          }) //
          .takePhotos(10, const Duration(milliseconds: 50))
          .takePhoto("End")
          .run(tester);
    });
  });
}

Widget _buildScaffold(
  LeaderLink link,
  AnimationController slideAnimation, {
  Alignment maxLeaderAlignment = const Alignment(1.15, 0),
  FollowerBoundary boundary = const ScreenFollowerBoundary(),
}) {
  return AnimatedBuilder(
    animation: slideAnimation,
    builder: (context, child) {
      return buildLeaderAndFollowerWithOffset(
        followerAlignBottom,
        link: link,
        leaderAlignment: Alignment.lerp(Alignment.center, maxLeaderAlignment, slideAnimation.value)!,
        boundary: boundary,
        fadeOutBeyondBoundary: true,
      );
    },
  );
}

final _fadeOutBoundaryVariant = ValueVariant(_FadeOutBoundaryVariant.values.toSet());

enum _FadeOutBoundaryVariant {
  screen,
  widget;

  String get name => switch (this) {
        _FadeOutBoundaryVariant.screen => "screen",
        _FadeOutBoundaryVariant.widget => "widget",
      };

  FollowerBoundary get boundary => switch (this) {
        _FadeOutBoundaryVariant.screen => const ScreenFollowerBoundary(),
        _FadeOutBoundaryVariant.widget => WidgetFollowerBoundary(boundaryKey: GlobalKey(debugLabel: "widget-boundary")),
      };

  Alignment get maxLeaderAlignment => switch (this) {
        _FadeOutBoundaryVariant.screen => const Alignment(1.15, 0),
        _FadeOutBoundaryVariant.widget => const Alignment(0.5, 0),
      };
}
