import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A menu container which simulates an iOS popover.
///
/// Given a [globalFocalPoint], this widget draws an arrow which
/// points to the direction between this widget and the [globalFocalPoint].
class IosPopoverMenu extends SingleChildRenderObjectWidget {
  const IosPopoverMenu({
    super.key,
    required this.globalFocalPoint,
    this.radius = const Radius.circular(12),
    this.arrowBaseWidth = 18.0,
    this.arrowLength = 12.0,
    this.allowHorizontalArrow = true,
    this.backgroundColor = const Color(0xFF474747),
    this.padding,
    super.child,
  });

  /// Radius of the corners.
  final Radius radius;

  /// Base of the arrow in pixels.
  ///
  /// If the arrow points up or down, [arrowBaseWidth] represents the number of
  /// pixels in the x-axis. Otherwise, it represents the number of pixels
  /// in the y-axis.
  final double arrowBaseWidth;

  /// Extent of the arrow in pixels.
  ///
  /// If the arrow points up or down, [arrowLength] represents the number of
  /// pixels in the y-axis. Otherwise, it represents the number of pixels
  /// in the x-axis.
  final double arrowLength;

  /// Padding around the popover content.
  final EdgeInsets? padding;

  /// Color of the menu background.
  final Color backgroundColor;

  /// Global offset which the arrow should point to.
  ///
  /// If the arrow can't point to [globalFocalPoint], e.g.,
  /// the arrow points up and `globalFocalPoint.dx` is outside
  /// the menu bounds, then the the arrow will point towards
  /// [globalFocalPoint] as much as possible.
  final Offset globalFocalPoint;

  /// Indicates wether or not the arrow can point to a horizontal direction.
  ///
  /// When `false`, the arrow only points up or down.
  final bool allowHorizontalArrow;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderPopover(
      radius: radius,
      arrowWidth: arrowBaseWidth,
      arrowLength: arrowLength,
      padding: padding,
      backgroundColor: backgroundColor,
      focalPoint: globalFocalPoint,
      allowHorizontalArrow: allowHorizontalArrow,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderPopover renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..radius = radius
      ..arrowBaseWidth = arrowBaseWidth
      ..arrowLength = arrowLength
      ..padding = padding
      ..focalPoint = globalFocalPoint
      ..backgroundColor = backgroundColor
      ..allowHorizontalArrow = allowHorizontalArrow;
  }
}

class RenderPopover extends RenderShiftedBox {
  RenderPopover({
    required Radius radius,
    required double arrowWidth,
    required double arrowLength,
    required Color backgroundColor,
    required Offset focalPoint,
    bool allowHorizontalArrow = true,
    EdgeInsets? padding,
    RenderBox? child,
  })  : _radius = radius,
        _arrowBaseWidth = arrowWidth,
        _arrowLength = arrowLength,
        _padding = padding,
        _backgroundColor = backgroundColor,
        _backgroundPaint = Paint()..color = backgroundColor,
        _focalPoint = focalPoint,
        _allowHorizontalArrow = allowHorizontalArrow,
        super(child);

  Radius _radius;
  Radius get radius => _radius;
  set radius(Radius value) {
    if (_radius != value) {
      _radius = value;
      markNeedsLayout();
    }
  }

  double _arrowBaseWidth;
  double get arrowBaseWidth => _arrowBaseWidth;
  set arrowBaseWidth(double value) {
    if (_arrowBaseWidth != value) {
      _arrowBaseWidth = value;
      markNeedsLayout();
    }
  }

  double _arrowLength;
  double get arrowLength => _arrowLength;
  set arrowLength(double value) {
    if (_arrowLength != value) {
      _arrowLength = value;
      markNeedsLayout();
    }
  }

  Offset _focalPoint;
  Offset get focalPoint => _focalPoint;
  set focalPoint(Offset value) {
    if (_focalPoint != value) {
      _focalPoint = value;
      markNeedsLayout();
    }
  }

  EdgeInsets? _padding;
  EdgeInsets? get padding => _padding;
  set padding(EdgeInsets? value) {
    if (_padding != value) {
      _padding = value;
      markNeedsLayout();
    }
  }

