import 'package:example/logging.dart';
import 'package:flutter/widgets.dart';
import 'package:follow_the_leader/follow_the_leader.dart';

/// Aligns an iOS-style popover menu `Follower` with a `Leader` widget.
///
/// Use with `Follower.withDynamics` to position the menu based on
/// proximity to the bounds of the screen.
class CupertinoPopoverMenuAligner implements FollowerAligner {
  CupertinoPopoverMenuAligner([this._boundsKey]);

  final GlobalKey? _boundsKey;

  FollowerAlignment _previousFollowerAlignment = const FollowerAlignment(
    leaderAnchor: Alignment.topCenter,
    followerAnchor: Alignment.bottomCenter,
    followerOffset: Offset(0, -20),
  );

  @override
  FollowerAlignment align(Rect globalLeaderRect, Size followerSize) {
    final boundsBox = _boundsKey?.currentContext?.findRenderObject() as RenderBox?;
    final bounds = boundsBox != null
        ? Rect.fromPoints(
            boundsBox.localToGlobal(Offset.zero),
            boundsBox.localToGlobal(boundsBox.size.bottomRight(Offset.zero)),
          )
        : Rect.largest;

    late FollowerAlignment alignment;
    if (globalLeaderRect.right + followerSize.width + _popoverMenuMinimumDistanceFromEdge >= bounds.right) {
      appLog.info(" - follower is too far to the right, switching to left");
      // The follower hit the minimum distance. Invert the follower position.
      alignment = const FollowerAlignment(
        leaderAnchor: Alignment.centerLeft,
        followerAnchor: Alignment.centerRight,
        followerOffset: Offset(-20, 0),
      );
    } else if (globalLeaderRect.left - followerSize.width - _popoverMenuMinimumDistanceFromEdge < bounds.left) {
      appLog.info(" - follower is too far to the left, switching to right");
      // The follower hit the minimum distance. Invert the follower position.
      alignment = const FollowerAlignment(
        leaderAnchor: Alignment.centerRight,
        followerAnchor: Alignment.centerLeft,
        followerOffset: Offset(20, 0),
      );
    } else {
      // We're not too far to the left or the right. Keep us wherever we were before.
      alignment = _previousFollowerAlignment;
    }

    _previousFollowerAlignment = alignment;

    return alignment;
  }
}

const double _popoverMenuMinimumDistanceFromEdge = 16;

/// Aligns an iOS-style popover toolbar `Follower` with a `Leader` widget.
///
/// Use with `Follower.withDynamics` to position the toolbar based on
/// proximity to the bounds of the screen.
class CupertinoPopoverToolbarAligner implements FollowerAligner {
  CupertinoPopoverToolbarAligner([this._boundsKey]);

  final GlobalKey? _boundsKey;

  @override
  FollowerAlignment align(Rect globalLeaderRect, Size followerSize) {
    final boundsBox = _boundsKey?.currentContext?.findRenderObject() as RenderBox?;
    final bounds = boundsBox != null
        ? Rect.fromPoints(
            boundsBox.localToGlobal(Offset.zero),
            boundsBox.localToGlobal(boundsBox.size.bottomRight(Offset.zero)),
          )
        : Rect.largest;

    late FollowerAlignment alignment;
    if (globalLeaderRect.top - followerSize.height - _popoverToolbarMinimumDistanceFromEdge < bounds.top) {
      appLog.info(" - follower is too far to the top, switching to bottom");
      // The follower hit the minimum distance. Invert the follower position.
      alignment = const FollowerAlignment(
        leaderAnchor: Alignment.bottomCenter,
        followerAnchor: Alignment.topCenter,
        followerOffset: Offset(0, 20),
      );
    } else {
      // There's enough room to display toolbar above content. That's our desired
      // default position, so put the toolbar on top.
      alignment = const FollowerAlignment(
        leaderAnchor: Alignment.topCenter,
        followerAnchor: Alignment.bottomCenter,
        followerOffset: Offset(0, -20),
      );
    }

    return alignment;
  }
}

const double _popoverToolbarMinimumDistanceFromEdge = 16;
