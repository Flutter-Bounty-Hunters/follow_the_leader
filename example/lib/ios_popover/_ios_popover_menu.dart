import 'dart:math';

import 'package:flutter/material.dart';

class IosPopoverMenu extends StatelessWidget {
  const IosPopoverMenu({
    super.key,
    this.radius = const Radius.circular(12),
    this.arrowWidth = 18.0,
    this.arrowLength = 12.0,
    required this.arrowDirection,
    this.backgroundColor = const Color(0xFF474747),
    this.padding = EdgeInsets.zero,
    this.arrowFocalPoint,
    required this.child,
  });

  /// Radius of the decoration corners.
  final Radius radius;

  /// Extent of the arrow.
  final double arrowLength;

  /// Width of the arrow.
  final double arrowWidth;

  /// Direction where the arrow points to.
  final ArrowDirection arrowDirection;

  /// Padding around the popover content.
  final EdgeInsets padding;

  /// Color of the decoration.
  final Color backgroundColor;

  /// Center point of the arrow.
  ///
  /// Defaults to the center of the axis.
  final double? arrowFocalPoint;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: _IosMenuShapeBorder(
          arrowDirection: arrowDirection,
          arrowFocalPoint: arrowFocalPoint,
          arrowLength: arrowLength,
          arrowWidth: arrowWidth,
          padding: padding,
          radius: radius,
        ),
      ),
      child: Padding(
        padding: _getArrowPadding(),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }

  /// Returns the padding needed to leave space for the arrow.
  EdgeInsets _getArrowPadding() {
    return EdgeInsets.fromLTRB(
      arrowDirection == ArrowDirection.left ? arrowLength : 0,
      arrowDirection == ArrowDirection.up ? arrowLength : 0,
      arrowDirection == ArrowDirection.right ? arrowLength : 0,
      arrowDirection == ArrowDirection.down ? arrowLength : 0,
    );
  }
}

class _IosMenuShapeBorder extends ShapeBorder {
  const _IosMenuShapeBorder({
    required this.radius,
    required this.arrowWidth,
    required this.arrowLength,
    required this.arrowDirection,
    required this.padding,
    this.arrowFocalPoint,
  });

  final Radius radius;
  final double arrowWidth;
  final double arrowLength;
  final ArrowDirection arrowDirection;
  final EdgeInsets padding;
  final double? arrowFocalPoint;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return _IosDecorationPathBuilder(
      size: rect.size,
      arrowDirection: arrowDirection,
      arrowLength: arrowLength,
      arrowWidth: arrowWidth,
      radius: radius,
      arrowFocalPoint: arrowFocalPoint,
    ).build().shift(Offset(rect.left, rect.top));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}

/// Builds a path used to paint an iOS popup menu decoration.
class _IosDecorationPathBuilder {
  _IosDecorationPathBuilder({
    required this.size,
    required this.arrowLength,
    required this.arrowWidth,
    required this.arrowDirection,
    required this.radius,
    this.arrowFocalPoint,
  });

  final Size size;
  final double arrowLength;
  final double arrowWidth;
  final ArrowDirection arrowDirection;
  final Radius radius;
  final double? arrowFocalPoint;

  Path build() {
    // Width of each side of the arrow.
    final arrowStep = arrowWidth / 2;

    // If a focal point is given, constrain it to ensure
    // it won't exceed the width of the menu.
    final effectiveFocalPoint = arrowFocalPoint != null //
        ? _constrainFocalPoint(arrowFocalPoint!)
        : _defaultArrowFocalPoint;

    // Adjust the rect to leave space for the arrow.
    final contentRect = Rect.fromLTRB(
      arrowDirection == ArrowDirection.left ? arrowLength : 0,
      arrowDirection == ArrowDirection.up ? arrowLength : 0,
      size.width - (arrowDirection == ArrowDirection.right ? arrowLength : 0),
      size.height - (arrowDirection == ArrowDirection.down ? arrowLength : 0),
    );

    Path path = Path()..addRRect(RRect.fromRectAndRadius(contentRect, radius));

    // Add the arrow points.
    if (arrowDirection == ArrowDirection.left) {
      path
        ..moveTo(contentRect.centerLeft.dx, effectiveFocalPoint - arrowStep)
        ..relativeLineTo(-arrowLength, arrowStep)
        ..relativeLineTo(arrowLength, arrowStep);
    } else if (arrowDirection == ArrowDirection.right) {
      path
        ..moveTo(contentRect.centerRight.dx, effectiveFocalPoint - arrowStep)
        ..relativeLineTo(arrowLength, arrowStep)
        ..relativeLineTo(-arrowLength, arrowStep);
    } else if (arrowDirection == ArrowDirection.up) {
      path
        ..moveTo(effectiveFocalPoint - arrowStep, contentRect.topCenter.dy)
        ..relativeLineTo(arrowStep, -arrowLength)
        ..relativeLineTo(arrowStep, arrowLength);
    } else {
      path
        ..moveTo(effectiveFocalPoint - arrowStep, contentRect.bottomCenter.dy)
        ..relativeLineTo(arrowStep, arrowLength)
        ..relativeLineTo(arrowStep, -arrowLength);
    }

    path.close();

    return path;
  }

  /// Indicates whether or not the arrow points to a vertical direction.
  bool get _arrowIsVertical => arrowDirection == ArrowDirection.up || arrowDirection == ArrowDirection.down;

  /// Default focal point according the arrow direction.
  double get _defaultArrowFocalPoint => _arrowIsVertical ? size.width / 2.0 : size.height / 2.0;

  /// Minimum focal point according the arrow direction.
  double get _minArrowFocalPoint => _arrowIsVertical ? _minArrowHorizontalCenter : _minArrowVerticalCenter;

  /// Maximum focal point according the arrow direction.
  double get _maxArrowFocalPoint => _arrowIsVertical ? _maxArrowHorizontalCenter : _maxArrowVerticalCenter;

  /// Minimum distance on the x-axis which the arrow can be displayed.
  double get _minArrowHorizontalCenter => (radius.x + arrowWidth / 2);

  /// Maximum distance on the x-axis which the arrow can be displayed.
  double get _maxArrowHorizontalCenter => (size.width - radius.x - arrowWidth / 2);

  /// Minimum distance on the y-axis which the arrow can be displayed.
  double get _minArrowVerticalCenter => (radius.y + arrowWidth / 2);

  /// Maximum distance on the y-axis which the arrow can be displayed.
  double get _maxArrowVerticalCenter => (size.height - radius.y - arrowWidth / 2);

  /// Constrain the focal point to be inside the decoration bounds.
  double _constrainFocalPoint(double desiredFocalPoint) {
    return min(max(desiredFocalPoint, _minArrowFocalPoint), _maxArrowFocalPoint);
  }
}

/// Direction where a arrow points to.
enum ArrowDirection {
  up,
  down,
  left,
  right,
}
