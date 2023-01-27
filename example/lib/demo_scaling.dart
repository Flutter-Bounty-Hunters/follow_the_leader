import 'package:flutter/material.dart';
import 'package:follow_the_leader/follow_the_leader.dart';
import 'package:overlord/follow_the_leader.dart';
import 'package:overlord/overlord.dart';

/// Demonstrates that leaders and followers paint and handle touch events
/// as expected, when they are scaled up/down.
class ScalingDemo extends StatefulWidget {
  const ScalingDemo({Key? key}) : super(key: key);

  @override
  State<ScalingDemo> createState() => _ScalingDemoState();
}

class _ScalingDemoState extends State<ScalingDemo> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF222222),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      // Spacer(),
                      Expanded(
                        child: _ScaleLeaderAndFollower(scale: _scale),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: _ScaleLeaderButNotFollower(scale: _scale),
                            ),
                            // Spacer(),
                            Expanded(
                              child: _ScaleFollowerButNotLeader(scale: _scale),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildScaleSlider(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScaleSlider() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48.0),
        child: SizedBox(
          width: 200,
          child: IntrinsicHeight(
            child: Slider(
              value: _scale,
              min: 0.1,
              max: 5.0,
              onChanged: (newValue) {
                setState(() {
                  _scale = newValue;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ScaleLeaderAndFollower extends StatefulWidget {
  const _ScaleLeaderAndFollower({
    Key? key,
    required this.scale,
  }) : super(key: key);

  final double scale;

  @override
  State<_ScaleLeaderAndFollower> createState() => _ScaleLeaderAndFollowerState();
}

class _ScaleLeaderAndFollowerState extends State<_ScaleLeaderAndFollower> {
  final _anchor = LeaderLink();
  final _boundsKey = GlobalKey();

  late final _viewportBoundary = WidgetFollowerBoundary(_boundsKey);
  late final _aligner = CupertinoPopoverToolbarAligner(_boundsKey);
  late final _focalPoint = LeaderMenuFocalPoint(link: _anchor);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRect(
            child: Transform.scale(
              scale: widget.scale,
              child: BuildInOrder(
                children: [
                  Align(
                    alignment: const Alignment(0.0, 0.2),
                    child: Leader(
                      link: _anchor,
                      child: Container(width: 25, height: 25, color: Colors.red),
                    ),
                  ),
                  Follower.withAligner(
                    link: _anchor,
                    aligner: _aligner,
                    // leaderAnchor: Alignment.topCenter,
                    // followerAnchor: Alignment.bottomCenter,
                    // offset: Offset(0, -25),
                    repaintWhenLeaderChanges: true,
                    child: CupertinoPopoverToolbar(
                      focalPoint: _focalPoint,
                      children: [
                        TextButton(
                          // ignore: avoid_print
                          onPressed: () => print("one"),
                          child: const Text("One", style: TextStyle(color: Colors.white)),
                        ),
                        TextButton(
                          // ignore: avoid_print
                          onPressed: () => print("two"),
                          child: const Text("Two", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0.0, 0.95),
          child: Text(
            "^ Scale Leader AND Follower ^",
            style: TextStyle(
              color: Colors.white.withOpacity(0.25),
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScaleLeaderButNotFollower extends StatefulWidget {
  const _ScaleLeaderButNotFollower({
    Key? key,
    required this.scale,
  }) : super(key: key);

  final double scale;

  @override
  State<_ScaleLeaderButNotFollower> createState() => _ScaleLeaderButNotFollowerState();
}

class _ScaleLeaderButNotFollowerState extends State<_ScaleLeaderButNotFollower> {
  final _anchor = LeaderLink();
  final _boundsKey = GlobalKey();

  late final _viewportBoundary = WidgetFollowerBoundary(_boundsKey);
  late final _aligner = CupertinoPopoverToolbarAligner(_boundsKey);
  late final _focalPoint = LeaderMenuFocalPoint(link: _anchor);

  @override
  Widget build(BuildContext context) {
    return BuildInOrder(
      children: [
        Align(
          alignment: const Alignment(0.0, 0.5),
          child: Transform.scale(
            scale: widget.scale,
            child: Leader(
              link: _anchor,
              child: Container(width: 25, height: 25, color: Colors.red),
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0.0, 0.95),
          child: Text(
            "^ Scale Leader but NOT Follower ^",
            style: TextStyle(
              color: Colors.white.withOpacity(0.25),
              fontSize: 10,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.yellow),
          ),
          child: Follower.withAligner(
            link: _anchor,
            aligner: _aligner,
            // leaderAnchor: Alignment.topCenter,
            // followerAnchor: Alignment.bottomCenter,
            // offset: Offset(0, -25),
            repaintWhenLeaderChanges: true,
            child: CupertinoPopoverToolbar(
              focalPoint: _focalPoint,
              children: [
                TextButton(
                  // ignore: avoid_print
                  onPressed: () => print("one"),
                  child: const Text("One", style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  // ignore: avoid_print
                  onPressed: () => print("two"),
                  child: const Text("Two", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ScaleFollowerButNotLeader extends StatefulWidget {
  const _ScaleFollowerButNotLeader({
    Key? key,
    required this.scale,
  }) : super(key: key);

  final double scale;

  @override
  State<_ScaleFollowerButNotLeader> createState() => _ScaleFollowerButNotLeaderState();
}

class _ScaleFollowerButNotLeaderState extends State<_ScaleFollowerButNotLeader> {
  final _anchor = LeaderLink();

  late final _aligner = CupertinoPopoverToolbarAligner();
  late final _focalPoint = LeaderMenuFocalPoint(link: _anchor);

  @override
  Widget build(BuildContext context) {
    return BuildInOrder(
      children: [
        Align(
          alignment: const Alignment(0.0, 0.5),
          child: Leader(
            link: _anchor,
            child: Container(width: 25, height: 25, color: Colors.red),
          ),
        ),
        Align(
          alignment: const Alignment(0.0, 0.95),
          child: Text(
            "^ Scale Follower but NOT Leader ^",
            style: TextStyle(
              color: Colors.white.withOpacity(0.25),
              fontSize: 10,
            ),
          ),
        ),
        Transform.scale(
          scale: widget.scale,
          child: Follower.withAligner(
            link: _anchor,
            aligner: _aligner,
            // leaderAnchor: Alignment.topCenter,
            // followerAnchor: Alignment.bottomCenter,
            // offset: Offset(0, -25),
            repaintWhenLeaderChanges: true,
            child: CupertinoPopoverToolbar(
              focalPoint: _focalPoint,
              children: [
                TextButton(
                  // ignore: avoid_print
                  onPressed: () => print("one"),
                  child: const Text("One", style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  // ignore: avoid_print
                  onPressed: () => print("two"),
                  child: const Text("Two", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
