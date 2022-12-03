import 'package:example/infrastructure/ball_sandbox.dart';
import 'package:flutter/material.dart';
import 'package:follow_the_leader/follow_the_leader.dart';

import 'ios_popover/ios_popover_menu.dart';

/// Displays a ball that the user can drag, followed by a menu with an arrow
/// that points in the direction of the ball.
class DraggableBallDemo extends StatefulWidget {
  const DraggableBallDemo({super.key});

  @override
  State<DraggableBallDemo> createState() => _DraggableBallDemoState();
}

class _DraggableBallDemoState extends State<DraggableBallDemo> {
  static const double _menuWidth = 100;
  static const double _draggableBallRadius = 50.0;

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

    final focalPointInScreenBounds = _draggableOffset + const Offset(_draggableBallRadius, _draggableBallRadius);
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
    return Stack(
      children: [
        BallSandbox(
          boundsKey: _screenBoundsKey,
          leaderKey: _leaderKey,
          followerKey: _followerKey,
          ballOffset: _draggableOffset,
          ballDecorator: (ball) {
            return GestureDetector(
              onPanUpdate: _onPanUpdate,
              child: ball,
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
