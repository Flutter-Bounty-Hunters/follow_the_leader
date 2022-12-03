import 'package:example/infrastructure/ball_sandbox.dart';
import 'package:flutter/material.dart';
import 'package:follow_the_leader/follow_the_leader.dart';

import 'ios_popover/_ios_popover_menu.dart';

/// Displays a blob that the user can drag, followed by a menu with an arrow
/// that points in the direction of the blob.
class DraggableBallDemo extends StatefulWidget {
  const DraggableBallDemo({super.key});

  @override
  State<DraggableBallDemo> createState() => _DraggableBallDemoState();
}

class _DraggableBallDemoState extends State<DraggableBallDemo> {
  static const double _menuWidth = 100;
  static const double _draggableBlogRadius = 50.0;
  static const double _minimumDistanceFromEdge = 16;

  final GlobalKey _screenBoundsKey = GlobalKey();
  final GlobalKey _leaderKey = GlobalKey();
  final GlobalKey _followerKey = GlobalKey();

  /// The (x,y) position of the draggable object, which is also our `Leader`.
  Offset _draggableOffset = const Offset(0, 200);

  /// The global offset where the menu's arrow should point.
  Offset _globalMenuFocalPoint = Offset.zero;

  /// The most recent [FollowerAlignment], which is cached so that we only
  /// change the `Follower`'s relative position if absolutely necessary.
  FollowerAlignment _previousFollowerAlignment = const FollowerAlignment(
    leaderAnchor: Alignment.centerRight,
    followerAnchor: Alignment.centerLeft,
    followerOffset: Offset(20, 0),
  );

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      // Update _draggableOffset before updating the menu focal point
      _draggableOffset += details.delta;
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

    final focalPointInScreenBounds = _draggableOffset + const Offset(_draggableBlogRadius, _draggableBlogRadius);
    final globalLeaderOffset = screenBoundsBox.localToGlobal(focalPointInScreenBounds);

    _globalMenuFocalPoint = globalLeaderOffset;
  }

  /// Aligns the menu `Follower` with the `Leader` blob.
  ///
  /// We use this method in a `Follower.withDynamics` so that we can flip the menu
  /// from one side of the blob to the other when we get close to the screen boundary.
  FollowerAlignment _alignMenu(Rect globalLeaderRect, Size followerSize) {
    final bounds = (_screenBoundsKey.currentContext?.findRenderObject() as RenderBox?)?.size ?? Size.zero;
    print("Running aligner. Screen bound: $bounds");

    late FollowerAlignment alignment;
    if (globalLeaderRect.right + followerSize.width + _minimumDistanceFromEdge >= bounds.width) {
      print(" - follower is too far to the right, switching to left");
      // The follower hit the minimum distance. Invert the follower position.
      alignment = const FollowerAlignment(
        leaderAnchor: Alignment.centerLeft,
        followerAnchor: Alignment.centerRight,
        followerOffset: Offset(-20, 0),
      );
    } else if (globalLeaderRect.left - followerSize.width - _minimumDistanceFromEdge < 0) {
      print(" - follower is too far to the left, switching to right");
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BallSandbox(
          boundsKey: _screenBoundsKey,
          leaderKey: _leaderKey,
          followerKey: _followerKey,
          blobOffset: _draggableOffset,
          blobDecorator: (blob) {
            return GestureDetector(
              onPanUpdate: _onPanUpdate,
              child: blob,
            );
          },
          followerAligner: _alignMenu,
          follower: _buildMenu(),
        ),
        _buildDebugFocalPoint(),
      ],
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

  Widget _buildDebugFocalPoint() {
    return Positioned(
      left: _globalMenuFocalPoint.dx,
      top: _globalMenuFocalPoint.dy,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
