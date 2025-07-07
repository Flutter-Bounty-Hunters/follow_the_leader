import 'package:flutter/material.dart';
import 'package:follow_the_leader/follow_the_leader.dart';

class StaticPositioningDemo extends StatelessWidget {
  const StaticPositioningDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildLeaderAndFollower(const Offset(0, 20));
  }
}

Widget _buildLeaderAndFollower(Offset followerOffset) {
  final link = LeaderLink();
  return ColoredBox(
    color: Colors.grey,
    child: Stack(
      children: [
        Center(
          child: Leader(
            link: link,
            child: const _TestLeader(),
          ),
        ),
        Follower.withOffset(
          link: link,
          leaderAnchor: Alignment.bottomCenter,
          followerAnchor: Alignment.topCenter,
          offset: followerOffset,
          child: const _TestFollower(),
        ),
      ],
    ),
  );
}

class _TestLeader extends StatelessWidget {
  const _TestLeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      color: Colors.blue,
    );
  }
}

class _TestFollower extends StatelessWidget {
  const _TestFollower();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      color: Colors.red,
    );
  }
}
