import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:follow_the_leader/follow_the_leader.dart';

/// A [BallSandbox], with a ball that bounces around the screen
/// with a given [follower].
class BouncingBallSandbox extends StatefulWidget {
  const BouncingBallSandbox({
    super.key,
    required this.boundsKey,
    required this.leaderKey,
    required this.followerKey,
    required this.followerAligner,
    required this.follower,
    this.initialBallOffset = Offset.zero,
    this.onBallMove,
  });

  final GlobalKey boundsKey;
  final GlobalKey leaderKey;
  final GlobalKey followerKey;
  final FollowerAligner followerAligner;
  final Widget follower;
  final Offset initialBallOffset;
  final void Function(Offset)? onBallMove;

  @override
  State<BouncingBallSandbox> createState() => _BouncingBallSandboxState();
}

class _BouncingBallSandboxState extends State<BouncingBallSandbox> with SingleTickerProviderStateMixin {
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
  late Offset _ballOffset;

  late Ticker ticker;

  @override
  void initState() {
    super.initState();
    ticker = createTicker(_onTick)..start();
    _velocity = _initialVelocity;
    _ballOffset = widget.initialBallOffset;
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

    final bounds = (widget.boundsKey.currentContext?.findRenderObject() as RenderBox?)?.size ?? Size.zero;

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
      widget.onBallMove?.call(_ballOffset);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BallSandbox(
      boundsKey: widget.boundsKey,
      leaderKey: widget.leaderKey,
      followerKey: widget.followerKey,
      ballOffset: _ballOffset,
      followerAligner: widget.followerAligner,
      follower: widget.follower,
    );
  }
}

/// A [BallSandbox], which lets the user drag the ball around the
/// screen with a given [follower].
class DraggableBallSandbox extends StatefulWidget {
  const DraggableBallSandbox({
    super.key,
    required this.boundsKey,
    required this.leaderKey,
    required this.followerKey,
    required this.followerAligner,
    required this.follower,
    this.initialBallOffset = Offset.zero,
    this.onBallMove,
  });

  final GlobalKey boundsKey;
  final GlobalKey leaderKey;
  final GlobalKey followerKey;
  final FollowerAligner followerAligner;
  final Widget follower;
  final Offset initialBallOffset;
  final void Function(Offset)? onBallMove;

  @override
  State<DraggableBallSandbox> createState() => _DraggableBallSandboxState();
}

class _DraggableBallSandboxState extends State<DraggableBallSandbox> {
  /// The (x,y) position of the draggable object, which is also our `Leader`.
  late Offset _ballOffset;

  @override
  void initState() {
    super.initState();
    _ballOffset = widget.initialBallOffset;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      // Update _draggableOffset before updating the menu focal point
      _ballOffset += details.delta;
      widget.onBallMove?.call(_ballOffset);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BallSandbox(
      boundsKey: widget.boundsKey,
      leaderKey: widget.leaderKey,
      followerKey: widget.followerKey,
      ballOffset: _ballOffset,
      ballDecorator: (ball) {
        return GestureDetector(
          onPanUpdate: _onPanUpdate,
          child: ball,
        );
      },
      followerAligner: widget.followerAligner,
      follower: widget.follower,
    );
  }
}

/// Displays a ball with an associated follower.
///
/// The ball can be given any offset, and the ball can be decorated
/// with another widget, such as a `GestureDetector`.
class BallSandbox extends StatefulWidget {
  const BallSandbox({
    super.key,
    required this.boundsKey,
    required this.leaderKey,
    required this.followerKey,
    required this.ballOffset,
    this.ballDecorator,
    required this.followerAligner,
    required this.follower,
  });

  final GlobalKey boundsKey;
  final GlobalKey leaderKey;
  final GlobalKey followerKey;
  final Offset ballOffset;
  final Widget Function(Widget ball)? ballDecorator;
  final FollowerAligner followerAligner;
  final Widget follower;

  @override
  State<BallSandbox> createState() => _BallSandboxState();
}

class _BallSandboxState extends State<BallSandbox> {
  /// Links the [Leader] and the [Follower].
  late LeaderLink _leaderLink;

  @override
  void initState() {
    super.initState();
    _leaderLink = LeaderLink();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: widget.boundsKey,
      children: [
        _buildLeader(),
        _buildFollower(),
      ],
    );
  }

  Widget _buildLeader() {
    return Positioned(
      left: widget.ballOffset.dx,
      top: widget.ballOffset.dy,
      child: Leader(
        key: widget.leaderKey,
        link: _leaderLink,
        child: widget.ballDecorator != null //
            ? widget.ballDecorator!.call(_buildBall()) //
            : _buildBall(),
      ),
    );
  }

  Widget _buildBall() {
    return Container(
      height: _ballRadius * 2,
      width: _ballRadius * 2,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black,
      ),
    );
  }

  Widget _buildFollower() {
    return Positioned(
      left: 0,
      top: 0,
      child: Follower.withAligner(
        key: widget.followerKey,
        link: _leaderLink,
        aligner: widget.followerAligner,
        boundary: WidgetFollowerBoundary(boundaryKey: widget.boundsKey),
        child: widget.follower,
      ),
    );
  }
}

const double _ballRadius = 50.0;
