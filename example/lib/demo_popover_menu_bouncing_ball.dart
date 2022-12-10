import 'package:example/infrastructure/ball_sandbox.dart';
import 'package:example/ios_popover/popover_aligners.dart';
import 'package:flutter/material.dart';
import 'package:follow_the_leader/follow_the_leader.dart';
import 'package:overlord/overlord.dart';

/// Displays an [IosPopoverMenu] near a bouncing ball.
class PopoverMenuBouncingBallDemo extends StatefulWidget {
  const PopoverMenuBouncingBallDemo({super.key});

  @override
  State<PopoverMenuBouncingBallDemo> createState() => _PopoverMenuBouncingBallDemoState();
}

class _PopoverMenuBouncingBallDemoState extends State<PopoverMenuBouncingBallDemo> with SingleTickerProviderStateMixin {
  static const double _menuWidth = 100;
  static const double _ballRadius = 50.0;

  final GlobalKey _screenBoundsKey = GlobalKey();
  final GlobalKey _leaderKey = GlobalKey();
  final GlobalKey _followerKey = GlobalKey();

  late final FollowerAligner _aligner;

  /// Current offset of the leader.
  ///
  /// The offset changes at every tick.
  Offset _ballOffset = const Offset(0, 200);

  /// The global offset where the menu's arrow should point.
  Offset _globalMenuFocalPoint = Offset.zero;

  @override
  void initState() {
    super.initState();
    _aligner = CupertinoPopoverMenuAligner(_screenBoundsKey);
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
      initialBallOffset: const Offset(0, 200),
      onBallMove: (ballOffset) {
        setState(() {
          _ballOffset = ballOffset;
          _updateMenuFocalPoint();
        });
      },
    );
  }

  Widget _buildMenu() {
    return CupertinoPopoverMenu(
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
}
