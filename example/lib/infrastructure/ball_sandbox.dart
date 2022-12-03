import 'package:flutter/material.dart';
import 'package:follow_the_leader/follow_the_leader.dart';

/// Displays a blob with an associated follower.
///
/// The blob can be given any offset.
class BallSandbox extends StatefulWidget {
  const BallSandbox({
    super.key,
    required this.boundsKey,
    required this.leaderKey,
    required this.followerKey,
    required this.blobOffset,
    this.blobDecorator,
    required this.followerAligner,
    required this.follower,
  });

  final GlobalKey boundsKey;
  final GlobalKey leaderKey;
  final GlobalKey followerKey;
  final Offset blobOffset;
  final Widget Function(Widget blob)? blobDecorator;
  final FollowerAligner followerAligner;
  final Widget follower;

  @override
  State<BallSandbox> createState() => _BallSandboxState();
}

class _BallSandboxState extends State<BallSandbox> {
  static const double _blobRadius = 50.0;

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
      left: widget.blobOffset.dx,
      top: widget.blobOffset.dy,
      child: Leader(
        key: widget.leaderKey,
        link: _leaderLink,
        child: widget.blobDecorator != null //
            ? widget.blobDecorator!.call(_buildBlob()) //
            : _buildBlob(),
      ),
    );
  }

  Widget _buildBlob() {
    return Container(
      height: _blobRadius * 2,
      width: _blobRadius * 2,
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
