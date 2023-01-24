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
  final _anchor = LeaderLink();
  final _boundsKey = GlobalKey();

  late final _viewportBoundary = WidgetFollowerBoundary(_boundsKey);
  late final _aligner = CupertinoPopoverToolbarAligner(_boundsKey);
  late final _focalPoint = LeaderMenuFocalPoint(link: _anchor);

  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF222222),
      child: Stack(
        children: [
          Positioned.fill(
            child: Transform.scale(
              scale: _scale,
              child: BuildInOrder(
                children: [
                  Center(
                    child: Leader(
                      link: _anchor,
                      child: Container(width: 25, height: 25, color: Colors.red),
                    ),
                  ),
                  Follower.withAligner(
                    link: _anchor,
                    aligner: _aligner,
                    boundary: _viewportBoundary,
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
          Positioned.fill(
            child: Align(
              alignment: const Alignment(0.0, 0.95),
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
          ),
        ],
      ),
    );
  }
}
