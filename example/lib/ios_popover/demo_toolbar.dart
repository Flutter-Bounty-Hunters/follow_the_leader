import 'package:example/ios_popover/ios_toolbar.dart';
import 'package:flutter/material.dart';

import 'toolbar_example.dart';

/// Demo which shows the capabilities of the [IosToolbar].
///
/// This demo includes examples of the toolbar pointing up and down,
/// menus with many pages, including an auto-paginated and a manually paginated menu.
///
/// It also includes a draggable example, where the user can drag the toolbar around the screen
/// and the toolbar updates the arrow direction to always point to the focal point.
class ToolbarDemo extends StatefulWidget {
  const ToolbarDemo({Key? key}) : super(key: key);

  @override
  State<ToolbarDemo> createState() => _ToolbarDemoState();
}

class _ToolbarDemoState extends State<ToolbarDemo> {
  late List<ToolbarDemoItem> items;
  late ToolbarDemoItem _selectedItem;

  final smallList = const [
    IosMenuItem(label: 'Style'),
    IosMenuItem(label: 'Duplicate'),
    IosMenuItem(label: 'Cut'),
    IosMenuItem(label: 'Copy'),
    IosMenuItem(label: 'Paste'),
  ];

  final longList = const [
    IosMenuItem(label: 'Style'),
    IosMenuItem(label: 'Duplicate'),
    IosMenuItem(label: 'Cut'),
    IosMenuItem(label: 'Copy'),
    IosMenuItem(label: 'Paste'),
    IosMenuItem(label: 'Delete'),
    IosMenuItem(label: 'Long Thing 1'),
    IosMenuItem(label: 'Long Thing 2'),
    IosMenuItem(label: 'Long Thing 3'),
    IosMenuItem(label: 'Long Thing 4'),
    IosMenuItem(label: 'Long Thing 5'),
  ];

  @override
  void initState() {
    super.initState();

    items = [
      ToolbarDemoItem(
        label: 'Pointing Up',
        builder: (context) => ToolbarExample(
          focalPoint: const Offset(600, 0),
          children: smallList,
        ),
      ),
      ToolbarDemoItem(
        label: 'Pointing Down',
        builder: (context) => ToolbarExample(
          focalPoint: const Offset(600, 1000),
          children: smallList,
        ),
      ),
      ToolbarDemoItem(
        label: 'Auto Paginated',
        builder: (context) => ToolbarExample(
          focalPoint: const Offset(600, 1000),
          constraints: const BoxConstraints(maxWidth: 300),
          children: longList,
        ),
      ),
      ToolbarDemoItem(
        label: 'Manually Paginated',
        builder: (context) => ToolbarExample(
          focalPoint: const Offset(600, 1000),
          pages: [
            MenuPage(
              items: const [
                IosMenuItem(label: 'Style'),
                IosMenuItem(label: 'Duplicate'),
              ],
            ),
            MenuPage(
              items: const [
                IosMenuItem(label: 'Cut'),
                IosMenuItem(label: 'Copy'),
                IosMenuItem(label: 'Paste'),
                IosMenuItem(label: 'Delete'),
              ],
            ),
            MenuPage(
              items: const [
                IosMenuItem(label: 'Page 3 Copy'),
                IosMenuItem(label: 'Page 3 Paste'),
                IosMenuItem(label: 'Page 3 Delete'),
              ],
            ),
          ],
        ),
      ),
      ToolbarDemoItem(
        label: 'Draggable',
        builder: (context) => DraggableDemo(
          focalPoint: const Offset(500, 334),
          children: smallList,
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

  Widget _buildDemoButton(ToolbarDemoItem item) {
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

class ToolbarDemoItem {
  final String label;
  final WidgetBuilder builder;

  ToolbarDemoItem({
    required this.label,
    required this.builder,
  });
}

class DraggableDemo extends StatefulWidget {
  const DraggableDemo({
    super.key,
    required this.focalPoint,
    required this.children,
  });

  final Offset focalPoint;
  final List<Widget> children;

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
            child: IosToolbar(
              globalFocalPoint: widget.focalPoint,
              padding: const EdgeInsets.all(12.0),
              arrowBaseWidth: 21,
              arrowLength: 20,
              backgroundColor: const Color(0xFF474747),
              children: widget.children,
            ),
          ),
        ),
      ],
    );
  }
}
