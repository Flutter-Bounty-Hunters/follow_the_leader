import 'package:example/ios_popover/ios_toolbar.dart';
import 'package:flutter/material.dart';

/// An example of an [IosToolbar] usage.
///
/// When [constraints] are provided, the toolbar is displayed inside a [ConstrainedBox].
///
/// Use [pages] to manually configure the menu pages.
///
/// Use [children] to let the toolbar compute the pages based on the available width.
class ToolbarExample extends StatelessWidget {
  const ToolbarExample({
    super.key,
    required this.focalPoint,
    this.constraints,
    this.pages,
    this.children,
  })  : assert(children != null || pages != null, 'You should provide either children or pages'),
        assert(children == null || pages == null, "You can't provide both children and pages");

  final BoxConstraints? constraints;
  final List<MenuPage>? pages;
  final Offset focalPoint;
  final List<Widget>? children;

  @override
  Widget build(BuildContext context) {
    final toolbar = children != null
        ? IosToolbar(
            globalFocalPoint: focalPoint,
            children: children!,
          )
        : IosToolbar.paginated(
            globalFocalPoint: focalPoint,
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
