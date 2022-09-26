import 'package:example/ios_popover/_ios_toolbar.dart';
import 'package:flutter/material.dart';

import '_toolbar_example.dart';

class ToolbarDemo extends StatefulWidget {
  const ToolbarDemo({Key? key}) : super(key: key);

  @override
  State<ToolbarDemo> createState() => _ToolbarDemoState();
}

class _ToolbarDemoState extends State<ToolbarDemo> {
  late List<ToolbarDemoItem> itens;
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

    itens = [
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
