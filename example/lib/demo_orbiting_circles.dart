import 'dart:math';

import 'package:flutter/material.dart';
import 'package:follow_the_leader/follow_the_leader.dart';

import 'logging.dart';

class OrbitingCirclesDemo extends StatefulWidget {
  const OrbitingCirclesDemo({Key? key}) : super(key: key);

  @override
  State<OrbitingCirclesDemo> createState() => _OrbitingCirclesDemoState();
}

class _OrbitingCirclesDemoState extends State<OrbitingCirclesDemo> {
  final _screenBoundKey = GlobalKey();
  late LeaderLink _link;
  Offset _offset = const Offset(250, 250);

  @override
  void initState() {
    super.initState();
    _link = LeaderLink();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _offset += details.delta;
    });
  }

  @override
  Widget build(BuildContext context) {
    appLog.fine("Rebuilding entire demo");
    return SizedBox(
      key: _screenBoundKey,
      child: Stack(
        children: [
          Positioned(
            left: _offset.dx,
            top: _offset.dy,
            child: FractionalTranslation(
              translation: const Offset(-0.5, -0.5),
              child: GestureDetector(
                onPanUpdate: _onPanUpdate,
                child: Leader(
                  link: _link,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
          ..._buildFollowers(),
        ],
      ),
    );
  }

  List<Widget> _buildFollowers() {
    const followerCount = 8;
    return [
      for (int i = 0; i < followerCount; i += 1) //
        _buildFollowerAtAngle((i / followerCount) * (2 * pi)),
    ];
  }

  Widget _buildFollowerAtAngle(double radians) {
    const radius = 100;

    return Positioned(
      left: 0,
      top: 0,
      child: Follower.withOffset(
        link: _link,
        boundaryKey: _screenBoundKey,
        leaderAnchor: Alignment.center,
        followerAnchor: Alignment.center,
        offset: Offset(
          radius * cos(radians),
          radius * sin(radians),
        ),
        child: Container(
          width: 25,
          height: 25,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
