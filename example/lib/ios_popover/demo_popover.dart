import 'package:flutter/material.dart';

import '_ios_popover_menu.dart';
import '_popover_example.dart';

class PopoverDemo extends StatefulWidget {
  const PopoverDemo({Key? key}) : super(key: key);

  @override
  State<PopoverDemo> createState() => _PopoverDemoState();
}

class _PopoverDemoState extends State<PopoverDemo> {
  late List<PopoverDemoItem> itens;
  late PopoverDemoItem _selectedItem;
  final Color targetColor = const Color(0xFFF5B6FF);

  @override
  void initState() {
    super.initState();
    itens = [
      PopoverDemoItem(
        label: 'Arrow Bottom / Left',
        builder: (context) => PopoverExample(
          arrowDirection: ArrowDirection.down,
          targetAnchor: Alignment.topCenter,
          followerAnchor: Alignment.bottomCenter,
          offset: const Offset(0, -6),
          targetBuilder: (context) => Container(
            height: 259,
            width: 306,
            color: targetColor,
          ),
          targetPosition: TargetPosition(left: 0, bottom: 0),
        ),
      ),
      PopoverDemoItem(
        label: 'Arrow Bottom / Center',
        builder: (context) => PopoverExample(
          arrowDirection: ArrowDirection.down,
          targetAnchor: Alignment.topCenter,
          followerAnchor: Alignment.bottomCenter,
          offset: const Offset(0, -6),
          targetBuilder: (context) => Container(
            height: 259,
            width: 604,
            color: targetColor,
          ),
          targetAlignment: Alignment.bottomCenter,
        ),
      ),
      PopoverDemoItem(
        label: 'Arrow Bottom / Right',
        builder: (context) => PopoverExample(
          arrowDirection: ArrowDirection.down,
          targetAnchor: Alignment.topCenter,
          followerAnchor: Alignment.bottomCenter,
          offset: const Offset(0, -6),
          targetBuilder: (context) => Container(
            height: 259,
            width: 306,
            color: targetColor,
          ),
          targetPosition: TargetPosition(right: 0, bottom: 0),
        ),
      ),
      PopoverDemoItem(
        label: 'Arrow Top / Left',
        builder: (context) => PopoverExample(
          arrowDirection: ArrowDirection.up,
          targetAnchor: Alignment.bottomCenter,
          followerAnchor: Alignment.topCenter,
          offset: const Offset(0, 6),
          targetBuilder: (context) => Container(
            height: 259,
            width: 306,
            color: targetColor,
          ),
          targetPosition: TargetPosition(left: 0, bottom: 220),
        ),
      ),
      PopoverDemoItem(
        label: 'Arrow Top / Center',
        builder: (context) => PopoverExample(
          arrowDirection: ArrowDirection.up,
          targetAnchor: Alignment.bottomCenter,
          followerAnchor: Alignment.topCenter,
          offset: const Offset(0, 6),
          targetBuilder: (context) => Center(
            child: Container(
              height: 259,
              width: 604,
              color: targetColor,
            ),
          ),
          targetPosition: TargetPosition(left: 0, right: 0, bottom: 220),
        ),
      ),
      PopoverDemoItem(
        label: 'Arrow Top / Right',
        builder: (context) => PopoverExample(
          arrowDirection: ArrowDirection.up,
          targetAnchor: Alignment.bottomCenter,
          followerAnchor: Alignment.topCenter,
          offset: const Offset(0, 6),
          targetBuilder: (context) => Center(
            child: Container(
              height: 259,
              width: 306,
              color: targetColor,
            ),
          ),
          targetPosition: TargetPosition(right: 0, bottom: 220),
        ),
      ),
      PopoverDemoItem(
        label: 'Arrow Left',
        builder: (context) => PopoverExample(
          arrowDirection: ArrowDirection.left,
          targetAnchor: Alignment.centerRight,
          followerAnchor: Alignment.centerLeft,
          offset: const Offset(6, 0),
          targetBuilder: (context) => Container(
            height: 494,
            width: 306,
            color: targetColor,
          ),
          targetPosition: TargetPosition(left: 0, bottom: 0),
        ),
      ),
      PopoverDemoItem(
        label: 'Arrow Right',
        builder: (context) => PopoverExample(
          arrowDirection: ArrowDirection.right,
          targetAnchor: Alignment.centerLeft,
          followerAnchor: Alignment.centerRight,
          offset: const Offset(-6, 0),
          targetBuilder: (context) => Container(
            height: 494,
            width: 306,
            color: targetColor,
          ),
          targetPosition: TargetPosition(right: 0, bottom: 0),
        ),
      ),
      PopoverDemoItem(
        label: 'Arrow Left Full',
        builder: (context) => PopoverExample(
          arrowDirection: ArrowDirection.left,
          targetAnchor: Alignment.centerRight,
          followerAnchor: Alignment.centerLeft,
          offset: const Offset(6, 0),
          targetBuilder: (context) => Container(
            width: 306,
            color: targetColor,
          ),
          targetPosition: TargetPosition(top: 0, bottom: 0),
        ),
      ),
      PopoverDemoItem(
        label: 'Arrow Right Full',
        builder: (context) => PopoverExample(
          arrowDirection: ArrowDirection.right,
          targetAnchor: Alignment.centerLeft,
          followerAnchor: Alignment.centerRight,
          offset: const Offset(-6, 0),
          targetBuilder: (context) => Container(
            width: 306,
            color: targetColor,
          ),
          targetPosition: TargetPosition(top: 0, bottom: 0, right: 0),
        ),
      ),
    ];
    _selectedItem = itens.first;
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
                    for (final item in itens) ...[
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
