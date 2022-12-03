import 'package:flutter/material.dart';
import 'package:follow_the_leader/follow_the_leader.dart';

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
  static const double _ballRadius = 50.0;

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
      child: Follower.withDynamics(
        key: widget.followerKey,
        link: _leaderLink,
        boundaryKey: widget.boundsKey,
        aligner: widget.followerAligner,
        child: widget.follower,
      ),
    );
  }
}
