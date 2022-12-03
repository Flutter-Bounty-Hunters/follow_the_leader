import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:follow_the_leader/follow_the_leader.dart';

import 'ios_popover/_ios_popover_menu.dart';

class BoucingBallDemo extends StatefulWidget {
  const BoucingBallDemo({super.key});

  @override
  State<BoucingBallDemo> createState() => _BoucingBallDemoState();
}

class _BoucingBallDemoState extends State<BoucingBallDemo> with SingleTickerProviderStateMixin {
  final GlobalKey _screenBoundKey = GlobalKey();
  final GlobalKey _followerKey = GlobalKey();
  late Ticker ticker;
  late LeaderLink _link;

  /// Initial velocity of the leader.
  final Offset _initialVelocity = const Offset(300, 300);

  /// Current velocity of the leader.
  ///
  /// The velocity is updated whenever the leader hits an edge of the screen.
  late Offset _velocity;

  /// Minimum distance in pixels which the follower should be from any edge.
  ///
  /// Whenever the leader hits this distance, the direction changes.
  final double _minimumDistanceFromEdge = 96;

  final double _leaderRadius = 50.0;

  /// Width of the menu.
  final double _followerWidth = 100;

  /// Last [Duration] given by the ticker.
  Duration? _lastElapsed;

  /// Current offset of the leader.
  ///
  /// The offset changes at every tick.
  Offset _leaderOffset = const Offset(0, 200);

  /// Current offset of the follower.
  ///
  /// The offset changes whenever the follower is less then [_minimumDistanceFromEdge] pixels from any edge.
  Offset _followerOffset = const Offset(20, 0);

  /// Current targetAnchor of the follower.
  ///
  /// The anchor changes whenever the follower is less then [_minimumDistanceFromEdge] pixels from any edge.
  Alignment _targetAnchor = Alignment.centerRight;

  /// Current followerAnchor of the follower.
  ///
  /// The anchor changes whenever the follower is less then [_minimumDistanceFromEdge] pixels from any edge.
  Alignment _followerAnchor = Alignment.centerLeft;

  /// Current focal point of the popover menu.
  ///
  /// The offset changes at every tick.
  Offset _currentFocalPoint = Offset.zero;

  @override
  void initState() {
    super.initState();
    ticker = createTicker(_onTick);
    ticker.start();
    _link = LeaderLink();
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

    final bounds = _getScreenBounds();

    // Offset where the leader hits the right edge.
    final maximumLeaderHorizontalOffset = bounds.width - _leaderRadius * 2;

    // Offset where the leader hits the bottom edge.
    final maximumLeaderVerticalOffset = bounds.height - _leaderRadius * 2;

    // Travelled distance between the last tick and the current.
    final distance = _velocity * (dt / 1000.0);

    Offset newOffset = _leaderOffset + distance;

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

    _updateMenuFocalPoint();
    _updateFollowerAnchorAndOffset();

    setState(() {
      _leaderOffset = newOffset;
    });
  }

  Size _getScreenBounds() {
    return (_screenBoundKey.currentContext?.findRenderObject() as RenderBox?)?.size ?? Size.zero;
  }

  void _updateMenuFocalPoint() {
    final renderBox = _screenBoundKey.currentContext?.findRenderObject() as RenderBox?;
    _currentFocalPoint = renderBox != null //
        ? renderBox.localToGlobal(_leaderOffset + Offset(_leaderRadius, _leaderRadius))
        : Offset.zero;
  }

  void _updateFollowerAnchorAndOffset() {
    final renderFollower = _followerKey.currentContext?.findRenderObject() as RenderFollowerLayer?;
    if (renderFollower == null) {
      return;
    }

    const defaultFollowerOffset = Offset(20, 0);
    final bounds = _getScreenBounds();

    // Find the follower offset and size.
    final effectiveFollowerOffset = renderFollower.previousFollowerOffset ?? Offset.zero;
    final transform = renderFollower.getCurrentTransform()..translate(effectiveFollowerOffset.dx);
    final translation = transform.getTranslation();
    final followerXOffset = translation.storage[0];
    final followerSize = renderFollower.size;

    if (followerXOffset + followerSize.width + _minimumDistanceFromEdge >= bounds.width) {
      // The follower hit the minimum distance. Invert the follower position.
      _targetAnchor = Alignment.centerLeft;
      _followerAnchor = Alignment.centerRight;
      _followerOffset = Offset(-defaultFollowerOffset.dx, 0);
    } else if (followerXOffset <= _minimumDistanceFromEdge) {
      // The follower hit the minimum distance. Invert the follower position.
      _targetAnchor = Alignment.centerRight;
      _followerAnchor = Alignment.centerLeft;
      _followerOffset = Offset(defaultFollowerOffset.dx, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: _screenBoundKey,
      children: [
        _buildLeader(),
        _buildFollower(),
      ],
    );
  }

  Widget _buildLeader() {
    return Positioned(
      left: _leaderOffset.dx,
      top: _leaderOffset.dy,
      child: Leader(
        link: _link,
        child: Container(
          height: _leaderRadius * 2,
          width: _leaderRadius * 2,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildFollower() {
    return Positioned(
      left: 0,
      top: 0,
      child: Follower(
        key: _followerKey,
        link: _link,
        boundaryKey: _screenBoundKey,
        targetAnchor: _targetAnchor,
        followerAnchor: _followerAnchor,
        offset: _followerOffset,
        child: IosPopoverMenu(
          globalFocalPoint: _currentFocalPoint,
          padding: const EdgeInsets.all(12.0),
          child: SizedBox(
            width: _followerWidth,
            height: 100,
            child: const Center(
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
        ),
      ),
    );
  }
}
