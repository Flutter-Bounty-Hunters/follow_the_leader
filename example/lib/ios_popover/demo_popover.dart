import 'package:flutter/material.dart';
import 'package:overlord/overlord.dart';

import 'popover_example.dart';

/// Demo which shows the capabilities of the [IosPopoverMenu].
///
/// This demo includes examples of the popover pointing up, down, left and right.
///
/// It also includes a draggable example, where the user can drag the popover around the screen
/// and the popover updates the arrow direction to always point to the focal point.
class PopoverDemo extends StatefulWidget {
  const PopoverDemo({Key? key}) : super(key: key);

  @override
  State<PopoverDemo> createState() => _PopoverDemoState();
}

class _PopoverDemoState extends State<PopoverDemo> {
  late List<PopoverDemoItem> items;
  late PopoverDemoItem _selectedItem;

  @override
  void initState() {
    super.initState();
    items = [
      PopoverDemoItem(
        label: 'Pointing Up',
        builder: (context) => const PopoverExample(
          focalPoint: Offset(500, 0),
        ),
      ),
      PopoverDemoItem(
        label: 'Pointing Down',
        builder: (context) => const PopoverExample(
          focalPoint: Offset(500, 1000),
        ),
      ),
      PopoverDemoItem(
        label: 'Pointing Left',
        builder: (context) => const PopoverExample(
          focalPoint: Offset(0, 334),
        ),
      ),
      PopoverDemoItem(
        label: 'Pointing Right',
        builder: (context) => const PopoverExample(
          focalPoint: Offset(1000, 334),
        ),
      ),
      PopoverDemoItem(
        label: 'Draggable',
        builder: (context) => const DraggableDemo(
          focalPoint: Offset(500, 334),
        ),
      ),
    ];
    _selectedItem = items.first;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Row(
        children: [
          Expanded(
            child: _selectedItem.builder(context),
          ),
          Container(
            color: Colors.redAccent,
            height: double.infinity,
            width: 250,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 48),
                    for (final item in items) ...[
                      _buildDemoButton(item),
                      const SizedBox(height: 24),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoButton(PopoverDemoItem item) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedItem = item;
          });
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        child: Text(item.label),
      ),
    );
  }
}

class PopoverDemoItem {
  final String label;
  final WidgetBuilder builder;

  PopoverDemoItem({
    required this.label,
    required this.builder,
  });
}

class DraggableDemo extends StatefulWidget {
  const DraggableDemo({
    super.key,
    required this.focalPoint,
  });

  final Offset focalPoint;

  @override
  State<DraggableDemo> createState() => _DraggableDemoState();
}

class _DraggableDemoState extends State<DraggableDemo> {
  Offset _offset = const Offset(50, 50);

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _offset += details.delta;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: widget.focalPoint.dx,
          top: widget.focalPoint.dy,
          child: Container(
            color: Colors.red,
            height: 10,
            width: 10,
          ),
        ),
        Positioned(
          left: _offset.dx,
          top: _offset.dy,
          child: GestureDetector(
            onPanUpdate: _onPanUpdate,
            child: CupertinoPopoverMenu(
              globalFocalPoint: widget.focalPoint,
              padding: const EdgeInsets.all(12.0),
              arrowBaseWidth: 21,
              arrowLength: 20,
              backgroundColor: const Color(0xFF474747),
              child: const SizedBox(
                width: 254,
                height: 159,
                child: Center(
                  child: Text(
                    'Popover Content',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