  Color _backgroundColor;
  Color get backgroundColor => _backgroundColor;
  set backgroundColor(Color value) {
    if (value != _backgroundColor) {
      _backgroundColor = value;
      _backgroundPaint = Paint()..color = _backgroundColor;
      markNeedsPaint();
    }
  }

  bool _allowHorizontalArrow;
  bool get allowHorizontalArrow => _allowHorizontalArrow;
  set allowHorizontalArrow(bool value) {
    if (value != _allowHorizontalArrow) {
      _allowHorizontalArrow = value;
      markNeedsLayout();
    }
  }

  late Paint _backgroundPaint;

  @override
  void performLayout() {
    // We need to know our offset in order to calculate the arrow direction
    // and we only know our offset at paint phase.
    // Therefore, we need to reserve space for the arrow in both axes.
    final reservedSize = Size(
      (padding?.horizontal ?? 0) + arrowLength,
      (padding?.vertical ?? 0) + arrowLength,
    );

    // The child cannot take the size reserved for padding or
    // for displaying the arrow.
    final innerConstraints = constraints.enforce(
      BoxConstraints(
        maxHeight: constraints.maxHeight - reservedSize.height,
        maxWidth: constraints.maxWidth - reservedSize.width,
      ),
    );

    child!.layout(innerConstraints, parentUsesSize: true);

    size = constraints.constrain(Size(
      reservedSize.width + child!.size.width,
      reservedSize.height + child!.size.height,
    ));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final localFocalPoint = globalToLocal(focalPoint);

    final direction = _computeArrowDirection(offset & size, focalPoint);
    final arrowCenter = _computeArrowCenter(direction, localFocalPoint);
    final contentOffset = _computeContentOffset(direction, arrowLength);

    final path = _buildPath(direction, arrowCenter);

    context.canvas.drawPath(path.shift(offset), _backgroundPaint);

    if (child != null) {
      context.paintChild(child!, offset + contentOffset);
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (hitTestChildren(result, position: position)) {
      return true;
    }
    // Allow hit-testing around the content, e.g, we might have padding and
    // the user is trying to drag using the padding area.
    final rect = Offset.zero & size;
    return rect.contains(position);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final direction = _computeArrowDirection(Offset.zero & size, focalPoint);
    final contentOffset = _computeContentOffset(direction, arrowLength);

    return result.addWithPaintOffset(
      offset: contentOffset,
      position: position,
      hitTest: (BoxHitTestResult result, Offset transformed) {
        assert(transformed == position - contentOffset);
        return child?.hitTest(result, position: transformed) ?? false;
      },
    );
  }

  /// Builds the path used to paint the menu.
  Path _buildPath(ArrowDirection arrowDirection, double arrowCenter) {
    final halfOfBase = arrowBaseWidth / 2;

    // Adjust the rect to leave space for the arrow.
    // During layout, we reserve space for the arrow in both x and y axis.
    final contentRect = Rect.fromLTWH(
      arrowDirection == ArrowDirection.left ? arrowLength : 0,
      arrowDirection == ArrowDirection.up ? arrowLength : 0,
      size.width - arrowLength,
      size.height - arrowLength,
    );

    Path path = Path()..addRRect(RRect.fromRectAndRadius(contentRect, radius));

    // Add the arrow points.
    if (arrowDirection == ArrowDirection.left) {
      path
        ..moveTo(contentRect.centerLeft.dx, arrowCenter - halfOfBase)
        ..relativeLineTo(-arrowLength, halfOfBase)
        ..relativeLineTo(arrowLength, halfOfBase);
    } else if (arrowDirection == ArrowDirection.right) {
      path
        ..moveTo(contentRect.centerRight.dx, arrowCenter - halfOfBase)
        ..relativeLineTo(arrowLength, halfOfBase)
        ..relativeLineTo(-arrowLength, halfOfBase);
    } else if (arrowDirection == ArrowDirection.up) {
      path
        ..moveTo(arrowCenter - halfOfBase, contentRect.topCenter.dy)
        ..relativeLineTo(halfOfBase, -arrowLength)
        ..relativeLineTo(halfOfBase, arrowLength);
    } else {
      path
        ..moveTo(arrowCenter - halfOfBase, contentRect.bottomCenter.dy)
        ..relativeLineTo(halfOfBase, arrowLength)
        ..relativeLineTo(halfOfBase, -arrowLength);
    }

    path.close();

    return path;
  }

  /// Computes the direction where the arrow should point to.
  ArrowDirection _computeArrowDirection(Rect menuRect, Offset globalFocalPoint) {
    if ((globalFocalPoint.dx >= menuRect.left && globalFocalPoint.dx <= menuRect.right) || !allowHorizontalArrow) {
      // The focal point is within our horizontal bounds or we don't allow the arrow to point left or right.
      if (globalFocalPoint.dy < menuRect.top) {
        return ArrowDirection.up;
      }
      return ArrowDirection.down;
    } else {
      if (globalFocalPoint.dx < menuRect.left) {
        return ArrowDirection.left;
      }
      return ArrowDirection.right;
    }
  }

  /// Computes the point where the arrow should be centered around.
  ///
  /// This point can be on the x or y axis, depending on the [direction].
  double _computeArrowCenter(ArrowDirection direction, Offset focalPoint) {
    final desiredFocalPoint = _arrowIsVertical(direction) //
        ? focalPoint.dx
        : focalPoint.dy;

    return _constrainFocalPoint(desiredFocalPoint, direction);
  }

  /// Computes the (x, y) offset of the menu content.
  ///
  /// When [direction] is up or left, the content needs to be shifted
  /// to leave space for the arrow.
  Offset _computeContentOffset(ArrowDirection direction, double arrowLength) {
    return Offset(
      (padding?.left ?? 0) + (direction == ArrowDirection.left ? arrowLength : 0.0),
      (padding?.top ?? 0) + (direction == ArrowDirection.up ? arrowLength : 0.0),
    );
  }

  /// Indicates whether or not the arrow points to a vertical direction.
  bool _arrowIsVertical(ArrowDirection arrowDirection) =>
      arrowDirection == ArrowDirection.up || arrowDirection == ArrowDirection.down;

  /// Minimum focal point for the given [arrowDirection].
  double _minArrowFocalPoint(ArrowDirection arrowDirection) => _arrowIsVertical(arrowDirection)
      ? _minArrowHorizontalCenter(arrowDirection)
      : _minArrowVerticalCenter(arrowDirection);

  /// Maximum focal point for the given [arrowDirection].
  double _maxArrowFocalPoint(ArrowDirection arrowDirection) => _arrowIsVertical(arrowDirection)
      ? _maxArrowHorizontalCenter(arrowDirection)
      : _maxArrowVerticalCenter(arrowDirection);

  /// Minimum distance on the x-axis which the arrow can be displayed.
  double _minArrowHorizontalCenter(ArrowDirection arrowDirection) => (radius.x + arrowBaseWidth / 2);

  /// Maximum distance on the x-axis which the arrow can be displayed.
  double _maxArrowHorizontalCenter(ArrowDirection arrowDirection) =>
      (size.width - radius.x - arrowBaseWidth - arrowLength / 2);

  /// Minimum distance on the y-axis which the arrow can be displayed.
  double _minArrowVerticalCenter(ArrowDirection arrowDirection) => (radius.y + arrowBaseWidth / 2);

  /// Maximum distance on the y-axis which the arrow can be displayed.
  double _maxArrowVerticalCenter(ArrowDirection arrowDirection) =>
      (size.height - radius.y - arrowLength - (arrowBaseWidth / 2));

  /// Constrain the focal point to be inside the menu bounds.
  double _constrainFocalPoint(double desiredFocalPoint, ArrowDirection arrowDirection) {
    return min(max(desiredFocalPoint, _minArrowFocalPoint(arrowDirection)), _maxArrowFocalPoint(arrowDirection));
  }
}

/// Direction where a arrow points to.
enum ArrowDirection {
  up,
  down,
  left,
  right,
}
