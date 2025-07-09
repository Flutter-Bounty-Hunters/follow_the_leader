import 'package:flutter/painting.dart';

import 'package:follow_the_leader/src/follower.dart';

/// A [FollowerAligner] that attempts to position the [Follower] at a preferred position in
/// relation to the [Leader], but moves the [Follower] if there's not enough space between
/// the [Leader] and the boundary.
///
/// If there's not enough room in the main-axis direction then the [Follower] is flipped to the
/// opposite side of the [Leader].
///
/// If there's not enough room in the cross-axis direction, the [Follower] is nudged by just
/// enough distance to keep it within the boundary.
///
/// If no boundary is registered with the [Follower], this aligner always positions the [Follower]
/// at the desired location relative to the [Leader].
class PreferredPositionAligner implements FollowerAligner {
  PreferredPositionAligner.top({
    this.leaderCrossAxisAnchor = Alignment.topCenter,
    this.followerCrossAxisAnchor = Alignment.bottomCenter,
    this.gap = 20,
  }) : followerPosition = PreferredPrimaryPosition.top;

  PreferredPositionAligner.bottom({
    this.leaderCrossAxisAnchor = Alignment.bottomCenter,
    this.followerCrossAxisAnchor = Alignment.topCenter,
    this.gap = 20,
  }) : followerPosition = PreferredPrimaryPosition.bottom;

  PreferredPositionAligner.left({
    this.leaderCrossAxisAnchor = Alignment.centerLeft,
    this.followerCrossAxisAnchor = Alignment.centerRight,
    this.gap = 20,
  }) : followerPosition = PreferredPrimaryPosition.left;

  PreferredPositionAligner.right({
    this.leaderCrossAxisAnchor = Alignment.centerRight,
    this.followerCrossAxisAnchor = Alignment.centerLeft,
    this.gap = 20,
  }) : followerPosition = PreferredPrimaryPosition.right;

  PreferredPositionAligner({
    required this.followerPosition,
    required this.leaderCrossAxisAnchor,
    required this.followerCrossAxisAnchor,
    this.gap = 20,
  });

  final PreferredPrimaryPosition followerPosition;

  final Alignment leaderCrossAxisAnchor;
  final Alignment followerCrossAxisAnchor;

  final Dip gap;

  @override
  FollowerAlignment align(RectDip globalLeaderRect, SizeDip followerSize, [RectDip? globalBounds]) {
    if (followerPosition.isVertical) {
      return _alignVertical(globalLeaderRect, followerSize, globalBounds);
    } else {
      return _alignHorizontal(globalLeaderRect, followerSize, globalBounds);
    }
  }

  FollowerAlignment _alignVertical(RectDip globalLeaderRect, SizeDip followerSize, [RectDip? globalBounds]) {
    assert(followerPosition == PreferredPrimaryPosition.top || followerPosition == PreferredPrimaryPosition.bottom);

    final spaceAboveLeader = globalLeaderRect.top - (globalBounds?.top ?? 0);
    final spaceBelowLeader = (globalBounds?.bottom ?? double.infinity) - globalLeaderRect.bottom;
    final neededFollowerSpace = followerSize.height + gap;

    if (followerPosition == PreferredPrimaryPosition.top) {
      // We want to place the Follower above the Leader.
      if (spaceAboveLeader < neededFollowerSpace && spaceBelowLeader > neededFollowerSpace) {
        // The follower hit the minimum distance. Invert the Follower position to below the Leader.
        return _alignBottom();
      }

      // The follower can fit above. Use the standard orientation.
      return _alignTop();
    } else {
      // We want to place the Follower below the Leader.
      if (spaceBelowLeader < neededFollowerSpace && spaceAboveLeader > neededFollowerSpace) {
        // The follower hit the minimum distance. Invert the follower position.
        return _alignTop();
      }

      // The follower can fit below. Use the standard orientation.
      return _alignBottom();
    }
  }

  FollowerAlignment _alignHorizontal(RectDip globalLeaderRect, SizeDip followerSize, [RectDip? globalBounds]) {
    assert(followerPosition == PreferredPrimaryPosition.left || followerPosition == PreferredPrimaryPosition.right);

    final spaceLeftOfLeader = globalLeaderRect.left - (globalBounds?.left ?? 0);
    final spaceRightOfLeader = (globalBounds?.right ?? double.infinity) - globalLeaderRect.right;
    final neededFollowerSpace = followerSize.width + gap;

    if (followerPosition == PreferredPrimaryPosition.left) {
      // We want to place the Follower to the left of the Leader.
      if (spaceLeftOfLeader < neededFollowerSpace && spaceRightOfLeader > neededFollowerSpace) {
        // The follower hit the minimum distance. Invert the Follower position to the right.
        return _alignRight();
      }

      // The follower can fit to the left. Use the standard orientation.
      return _alignLeft();
    } else {
      // We want to place the Follower to the right of the Leader.
      if (spaceRightOfLeader < neededFollowerSpace && spaceLeftOfLeader > neededFollowerSpace) {
        // The follower hit the minimum distance. Invert the follower position to the left.
        return _alignLeft();
      }

      // The follower can fit to the right. Use the standard orientation.
      return _alignRight();
    }
  }

  FollowerAlignment _alignTop() {
    return FollowerAlignment(
      leaderAnchor: Alignment(leaderCrossAxisAnchor.x, -1),
      followerAnchor: Alignment(followerCrossAxisAnchor.x, 1),
      followerOffset: Offset(0, -gap),
    );
  }

  FollowerAlignment _alignBottom() {
    return FollowerAlignment(
      leaderAnchor: Alignment(leaderCrossAxisAnchor.x, 1),
      followerAnchor: Alignment(followerCrossAxisAnchor.x, -1),
      followerOffset: Offset(0, gap),
    );
  }

  FollowerAlignment _alignLeft() {
    return FollowerAlignment(
      leaderAnchor: Alignment(-1, leaderCrossAxisAnchor.y),
      followerAnchor: Alignment(1, followerCrossAxisAnchor.y),
      followerOffset: Offset(-gap, 0),
    );
  }

  FollowerAlignment _alignRight() {
    return FollowerAlignment(
      leaderAnchor: Alignment(1, leaderCrossAxisAnchor.y),
      followerAnchor: Alignment(-1, followerCrossAxisAnchor.y),
      followerOffset: Offset(gap, 0),
    );
  }
}

enum PreferredPrimaryPosition {
  top,
  bottom,
  left,
  right;

  bool get isVertical => this == top || this == bottom;

  bool get isHorizontal => this == left || this == right;
}

/// Positions a [Follower] near a [Leader] as per [leaderAnchor], [followerAnchor], and [gap], but constrains
/// the [Follower] within the [Follower]'s bounds by holding the [Follower] at the edge of the
/// boundary, regardless of where the [Leader] is positioned.
///
/// You can think of this behavior like holding the [Follower] within a fence.
class ConstrainedAligner implements FollowerAligner {
  const ConstrainedAligner({
    required this.leaderAnchor,
    required this.followerAnchor,
    this.gap = Offset.zero,
  });

  final Alignment leaderAnchor;
  final Alignment followerAnchor;
  final Offset gap;

  @override
  FollowerAlignment align(Rect globalLeaderRect, Size followerSize, [Rect? globalBounds]) {
    // TODO: implement align
    throw UnimplementedError();
  }
}
