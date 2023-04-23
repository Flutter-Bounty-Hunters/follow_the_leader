import 'package:flutter/material.dart';
import 'package:follow_the_leader/follow_the_leader.dart';
import 'package:overlord/follow_the_leader.dart';
import 'package:overlord/overlord.dart';

class InteractiveViewerDemo extends StatefulWidget {
  const InteractiveViewerDemo({Key? key}) : super(key: key);

  @override
  State<InteractiveViewerDemo> createState() => _InteractiveViewerDemoState();
}

class _InteractiveViewerDemoState extends State<InteractiveViewerDemo> with SingleTickerProviderStateMixin {
  final _leaderLink = LeaderLink();
  late final TransformationController _controller;

  late final _aligner = CupertinoPopoverToolbarAligner();
  late final _focalPoint = LeaderMenuFocalPoint(link: _leaderLink);

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BuildInOrder(
        children: [
          InteractiveViewer(
            minScale: 0.1,
            maxScale: 10.0,
            constrained: false,
            child: SizedBox(
              width: 1920,
              height: 2400,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(constraints.maxWidth, constraints.maxHeight);

                  return Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          "assets/images/example-photo-1.jpeg",
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        left: size.width * 0.181,
                        top: size.height * 0.322,
                        child: FractionalTranslation(
                          translation: const Offset(-0.5, -0.5),
                          child: Leader(
                            link: _leaderLink,
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Follower.withAligner(
            link: _leaderLink,
            aligner: _aligner,
            repaintWhenLeaderChanges: true,
            showDebugPaint: false,
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
                TextButton(
                  // ignore: avoid_print
                  onPressed: () => print("three"),
                  child: const Text("Three", style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  // ignore: avoid_print
                  onPressed: () => print("four"),
                  child: const Text("Four", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
