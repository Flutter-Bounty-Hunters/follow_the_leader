import 'package:example/infrastructure/ball_sandbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:follow_the_leader/follow_the_leader.dart';

import 'ios_popover/ios_popover_menu.dart';

class BouncingBallDemo extends StatefulWidget {
  const BouncingBallDemo({super.key});

  @override
  State<BouncingBallDemo> createState() => _BouncingBallDemoState();
}

class _BouncingBallDemoState extends State<BouncingBallDemo> with SingleTickerProviderStateMixin {
  static const double _menuWidth = 100;
  static const double _ballRadius = 50.0;

  final GlobalKey _screenBoundsKey = GlobalKey();
  final GlobalKey _leaderKey = GlobalKey();
  final GlobalKey _followerKey = GlobalKey();

  /// Initial velocity of the leader.
  final Offset _initialVelocity = const Offset(300, 300);

  /// Current velocity of the leader.
  ///
  /// The velocity is updated whenever the leader hits an edge of the screen.
  late Offset _velocity;

  /// Last [Duration] given by the ticker.
  Duration? _lastElapsed;

  /// Current offset of the leader.
  ///
  /// The offset changes at every tick.
  Offset _ballOffset = const Offset(0, 200);

  /// The global offset where the menu's arrow should point.
  Offset _globalMenuFocalPoint = Offset.zero;

  /// The most recent [FollowerAlignment], which is cached so that we only
  /// change the `Follower`'s relative position if absolutely necessary.
  FollowerAlignment _previousFollowerAlignment = const FollowerAlignment(
    leaderAnchor: Alignment.centerRight,
    followerAnchor: Alignment.centerLeft,
    followerOffset: Offset(20, 0),
  );

  late Ticker ticker;

  @override
  void initState() {
    super.initState();
    ticker = createTicker(_onTick)..start();
    _velocity = _initialVelocity;
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (_lastElapsed == null) {
      _lastElapsed = elapsed;
      return;
    }

    final dt = elapsed.inMilliseconds - _lastElapsed!.inMilliseconds;
    _lastElapsed = elapsed;

    final bounds = (_screenBoundsKey.currentContext?.findRenderObject() as RenderBox?)?.size ?? Size.zero;

    // Offset where the leader hits the right edge.
    final maximumLeaderHorizontalOffset = bounds.width - _ballRadius * 2;

    // Offset where the leader hits the bottom edge.
    final maximumLeaderVerticalOffset = bounds.height - _ballRadius * 2;

    // Travelled distance between the last tick and the current.
    final distance = _velocity * (dt / 1000.0);

    Offset newOffset = _ballOffset + distance;

    // Check for hits.

    if (newOffset.dx > maximumLeaderHorizontalOffset) {
      // The ball hit the right edge.
      _velocity = Offset(-_velocity.dx, _velocity.dy);
      newOffset = Offset(maximumLeaderHorizontalOffset, newOffset.dy);
    }

    if (newOffset.dx <= 0) {
      // The ball hit the left edge.
      _velocity = Offset(-_velocity.dx, _velocity.dy);
      newOffset = Offset(0, newOffset.dy);
    }

    if (newOffset.dy > maximumLeaderVerticalOffset) {
      // The ball hit the bottom.
      _velocity = Offset(_velocity.dx, -_velocity.dy);
      newOffset = Offset(newOffset.dx, maximumLeaderVerticalOffset);
    }

    if (newOffset.dy <= 0) {
      // The ball hit the top.
      _velocity = Offset(_velocity.dx, -_velocity.dy);
      newOffset = Offset(newOffset.dx, 0);
    }

    setState(() {
      // Update the ball offset before updating the menu focal point.
      _ballOffset = newOffset;
      _updateMenuFocalPoint();
    });
  }

  /// Calculates the global offset where the menu's arrow should point.
  void _updateMenuFocalPoint() {
    final screenBoundsBox = _screenBoundsKey.currentContext?.findRenderObject() as RenderBox?;
    if (screenBoundsBox == null) {
      _globalMenuFocalPoint = Offset.zero;
      return;
    }

    final focalPointInScreenBounds = _ballOffset + const Offset(_ballRadius, _ballRadius);
    final globalLeaderOffset = screenBoundsBox.localToGlobal(focalPointInScreenBounds);

    _globalMenuFocalPoint = globalLeaderOffset;
  }

  FollowerAlignment _alignMenu(Rect globalLeaderRect, Size followerSize) {
    final bounds = (_screenBoundsKey.currentContext?.findRenderObject() as RenderBox?)?.size ?? Size.zero;

    final newAlignment = popoverMenuAligner(globalLeaderRect, followerSize, bounds, _previousFollowerAlignment);
    _previousFollowerAlignment = newAlignment;
    return newAlignment;
  }

  @override
  Widget build(BuildContext context) {
    return BallSandbox(
      boundsKey: _screenBoundsKey,
      leaderKey: _leaderKey,
      followerKey: _followerKey,
      ballOffset: _ballOffset,
      followerAligner: _alignMenu,
      follower: _buildMenu(),
    );
  }

  Widget _buildMenu() {
    return IosPopoverMenu(
      globalFocalPoint: _globalMenuFocalPoint,
      padding: const EdgeInsets.all(12.0),
      child: const SizedBox(
        width: _menuWidth,
        height: 100,
        child: Center(
          child: Text(
            'Popover Content',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
