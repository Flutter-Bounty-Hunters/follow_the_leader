import 'package:flutter/material.dart';
import 'package:follow_the_leader/follow_the_leader.dart';

Widget buildLeaderAndFollowerWithOffset(
  FollowerAlignment align, {
  LeaderLink? link,
  Size leaderSize = const Size(10, 10),
  Alignment leaderAlignment = Alignment.center,
  Size followerSize = const Size(20, 20),
  FollowerBoundary boundary = const ScreenFollowerBoundary(),
  bool fadeOutBeyondBoundary = false,
}) {
  link ??= LeaderLink();

  return ColoredBox(
    color: const Color(0xff020817),
    child: Stack(
      children: [
        if (boundary is WidgetFollowerBoundary) //
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: DecoratedBox(
                key: boundary.boundaryKey,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.purpleAccent, width: 2),
                ),
              ),
            ),
          ),
        Align(
          alignment: leaderAlignment,
          child: Leader(
            link: link,
            child: _TestLeader(leaderSize),
          ),
        ),
        FollowerFadeOutBeyondBoundary(
          link: link,
          boundary: boundary,
          enabled: fadeOutBeyondBoundary,
          child: Follower.withOffset(
            link: link,
            leaderAnchor: align.leaderAnchor,
            followerAnchor: align.followerAnchor,
            offset: align.followerOffset,
            boundary: boundary,
            child: _TestFollower(followerSize),
          ),
        ),
      ],
    ),
  );
}

Widget buildLeaderAndFollowerWithAligner({
  LeaderLink? link,
  Size leaderSize = const Size(10, 10),
  Alignment leaderAlignment = Alignment.center,
  Size followerSize = const Size(20, 20),
  required FollowerAligner aligner,
  FollowerBoundary boundary = const ScreenFollowerBoundary(),
}) {
  link ??= LeaderLink();

  return ColoredBox(
    color: const Color(0xff020817),
    child: Stack(
      children: [
        Align(
          alignment: leaderAlignment,
          child: Leader(
            link: link,
            child: _TestLeader(leaderSize),
          ),
        ),
        Follower.withAligner(
          link: link,
          aligner: aligner,
          boundary: boundary,
          child: _TestFollower(followerSize),
        ),
      ],
    ),
  );
}

class _TestLeader extends StatelessWidget {
  const _TestLeader(this.size);

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      color: Colors.blue,
    );
  }
}

class _TestFollower extends StatelessWidget {
  const _TestFollower(this.size);

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      color: Colors.red,
    );
  }
}

const followerAlignLeft = FollowerAlignment(
  leaderAnchor: Alignment.centerLeft,
  followerAnchor: Alignment.centerRight,
  followerOffset: Offset(-20, 0),
);

const followerAlignTopLeft = FollowerAlignment(
  leaderAnchor: Alignment.topLeft,
  followerAnchor: Alignment.bottomRight,
  followerOffset: Offset(-20, -20),
);

const followerAlignTop = FollowerAlignment(
  leaderAnchor: Alignment.topCenter,
  followerAnchor: Alignment.bottomCenter,
  followerOffset: Offset(0, -20),
);

const followerAlignTopRight = FollowerAlignment(
  leaderAnchor: Alignment.topRight,
  followerAnchor: Alignment.bottomLeft,
  followerOffset: Offset(20, -20),
);

const followerAlignRight = FollowerAlignment(
  leaderAnchor: Alignment.centerRight,
  followerAnchor: Alignment.centerLeft,
  followerOffset: Offset(20, 0),
);

const followerAlignBottomRight = FollowerAlignment(
  leaderAnchor: Alignment.bottomRight,
  followerAnchor: Alignment.topLeft,
  followerOffset: Offset(20, 20),
);

const followerAlignBottom = FollowerAlignment(
  leaderAnchor: Alignment.bottomCenter,
  followerAnchor: Alignment.topCenter,
  followerOffset: Offset(0, 20),
);

const followerAlignBottomLeft = FollowerAlignment(
  leaderAnchor: Alignment.bottomLeft,
  followerAnchor: Alignment.topRight,
  followerOffset: Offset(-20, 20),
);

const followerAlignCenter = FollowerAlignment(
  leaderAnchor: Alignment.center,
  followerAnchor: Alignment.center,
  followerOffset: Offset.zero,
);
