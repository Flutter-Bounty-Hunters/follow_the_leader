import 'package:example/infrastructure/ball_sandbox.dart';
import 'package:example/ios_popover/popover_aligners.dart';
import 'package:flutter/material.dart';
import 'package:follow_the_leader/follow_the_leader.dart';
import 'package:overlord/overlord.dart';

/// Displays an [IosToolbar] near a bouncing ball.
class ToolbarBouncingBallDemo extends StatefulWidget {
  const ToolbarBouncingBallDemo({super.key});

  @override
  State<ToolbarBouncingBallDemo> createState() => _ToolbarBouncingBallDemoState();
}

class _ToolbarBouncingBallDemoState extends State<ToolbarBouncingBallDemo> with SingleTickerProviderStateMixin {
  static const double _ballRadius = 50.0;

  final GlobalKey _screenBoundsKey = GlobalKey();
  final GlobalKey _leaderKey = GlobalKey();
  final GlobalKey _followerKey = GlobalKey();

  late final FollowerAligner _aligner;

  /// Current offset of the leader.
  ///
  /// The offset changes at every tick.
  Offset _ballOffset = const Offset(300, 200);

  /// The global offset where the menu's arrow should point.
  Offset _globalMenuFocalPoint = Offset.zero;

  @override
  void initState() {
    super.initState();
    _aligner = CupertinoPopoverToolbarAligner(_screenBoundsKey);
  }

  /// Calculates the global offset where the menu's arrow should point.
  void _updateMenuFocalPoint() {
    final screenBoundsBox = _screenBoundsKey.currentContext?.findRenderObject() as RenderBox?;
    if (screenBoundsBox == null) {
      _globalMenuFocalPoint = Offset.zero;
      return;
    }

    final focalPointInScreenBounds = _ballOffset + const Offset(_ballRadius, _ballRadius);
    final globalLeaderOffset = screenBoundsBox.localToGlobal(focalPointInScreenBounds);

    _globalMenuFocalPoint = globalLeaderOffset;
  }

  @override
  Widget build(BuildContext context) {
    return BouncingBallSandbox(
      boundsKey: _screenBoundsKey,
      leaderKey: _leaderKey,
      followerKey: _followerKey,
      followerAligner: _aligner,
      follower: _buildMenu(),
      initialBallOffset: _ballOffset,
      onBallMove: (ballOffset) {
        setState(() {
          _ballOffset = ballOffset;
          _updateMenuFocalPoint();
        });
      },
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
}
