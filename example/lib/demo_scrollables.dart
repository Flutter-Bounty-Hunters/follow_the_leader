import 'package:flutter/material.dart';
import 'package:follow_the_leader/follow_the_leader.dart';
import 'package:overlord/follow_the_leader.dart';
import 'package:overlord/overlord.dart';

/// Demonstrates that leaders and followers appear at expected locations,
/// even when they sit within a scrolling viewport.
class ScrollablesDemo extends StatefulWidget {
  const ScrollablesDemo({Key? key}) : super(key: key);

  @override
  State<ScrollablesDemo> createState() => _ScrollablesDemoState();
}

class _ScrollablesDemoState extends State<ScrollablesDemo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF222222),
      child: const SafeArea(
        child: Row(
          children: [
            Expanded(child: _VerticalList()),
            Expanded(
              child: Column(
                children: [
                  Expanded(child: _HorizontalList()),
                  Spacer(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _VerticalList extends StatefulWidget {
  const _VerticalList({Key? key}) : super(key: key);

  @override
  State<_VerticalList> createState() => _VerticalListState();
}

class _VerticalListState extends State<_VerticalList> {
  final _boundsKey = GlobalKey();
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: LayoutBuilder(builder: (context, constraints) {
            return ListView.builder(
              controller: _scrollController,
              itemBuilder: (context, index) {
                if (index == 1) {
                  return _LeaderAndFollowerListItem(
                    height: constraints.maxHeight,
                    recalculateGlobalOffset: _scrollController,
                    boundsKey: _boundsKey,
                  );
                }

                return _EmptyListItem(height: constraints.maxHeight);
              },
            );
          }),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Padding(
              padding: const EdgeInsets.all(100),
              child: DecoratedBox(
                key: _boundsKey,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HorizontalList extends StatefulWidget {
  const _HorizontalList({Key? key}) : super(key: key);

  @override
  State<_HorizontalList> createState() => _HorizontalListState();
}

class _HorizontalListState extends State<_HorizontalList> {
  final _boundsKey = GlobalKey();
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: LayoutBuilder(builder: (context, constraints) {
            return ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                if (index == 1) {
                  return _LeaderAndFollowerListItem(
                    width: constraints.maxWidth,
                    recalculateGlobalOffset: _scrollController,
                    boundsKey: _boundsKey,
                  );
                }

                return _EmptyListItem(
                  width: constraints.maxWidth,
                );
              },
            );
          }),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Padding(
              padding: const EdgeInsets.all(100),
              child: DecoratedBox(
                key: _boundsKey,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyListItem extends StatelessWidget {
  const _EmptyListItem({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
          border: Border.all(color: Colors.black, width: 1),
        ),
      ),
    );
  }
}

class _LeaderAndFollowerListItem extends StatefulWidget {
  const _LeaderAndFollowerListItem({
    Key? key,
    this.width,
    this.height,
    required this.recalculateGlobalOffset,
    required this.boundsKey,
  }) : super(key: key);

  final double? width;
  final double? height;
  final Listenable recalculateGlobalOffset;
  final GlobalKey boundsKey;

  @override
  State<_LeaderAndFollowerListItem> createState() => _LeaderAndFollowerListItemState();
}

class _LeaderAndFollowerListItemState extends State<_LeaderAndFollowerListItem> {
  final _anchor = LeaderLink();

  late final FollowerBoundary? _viewportBoundary;
  late final FollowerAligner _aligner;
  late final _focalPoint = LeaderMenuFocalPoint(link: _anchor);

  @override
  void initState() {
    super.initState();

    _aligner = CupertinoPopoverToolbarAligner(widget.boundsKey);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _viewportBoundary = WidgetFollowerBoundary(
      devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
      boundaryKey: widget.boundsKey,
    );
  }

  @override
  void didUpdateWidget(_LeaderAndFollowerListItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.boundsKey != oldWidget.boundsKey) {
      _viewportBoundary = WidgetFollowerBoundary(
        devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
        boundaryKey: widget.boundsKey,
      );
      _aligner = CupertinoPopoverToolbarAligner(widget.boundsKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: BuildInOrder(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Center(
              child: Leader(
                link: _anchor,
                recalculateGlobalOffset: widget.recalculateGlobalOffset,
                child: Container(width: 25, height: 25, color: Colors.red),
              ),
            ),
          ),
          SizedBox.expand(
            child: DecoratedBox(
              decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.red)),
              child: FollowerFadeOutBeyondBoundary(
                boundary: _viewportBoundary,
                link: _anchor,
                child: Follower.withAligner(
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
