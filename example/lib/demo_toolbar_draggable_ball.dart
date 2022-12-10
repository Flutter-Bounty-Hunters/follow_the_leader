import 'package:example/infrastructure/ball_sandbox.dart';
import 'package:example/ios_popover/popover_aligners.dart';
import 'package:flutter/material.dart';
import 'package:follow_the_leader/follow_the_leader.dart';
import 'package:overlord/overlord.dart';

/// Displays an [IosToolbar] near a draggable ball.
class ToolbarDraggableBallDemo extends StatefulWidget {
  const ToolbarDraggableBallDemo({super.key});

  @override
  State<ToolbarDraggableBallDemo> createState() => _ToolbarDraggableBallDemoState();
}

class _ToolbarDraggableBallDemoState extends State<ToolbarDraggableBallDemo> {
  static const double _draggableBallRadius = 50.0;

  final GlobalKey _screenBoundsKey = GlobalKey();
  final GlobalKey _leaderKey = GlobalKey();
  final GlobalKey _followerKey = GlobalKey();

  late final FollowerAligner _aligner;

  /// The (x,y) position of the draggable object, which is also our `Leader`.
  Offset _ballOffset = const Offset(300, 200);

  /// The global offset where the menu's arrow should point.
  Offset _globalMenuFocalPoint = Offset.zero;

  @override
  void initState() {
    super.initState();

    _aligner = CupertinoPopoverToolbarAligner(_screenBoundsKey);

    // After the first frame, calculate the menu focal point.
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _updateMenuFocalPoint();
      });
    });
  }

  void _onBallMove(Offset offset) {
    setState(() {
      // Update _draggableOffset before updating the menu focal point
      _ballOffset = offset;
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

    final focalPointInScreenBounds = _ballOffset + const Offset(_draggableBallRadius, _draggableBallRadius);
    final globalLeaderOffset = screenBoundsBox.localToGlobal(focalPointInScreenBounds);

    _globalMenuFocalPoint = globalLeaderOffset;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DraggableBallSandbox(
          boundsKey: _screenBoundsKey,
          leaderKey: _leaderKey,
          followerKey: _followerKey,
          followerAligner: _aligner,
          follower: _buildMenu(),
          initialBallOffset: _ballOffset,
          onBallMove: _onBallMove,
        ),
        _buildDebugFocalPoint(),
      ],
    );
  }

  Widget _buildMenu() {
    return CupertinoPopoverToolbar(
      globalFocalPoint: _globalMenuFocalPoint,
      children: const [
        CupertinoPopoverToolbarMenuItem(label: 'Style'),
        CupertinoPopoverToolbarMenuItem(label: 'Duplicate'),
        CupertinoPopoverToolbarMenuItem(label: 'Cut'),
        CupertinoPopoverToolbarMenuItem(label: 'Copy'),
        CupertinoPopoverToolbarMenuItem(label: 'Paste'),
      ],
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
