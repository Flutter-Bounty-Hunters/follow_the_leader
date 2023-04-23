import 'package:flutter/material.dart';
import 'package:follow_the_leader/follow_the_leader.dart';
import 'package:overlord/follow_the_leader.dart';
import 'package:overlord/overlord.dart';
import 'package:page_list_viewport/page_list_viewport.dart';

class PageListViewportDemo extends StatefulWidget {
  const PageListViewportDemo({Key? key}) : super(key: key);

  @override
  State<PageListViewportDemo> createState() => _PageListViewportDemoState();
}

class _PageListViewportDemoState extends State<PageListViewportDemo> with SingleTickerProviderStateMixin {
  late final PageListViewportController _controller;
  final _leaderLink = LeaderLink();

  late final _aligner = CupertinoPopoverToolbarAligner();
  late final _focalPoint = LeaderMenuFocalPoint(link: _leaderLink);

  @override
  void initState() {
    super.initState();
    _controller = PageListViewportController(vsync: this);
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
          PageListViewportGestures(
            controller: _controller,
            child: PageListViewport(
              controller: _controller,
              naturalPageSize: const Size(1920, 2400),
              pageCount: 10,
              builder: (context, pageIndex) {
                final image = Image.asset(
                  "assets/images/example-photo-1.jpeg",
                  fit: BoxFit.contain,
                );

                if (pageIndex != 1) {
                  return image;
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final size = Size(constraints.maxWidth, constraints.maxHeight);

                    return Stack(
                      children: [
                        Positioned.fill(
                          child: image,
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
                );
              },
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
