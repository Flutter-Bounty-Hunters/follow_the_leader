import 'package:flutter/material.dart';

import '_popover_example.dart';

class PopoverDemo extends StatefulWidget {
  const PopoverDemo({Key? key}) : super(key: key);

  @override
  State<PopoverDemo> createState() => _PopoverDemoState();
}

class _PopoverDemoState extends State<PopoverDemo> {
  late List<PopoverDemoItem> itens;
  late PopoverDemoItem _selectedItem;

  @override
  void initState() {
    super.initState();
    itens = [
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
