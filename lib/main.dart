import 'dart:math';

import 'package:flutter/material.dart';

import 'position_aware_follower.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Aware Follower',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _screenBoundKey = GlobalKey();
  late LayerLink _link;
  Offset _offset = const Offset(250, 250);

  @override
  void initState() {
    super.initState();
    _link = LayerLink();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _offset += details.delta;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _screenBoundKey,
      body: Stack(
        children: [
          Positioned(
            left: _offset.dx,
            top: _offset.dy,
            child: FractionalTranslation(
              translation: const Offset(-0.5, -0.5),
              child: GestureDetector(
                onPanUpdate: _onPanUpdate,
                child: CompositedTransformTarget(
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
      for (int i = 0; i < followerCount; i += 1) _buildFollowerAtAngle((i / followerCount) * (2 * pi)),
    ];
  }

  Widget _buildFollowerAtAngle(double radians) {
    const radius = 100;

    return Positioned(
      left: 0,
      top: 0,
      child: LocationAwareCompositedTransformFollower(
        link: _link,
        boundaryKey: _screenBoundKey,
        targetAnchor: Alignment.center,
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
