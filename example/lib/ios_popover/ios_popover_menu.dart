import 'dart:math';

import 'package:example/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:follow_the_leader/follow_the_leader.dart';

/// Aligns the menu `Follower` with a `Leader` widget.
///
/// We use this method in a `Follower.withDynamics` so that we can flip the menu
/// from one side of the `Leader` to the other when we get close to the screen boundary.
FollowerAlignment popoverMenuAligner(
    Rect globalLeaderRect, Size followerSize, Size bounds, FollowerAlignment previousFollowerAlignment) {
  late FollowerAlignment alignment;
  if (globalLeaderRect.right + followerSize.width + _minimumDistanceFromEdge >= bounds.width) {
    appLog.info(" - follower is too far to the right, switching to left");
    // The follower hit the minimum distance. Invert the follower position.
    alignment = const FollowerAlignment(
      leaderAnchor: Alignment.centerLeft,
      followerAnchor: Alignment.centerRight,
      followerOffset: Offset(-20, 0),
    );
  } else if (globalLeaderRect.left - followerSize.width - _minimumDistanceFromEdge < 0) {
    appLog.info(" - follower is too far to the left, switching to right");
    // The follower hit the minimum distance. Invert the follower position.
    alignment = const FollowerAlignment(
      leaderAnchor: Alignment.centerRight,
      followerAnchor: Alignment.centerLeft,
      followerOffset: Offset(20, 0),
    );
  } else {
    // We're not too far to the left or the right. Keep us wherever we were before.
    alignment = previousFollowerAlignment;
  }

  return alignment;
}

const double _minimumDistanceFromEdge = 16;

/// A menu container which simulates an iOS popover.
///
/// Given a [globalFocalPoint], this widget draws an arrow which
/// points to the direction between this widget and the [globalFocalPoint].
class IosPopoverMenu extends SingleChildRenderObjectWidget {
  const IosPopoverMenu({
    super.key,
    required this.globalFocalPoint,
    this.borderRadius = 12.0,
    this.arrowBaseWidth = 18.0,
    this.arrowLength = 12.0,
    this.allowHorizontalArrow = true,
    this.backgroundColor = const Color(0xFF474747),
    this.padding,
    super.child,
  });

  /// Radius of the corners.
  final double borderRadius;

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
      borderRadius: borderRadius,
      arrowWidth: arrowBaseWidth,
      arrowLength: arrowLength,
      padding: padding,
      screenSize: MediaQuery.of(context).size,
      backgroundColor: backgroundColor,
      focalPoint: globalFocalPoint,
      allowHorizontalArrow: allowHorizontalArrow,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderPopover renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..borderRadius = borderRadius
      ..arrowBaseWidth = arrowBaseWidth
      ..arrowLength = arrowLength
      ..padding = padding
      ..screenSize = MediaQuery.of(context).size
      ..focalPoint = globalFocalPoint
      ..backgroundColor = backgroundColor
      ..allowHorizontalArrow = allowHorizontalArrow;
  }
}

class RenderPopover extends RenderShiftedBox {
  RenderPopover({
    required double borderRadius,
    required double arrowWidth,
    required double arrowLength,
    required Color backgroundColor,
    required Offset focalPoint,
    required Size screenSize,
    bool allowHorizontalArrow = true,
    EdgeInsets? padding,
    RenderBox? child,
  })  : _borderRadius = borderRadius,
        _arrowBaseWidth = arrowWidth,
        _arrowLength = arrowLength,
        _padding = padding,
        _screenSize = screenSize,
        _backgroundColor = backgroundColor,
        _backgroundPaint = Paint()..color = backgroundColor,
        _focalPoint = focalPoint,
        _allowHorizontalArrow = allowHorizontalArrow,
        super(child);

