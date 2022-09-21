import 'package:example/ios_popover/_ios_popover_menu.dart';
import 'package:example/ios_popover/_ios_toolbar.dart';
import 'package:flutter/material.dart';

class ToolbarExample extends StatelessWidget {
  const ToolbarExample({
    super.key,
    required this.arrowDirection,
    this.constraints,
    this.pages,
    this.focalPoint,
    this.children,
  })  : assert(children != null || pages != null, 'You should provide either children or pages'),
        assert(children == null || pages == null, "You can't provide both children and pages");

  final ArrowDirection arrowDirection;
  final BoxConstraints? constraints;
  final List<MenuPage>? pages;
  final double? focalPoint;
  final List<Widget>? children;

  @override
  Widget build(BuildContext context) {    
    final toolbar = children != null
        ? IosToolbar(
            arrowDirection: arrowDirection,
            radius: const Radius.circular(12),
            arrowWidth: 18,
            arrowLength: 12,
            arrowFocalPoint: focalPoint,
            children: children!,
          )
        : IosToolbar.paginated(
            arrowDirection: arrowDirection,
            radius: const Radius.circular(12),
            arrowWidth: 18,
            arrowLength: 12,
            arrowFocalPoint: focalPoint,
            pages: pages,
          );

    final result = constraints != null
        ? ConstrainedBox(
            constraints: constraints!,
            child: toolbar,
          )
        : toolbar;

    return Center(
      child: result,
    );
  }
}

class IosMenuItem extends StatelessWidget {
  const IosMenuItem({Key? key, required this.label}) : super(key: key);

  final String label;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}
