import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:follow_the_leader/follow_the_leader.dart';

void main() {
  group("Followers", () {
    testWidgets("position content statically", (widgetTester) async {
      await _pumpBoundedFollowerScenario(
        widgetTester,
        leaderAlignment: Alignment.center,
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile("goldens/follower_static_initial-placement_in-bounds_center.png"),
      );
    });

    testWidgets("restrict to boundary", (widgetTester) async {
      // Variants tests four corners of alignment.
      await _pumpBoundedFollowerScenario(
        widgetTester,
        leaderAlignment: _CornerAlignmentBeyondBoundaryVariant.currentAlignment!,
        constrainFollowerToBoundary: true,
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
            "goldens/follower_restricts-to-boundary_${_CornerAlignmentBeyondBoundaryVariant.currentDescription!}.png"),
      );
    }, variant: const _CornerAlignmentBeyondBoundaryVariant());

    testWidgets("fade out when they are entirely outside of boundary with a fade policy", (widgetTester) async {
      // Variants tests four corners of alignment.
      await _pumpBoundedFollowerScenario(
        widgetTester,
        leaderAlignment: _CornerAlignmentBeyondBoundaryVariant.currentAlignment!,
        fadeOutBeyondBoundary: true,
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
            "goldens/follower_fade-when-out-of-bounds_${_CornerAlignmentBeyondBoundaryVariant.currentDescription!}.png"),
      );
    }, variant: const _CornerAlignmentBeyondBoundaryVariant());

    testWidgets("don't fade when they partially overlap boundary with a fade policy", (widgetTester) async {
      // Variants tests four corners of alignment.
      await _pumpBoundedFollowerScenario(
        widgetTester,
        leaderAlignment: _CornerAlignmentPartialOverlapVariant.currentAlignment!,
        fadeOutBeyondBoundary: true,
      );

      // Wait for the follower to animate to opaque. The very first frame probably didn't
      // have the Leader connected yet. The second frame made the connection. Which means the
      // Follower starts invisible, then decides to become visible, and this requires an
      // animation to complete.
      await widgetTester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
            "goldens/follower_static_no-fade-when-partial-overlap_${_CornerAlignmentPartialOverlapVariant.currentDescription!}.png"),
      );
    }, variant: const _CornerAlignmentPartialOverlapVariant());
  });
}

/// Pumps a widget tree with a follower boundary at the center of the screen,
/// places the the [Leader] on the screen according to [leaderAlignment], and
/// then lets the [Follower] place itself, as desired.
///
/// This scenario is used to place the [Leader] inside and outside the boundary
/// at various locations to ensure the [Follower] ends up where it's supposed to.
Future<void> _pumpBoundedFollowerScenario(
  WidgetTester widgetTester, {
  required leaderAlignment,
  LeaderLink? leaderLink,
  bool fadeOutBeyondBoundary = false,
  bool constrainFollowerToBoundary = false,
}) async {
  widgetTester.view
    ..devicePixelRatio = 1.0
    ..physicalSize = const Size(500, 500);

  final link = leaderLink ?? LeaderLink();
  final boundsKey = GlobalKey();
  final widgetBoundary = WidgetFollowerBoundary(
    boundaryKey: boundsKey,
  );

  await _pumpScaffold(
    widgetTester: widgetTester,
    child: Stack(
      children: [
        Align(
          alignment: leaderAlignment,
          child: Leader(
            link: link,
            child: Container(
              width: 25,
              height: 25,
              color: Colors.red,
            ),
          ),
        ),
        Center(
          // The widget that represents the bounds where the follower
          // is allowed to appear.
          child: Container(
            key: boundsKey,
            width: 300,
            height: 300,
            color: Colors.green.withValues(alpha: 0.2),
          ),
        ),
        FollowerFadeOutBeyondBoundary(
          link: link,
          boundary: widgetBoundary,
          enabled: fadeOutBeyondBoundary,
          child: Follower.withOffset(
            link: link,
            offset: const Offset(0, -50),
            boundary: constrainFollowerToBoundary ? widgetBoundary : null,
            child: Container(
              width: 50,
              height: 50,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    ),
  );

  // Pump one more frame so that the Follower can link to the Leader.
  await widgetTester.pump();
}

class _CornerAlignmentBeyondBoundaryVariant extends TestVariant<Alignment> {
  static Alignment? get currentAlignment => _currentAlignment;
  static Alignment? _currentAlignment;

  static String? get currentDescription => _currentDescription;
  static String? _currentDescription;

  const _CornerAlignmentBeyondBoundaryVariant();

  @override
  Iterable<Alignment> get values => const [
        Alignment(-0.9, -0.9),
        Alignment(0.9, -0.9),
        Alignment(0.9, 0.9),
        Alignment(-0.9, 0.9),
      ];

  @override
  String describeValue(Alignment value) {
    final horizontal = value.x < 0.0 ? "left" : "right";
    final vertical = value.y < 0.0 ? "top" : "bottom";
    return "$vertical-$horizontal";
  }

  @override
  Future<Object?> setUp(Alignment value) async {
    _currentAlignment = value;
    _currentDescription = describeValue(value);
    return null;
  }

  @override
  Future<void> tearDown(Alignment value, covariant Object? memento) async {
    _currentAlignment = null;
    _currentDescription = null;
  }
}

/// Positions leaders so that they sit partially inside, and outside of the
/// boundary region, at every corner.
class _CornerAlignmentPartialOverlapVariant extends TestVariant<Alignment> {
  static Alignment? get currentAlignment => _currentAlignment;
  static Alignment? _currentAlignment;

  static String? get currentDescription => _currentDescription;
  static String? _currentDescription;

  const _CornerAlignmentPartialOverlapVariant();

  @override
  Iterable<Alignment> get values => const [
        Alignment(-0.6, -0.6),
        Alignment(0.6, -0.6),
        Alignment(0.6, 0.6),
        Alignment(-0.6, 0.6),
      ];

  @override
  String describeValue(Alignment value) {
    final horizontal = value.x < 0.0 ? "left" : "right";
    final vertical = value.y < 0.0 ? "top" : "bottom";
    return "$vertical-$horizontal";
  }

  @override
  Future<Object?> setUp(Alignment value) async {
    _currentAlignment = value;
    _currentDescription = describeValue(value);
    return null;
  }

  @override
  Future<void> tearDown(Alignment value, covariant Object? memento) async {
    _currentAlignment = null;
    _currentDescription = null;
  }
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
      debugShowCheckedModeBanner: false,
    ),
  );
}