  double _borderRadius;
  double get borderRadius => _borderRadius;
  set borderRadius(double value) {
    if (_borderRadius != value) {
      _borderRadius = value;
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

  Size _screenSize;
  Size get screenSize => _screenSize;
  set screenSize(Size value) {
    if (value != _screenSize) {
      _screenSize = value;
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
    final reservedSize = Size(
      ((padding?.horizontal ?? 0) + arrowLength) * 2,
      ((padding?.vertical ?? 0) + arrowLength) * 2,
    );

    // Compute the child constraints to leave space for the arrow and padding.
    final innerConstraints = constraints.enforce(
      BoxConstraints(
        maxHeight: min(_screenSize.height, constraints.maxHeight) - reservedSize.height,
        maxWidth: min(_screenSize.width, constraints.maxWidth) - reservedSize.width,
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

    final contentOffset = _computeContentOffset(arrowLength);
    final direction = _computeArrowDirection(Offset.zero & size, localFocalPoint);
    final arrowCenter = _computeArrowCenter(direction, localFocalPoint);

    final borderPath = _buildBorderPath(direction, arrowCenter);

    context.canvas.drawPath(borderPath.shift(offset), _backgroundPaint);

    if (child != null) {
      context.paintChild(child!, offset + contentOffset);
    }

    context.canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );

    // print("Global focal point: $focalPoint, local focal point: $localFocalPoint");
    context.canvas.drawCircle(localFocalPoint, 10, Paint()..color = Colors.blue);
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
    final contentOffset = _computeContentOffset(arrowLength);

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
  ///
  /// The path includes a rounded rectangle and a arrow pointing to [arrowDirection], centered at [arrowCenter].
  Path _buildBorderPath(ArrowDirection arrowDirection, double arrowCenter) {
    final halfOfBase = arrowBaseWidth / 2;

    // Adjust the rect to leave space for the arrow.
    // During layout, we reserve space for the arrow in both x and y axis.
    final contentRect = Rect.fromLTWH(
      arrowLength,
      arrowLength,
      size.width - arrowLength * 2,
      size.height - arrowLength * 2,
    );

    Path path = Path()..addRRect(RRect.fromRectAndRadius(contentRect, Radius.circular(borderRadius)));

    // Add the arrow.
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
  ///
  /// If [globalFocalPoint] is inside the [menuRect] horizontal bounds, the arrow points up or right. Otherwise,
  /// the arrow points left or right.
  ///
  /// If [allowHorizontalArrow] is `false`, the arrow only points up or down.
  ArrowDirection _computeArrowDirection(Rect menuRect, Offset globalFocalPoint) {
    final isFocalPointInsideHorizontalBounds =
        globalFocalPoint.dx >= menuRect.left && globalFocalPoint.dx <= menuRect.right;

    if (isFocalPointInsideHorizontalBounds || !allowHorizontalArrow) {
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

  /// Computes the center point of the arrow.
  ///
  /// This point can be on the x or y axis, depending on the [direction].
  double _computeArrowCenter(ArrowDirection direction, Offset focalPoint) {
    final desiredFocalPoint = _isArrowVertical(direction) //
        ? focalPoint.dx
        : focalPoint.dy;

    return _constrainFocalPoint(desiredFocalPoint, direction);
  }

  /// Computes the (x, y) offset used to paint the menu content inside the popover.
  Offset _computeContentOffset(double arrowLength) {
    return Offset(
      (padding?.left ?? 0) + arrowLength,
      (padding?.top ?? 0) + arrowLength,
    );
  }

  /// Indicates whether or not the arrow points to a vertical direction.
  bool _isArrowVertical(ArrowDirection arrowDirection) =>
      arrowDirection == ArrowDirection.up || arrowDirection == ArrowDirection.down;

  /// Minimum focal point for the given [arrowDirection] in which the arrow can be displayed inside the popover bounds.
  double _minArrowFocalPoint(ArrowDirection arrowDirection) => _isArrowVertical(arrowDirection)
      ? _minArrowHorizontalCenter(arrowDirection)
      : _minArrowVerticalCenter(arrowDirection);

  /// Maximum focal point for the given [arrowDirection] in which the arrow can be displayed inside the popover bounds.
  double _maxArrowFocalPoint(ArrowDirection arrowDirection) => _isArrowVertical(arrowDirection)
      ? _maxArrowHorizontalCenter(arrowDirection)
      : _maxArrowVerticalCenter(arrowDirection);

  /// Minimum distance on the x-axis in which the arrow can be displayed without being above the corner.
  double _minArrowHorizontalCenter(ArrowDirection arrowDirection) => (borderRadius + arrowBaseWidth / 2) + arrowLength;

  /// Maximum distance on the x-axis in which the arrow can be displayed without being above the corner.
  double _maxArrowHorizontalCenter(ArrowDirection arrowDirection) =>
      (size.width - borderRadius - arrowBaseWidth - arrowLength / 2);

  /// Minimum distance on the y-axis which the arrow can be displayed without being above the corner.
  double _minArrowVerticalCenter(ArrowDirection arrowDirection) => (borderRadius + arrowBaseWidth / 2) + arrowLength;

  /// Maximum distance on the y-axis which the arrow can be displayed without being above the corner.
  double _maxArrowVerticalCenter(ArrowDirection arrowDirection) =>
      (size.height - borderRadius - arrowLength - (arrowBaseWidth / 2));

  /// Constrain the focal point to be inside the menu bounds, respecting the minimum and maximum focal points.
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
