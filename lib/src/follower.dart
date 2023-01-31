import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' hide LeaderLayer;
import 'package:follow_the_leader/src/logging.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import 'leader.dart';
import 'leader_link.dart';

/// A widget that follows a [Leader].
class Follower extends SingleChildRenderObjectWidget {
  const Follower.withOffset({
    Key? key,
    required this.link,
    this.offset = Offset.zero,
    this.leaderAnchor = Alignment.topCenter,
    this.followerAnchor = Alignment.bottomCenter,
    this.boundary,
    this.showWhenUnlinked = true,
    this.repaintWhenLeaderChanges = false,
    Widget? child,
  })  : aligner = null,
        super(key: key, child: child);

  const Follower.withAligner({
    Key? key,
    required this.link,
    required this.aligner,
    this.boundary,
    this.showWhenUnlinked = false,
    this.repaintWhenLeaderChanges = false,
    Widget? child,
  })  : leaderAnchor = null,
        followerAnchor = null,
        offset = null,
        super(key: key, child: child);

  /// The link object that connects this [CompositedTransformFollower] with a
  /// [CompositedTransformTarget].
  ///
  /// This property must not be null.
  final LeaderLink link;

  /// Boundary that constrains where the follower is allowed to appear, such as
  /// within the bounds of the screen.
  ///
  /// If [boundary] is `null` then the follower isn't constrained at all.
  final FollowerBoundary? boundary;

  final FollowerAligner? aligner;

  /// The anchor point on the linked [CompositedTransformTarget] that
  /// [followerAnchor] will line up with.
  ///
  /// {@template flutter.widgets.CompositedTransformFollower.targetAnchor}
  /// For example, when [leaderAnchor] and [followerAnchor] are both
  /// [Alignment.topLeft], this widget will be top left aligned with the linked
  /// [CompositedTransformTarget]. When [leaderAnchor] is
  /// [Alignment.bottomLeft] and [followerAnchor] is [Alignment.topLeft], this
  /// widget will be left aligned with the linked [CompositedTransformTarget],
  /// and its top edge will line up with the [CompositedTransformTarget]'s
  /// bottom edge.
  /// {@endtemplate}
  ///
  /// Defaults to [Alignment.topLeft].
  final Alignment? leaderAnchor;

  /// The anchor point on this widget that will line up with [followerAnchor] on
  /// the linked [CompositedTransformTarget].
  ///
  /// {@macro flutter.widgets.CompositedTransformFollower.targetAnchor}
  ///
  /// Defaults to [Alignment.topLeft].
  final Alignment? followerAnchor;

  /// The additional offset to apply to the [leaderAnchor] of the linked
  /// [CompositedTransformTarget] to obtain this widget's [followerAnchor]
  /// position.
  final Offset? offset;

  /// Whether to show the widget's contents when there is no corresponding
  /// [Leader] with the same [link].
  ///
  /// When the widget is not linked, then: if [showWhenUnlinked] is true, the
  /// child is visible and not repositioned; if it is false, then child is
  /// hidden.
  final bool showWhenUnlinked;

  /// Whether to repaint the [child] when the [Leader] changes offset
  /// or size.
  ///
  /// This should be `true` when the [child]'s appearance is based on the
  /// location or size of the [Leader], such as a menu with an arrow that
  /// points in the direction of the [Leader]. Otherwise, if the [child]'s
  /// appearance isn't impacted by [Leader], then passing `false` will be
  /// more efficient, because fewer repaints will be scheduled.
  final bool repaintWhenLeaderChanges;

  @override
  RenderFollower createRenderObject(BuildContext context) {
    return RenderFollower(
      link: link,
      offset: offset,
      leaderAnchor: leaderAnchor,
      followerAnchor: followerAnchor,
      aligner: aligner,
      boundary: boundary,
      showWhenUnlinked: showWhenUnlinked,
      repaintWhenLeaderChanges: repaintWhenLeaderChanges,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderFollower renderObject) {
    renderObject
      ..link = link
      ..offset = offset
      ..leaderAnchor = leaderAnchor
      ..followerAnchor = followerAnchor
      ..aligner = aligner
      ..boundary = boundary
      ..showWhenUnlinked = showWhenUnlinked
      ..repaintWhenLeaderChanges = repaintWhenLeaderChanges;
  }
}

abstract class FollowerAligner {
  FollowerAlignment align(Rect globalLeaderRect, Size followerSize);
}

class FollowerAlignment {
  const FollowerAlignment({
    required this.leaderAnchor,
    required this.followerAnchor,
    this.followerOffset = Offset.zero,
  });

  final Alignment leaderAnchor;
  final Alignment followerAnchor;
  final Offset followerOffset;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FollowerAlignment &&
          runtimeType == other.runtimeType &&
          leaderAnchor == other.leaderAnchor &&
          followerAnchor == other.followerAnchor;

  @override
  int get hashCode => leaderAnchor.hashCode ^ followerAnchor.hashCode;
}

/// A boundary that determines where a [Follower] is allowed to appear.
abstract class FollowerBoundary {
  /// Returns `true` if the given [offset] sits within this boundary,
  /// or `false` if it sits outside.
  bool contains(Offset offset);

  /// Constrains the given [desiredOffset] to a legal [Offset] for this
  /// boundary.
  Offset constrain(Rect globalFollowerRect, double followerScale);
}

/// A [FollowerBoundary] that keeps the follower within the screen bounds.
class ScreenFollowerBoundary implements FollowerBoundary {
  const ScreenFollowerBoundary(this.screenSize);

  final Size screenSize;

  @override
  bool contains(Offset offset) => screenSize.contains(offset);

  @override
  Offset constrain(Rect globalFollowerRect, double followerScale) {
    //(LeaderLink link, RenderBox follower, Offset desiredOffset) {
    final xAdjustment = globalFollowerRect.left < 0
        ? -globalFollowerRect.left
        : globalFollowerRect.right > screenSize.width
            ? screenSize.width - globalFollowerRect.right
            : 0.0;
    final yAdjustment = globalFollowerRect.top < 0
        ? -globalFollowerRect.top
        : globalFollowerRect.bottom > screenSize.height
            ? screenSize.height - globalFollowerRect.bottom
            : 0.0;

    return Offset(xAdjustment, yAdjustment);

    // final followerSize = follower.size;
    // final followerOffset = link.offset! + desiredOffset;
    // final xAdjustment = followerOffset.dx < 0
    //     ? -followerOffset.dx
    //     : followerOffset.dx > (screenSize.width - followerSize.width)
    //         ? (screenSize.width - followerSize.width) - followerOffset.dx
    //         : 0.0;
    // final yAdjustment = followerOffset.dy < 0
    //     ? -followerOffset.dy
    //     : followerOffset.dy > (screenSize.height - followerSize.height)
    //         ? (screenSize.height - followerSize.height) - followerOffset.dy
    //         : 0.0;
    // final adjustment = Offset(xAdjustment, yAdjustment);
    //
    // return desiredOffset + adjustment;
  }
}

/// A [FollowerBoundary] that keeps the follower within the bounds of the widget
/// attached to the given [boundaryKey].
class WidgetFollowerBoundary implements FollowerBoundary {
  const WidgetFollowerBoundary(this.boundaryKey);

  final GlobalKey? boundaryKey;

  @override
  bool contains(Offset offset) {
    if (boundaryKey == null || boundaryKey!.currentContext == null) {
      return false;
    }

    final boundaryBox = boundaryKey!.currentContext!.findRenderObject() as RenderBox;
    final boundaryRect = Rect.fromPoints(
      boundaryBox.localToGlobal(Offset.zero),
      boundaryBox.localToGlobal(boundaryBox.size.bottomRight(Offset.zero)),
    );
    return boundaryRect.contains(offset);
  }

  @override
  Offset constrain(Rect globalFollowerRect, double followerScale) {
    // (LeaderLink link, RenderBox follower, Offset desiredOffset) {
    if (boundaryKey == null) {
      // return globalFollowerRect.topLeft;
      return Offset.zero;
    }

    final boundaryBox = boundaryKey!.currentContext!.findRenderObject() as RenderBox;
    final boundaryGlobalOrigin = boundaryBox.localToGlobal(Offset.zero);
    final boundaryGlobalRect = boundaryGlobalOrigin & boundaryBox.size;

    final xAdjustment = globalFollowerRect.left < boundaryGlobalRect.left
        ? boundaryGlobalRect.left - globalFollowerRect.left
        : globalFollowerRect.right > boundaryGlobalRect.right
            ? boundaryGlobalRect.right - globalFollowerRect.right
            : 0.0;
    final yAdjustment = globalFollowerRect.top < boundaryGlobalRect.top
        ? boundaryGlobalRect.top - globalFollowerRect.top
        : globalFollowerRect.bottom > boundaryGlobalRect.bottom
            ? boundaryGlobalRect.bottom - globalFollowerRect.bottom
            : 0.0;

    return Offset(xAdjustment, yAdjustment) / followerScale;

    // return globalFollowerRect.translate(xAdjustment, yAdjustment).topLeft;

    // if (boundaryKey!.currentContext == null) {
    //   FtlLogs.follower.warning(
    //       "Tried to constrain a follower to bounds of another widget, but the GlobalKey wasn't attached to anything: $boundaryKey");
    //   return desiredOffset;
    // }
    //
    // FtlLogs.widgetBoundary.finer("Constraining Follower offset.");
    // final boundaryBox = boundaryKey!.currentContext!.findRenderObject() as RenderBox;
    // final boundaryGlobalOrigin = boundaryBox.localToGlobal(Offset.zero);
    // final boundaryGlobalRect = boundaryGlobalOrigin & boundaryBox.size;
    // FtlLogs.widgetBoundary.finer(" - boundary global rect: $boundaryGlobalRect");
    // final followerScale = follower.scaleInScreenSpace;
    // FtlLogs.widgetBoundary.finer(" - follower scale: $followerScale");
    // FtlLogs.widgetBoundary.finer(" - follower size (unscaled): ${follower.size}");
    // final followerOffset = link.offset! + desiredOffset;
    // final followerGlobalRect = Rect.fromPoints(
    //   follower.localToGlobal(Offset.zero),
    //   follower.localToGlobal(follower.size.bottomRight(Offset.zero)),
    // );
    // FtlLogs.widgetBoundary.finer(" - follower size (scaled): ${followerGlobalRect.size}");
    // FtlLogs.widgetBoundary.finer(" - follower offset: $followerOffset");
    // FtlLogs.widgetBoundary.finer(" - follower global rect: $followerGlobalRect");
    //
    // final xAdjustment = followerGlobalRect.left < boundaryGlobalRect.left
    //     ? boundaryGlobalRect.left - followerGlobalRect.left
    //     : followerGlobalRect.right > boundaryGlobalRect.right
    //         ? boundaryGlobalRect.right - followerGlobalRect.right
    //         : 0.0;
    // final yAdjustment = followerGlobalRect.top < boundaryGlobalRect.top
    //     ? boundaryGlobalRect.top - followerGlobalRect.top
    //     : followerGlobalRect.bottom > boundaryGlobalRect.bottom
    //         ? boundaryGlobalRect.bottom - followerGlobalRect.bottom
    //         : 0.0;
    // final adjustment = Offset(xAdjustment, yAdjustment);
    // FtlLogs.widgetBoundary.finer(" - follower adjustment: $adjustment");
    //
    // final adjustedFollowerOffset = desiredOffset + adjustment;
    // FtlLogs.widgetBoundary.finer(" - adjusted follower offset from: $desiredOffset, to: $adjustedFollowerOffset");
    // return adjustedFollowerOffset;
  }
}

// TODO: decide if this should really be an extension. If so, check for
//       any other scale calculations and use this extension
extension on RenderBox {
  /// The scale of this [RenderBox]'s content from the perspective of
  /// screen-space.
  ///
  /// For example, a [RenderBox] might think its painting a 100x100
  /// rectangle, but on the screen it appears 200x200. That's a scale
  /// of 2.0.
  double get scaleInScreenSpace {
    return (localToGlobal(const Offset(1, 0)) - localToGlobal(const Offset(0, 0))).dx;
  }
}

class RenderFollower extends RenderProxyBox {
  RenderFollower({
    required LeaderLink link,
    FollowerBoundary? boundary,
    FollowerAligner? aligner,
    Alignment? leaderAnchor = Alignment.topLeft,
    Alignment? followerAnchor = Alignment.topLeft,
    Offset? offset = Offset.zero,
    bool showWhenUnlinked = true,
    bool repaintWhenLeaderChanges = false,
    RenderBox? child,
  })  : _link = link,
        _gapFromLeaderInScreenSpace = offset,
        _leaderAnchor = leaderAnchor,
        _followerAnchor = followerAnchor,
        _aligner = aligner,
        _boundary = boundary,
        _showWhenUnlinked = showWhenUnlinked,
        _repaintWhenLeaderChanges = repaintWhenLeaderChanges,
        super(child);

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    if (repaintWhenLeaderChanges) {
      _link.addListener(_onLinkChange);
    }
  }

  @override
  void detach() {
    if (repaintWhenLeaderChanges) {
      _link.removeListener(_onLinkChange);
    }
    layer = null;
    super.detach();
  }

  /// The link object that connects this [RenderFollower] with a
  /// [RenderLeaderLayer] earlier in the paint order.
  LeaderLink get link => _link;
  LeaderLink _link;
  set link(LeaderLink value) {
    if (_link == value) {
      return;
    }

    FtlLogs.follower.fine("Setting new link - $value");

    if (repaintWhenLeaderChanges) {
      _link.removeListener(_onLinkChange);
    }

    _link = value;

    if (repaintWhenLeaderChanges) {
      _link.addListener(_onLinkChange);
    }

    _firstPaintOfCurrentLink = true;

    markNeedsPaint();
  }

  void _onLinkChange() {
    if (owner == null) {
      // We're not attached to the framework pipeline.
      return;
    }

    FtlLogs.follower.finest("Follower's LeaderLink reported a change: $_link. Requesting Follower child repaint.");
    child?.markNeedsPaint();
  }

  FollowerBoundary? get boundary => _boundary;
  FollowerBoundary? _boundary;
  set boundary(FollowerBoundary? newValue) {
    if (newValue == _boundary) {
      return;
    }

    _boundary = newValue;
    markNeedsPaint();
  }

  FollowerAligner? get aligner => _aligner;
  FollowerAligner? _aligner;
  set aligner(FollowerAligner? newAligner) {
    if (newAligner == _aligner) {
      return;
    }

    _aligner = newAligner;
    markNeedsPaint();
  }

  /// The offset to apply to the origin of the linked [RenderLeaderLayer] to
  /// obtain this render object's origin.
  Offset? get offset => _gapFromLeaderInScreenSpace;
  Offset? _gapFromLeaderInScreenSpace;
  set offset(Offset? value) {
    if (_gapFromLeaderInScreenSpace == value) return;
    FtlLogs.follower.fine("Setting new follower offset");
    _gapFromLeaderInScreenSpace = value;
    markNeedsPaint();
  }

  /// The anchor point on the linked [RenderLeaderLayer] that [followerAnchor]
  /// will line up with.
  ///
  /// {@template flutter.rendering.RenderFollowerLayer.leaderAnchor}
  /// For example, when [leaderAnchor] and [followerAnchor] are both
  /// [Alignment.topLeft], this [RenderFollower] will be top left aligned
  /// with the linked [RenderLeaderLayer]. When [leaderAnchor] is
  /// [Alignment.bottomLeft] and [followerAnchor] is [Alignment.topLeft], this
  /// [RenderFollower] will be left aligned with the linked
  /// [RenderLeaderLayer], and its top edge will line up with the
  /// [RenderLeaderLayer]'s bottom edge.
  /// {@endtemplate}
  ///
  /// Defaults to [Alignment.topLeft].
  Alignment? get leaderAnchor => _leaderAnchor;
  Alignment? _leaderAnchor;
  set leaderAnchor(Alignment? value) {
    if (_leaderAnchor == value) return;
    _leaderAnchor = value;
    markNeedsPaint();
  }

  /// The anchor point on this [RenderFollower] that will line up with
  /// [followerAnchor] on the linked [RenderLeaderLayer].
  ///
  /// {@macro flutter.rendering.RenderFollowerLayer.leaderAnchor}
  ///
  /// Defaults to [Alignment.topLeft].
  Alignment? get followerAnchor => _followerAnchor;
  Alignment? _followerAnchor;
  set followerAnchor(Alignment? value) {
    if (_followerAnchor == value) return;
    _followerAnchor = value;
    markNeedsPaint();
  }

  bool get showWhenUnlinked => _showWhenUnlinked;
  bool _showWhenUnlinked;
  set showWhenUnlinked(bool value) {
    if (_showWhenUnlinked == value) return;
    _showWhenUnlinked = value;
    markNeedsPaint();
  }

  bool get repaintWhenLeaderChanges => _repaintWhenLeaderChanges;
  bool _repaintWhenLeaderChanges;
  set repaintWhenLeaderChanges(bool newValue) {
    if (newValue == _repaintWhenLeaderChanges) {
      return;
    }

    _repaintWhenLeaderChanges = newValue;
    if (_repaintWhenLeaderChanges) {
      _link.addListener(_onLinkChange);
    } else {
      _link.removeListener(_onLinkChange);
    }
  }

  @override
  bool get alwaysNeedsCompositing => true;

  /// The layer we created when we were last painted.
  @override
  FollowerLayer? get layer => super.layer as FollowerLayer?;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // Disables the hit testing if this render object is hidden.
    if (!link.leaderConnected && !showWhenUnlinked) return false;
    // RenderFollowerLayer objects don't check if they are
    // themselves hit, because it's confusing to think about
    // how the untransformed size and the child's transformed
    // position interact.
    return hitTestChildren(result, position: position);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final followerOffset = _followerOffsetFromLeader ?? Offset.zero;
    final transform = layer?.getLastTransform()?..translate(followerOffset.dx, followerOffset.dy);

    return result.addWithPaintTransform(
      transform: transform,
      position: position,
      hitTest: (BoxHitTestResult result, Offset position) {
        return super.hitTestChildren(result, position: position);
      },
    );
  }

  Offset? _followerOffsetFromLeader;
  Offset? get previousFollowerOffset => _followerOffsetFromLeader;

  /// Indicates whether or not we are in the first paint of the current [LeaderLink].
  bool _firstPaintOfCurrentLink = true;

  @override
  void performLayout() {
    FtlLogs.follower.finer("Laying out Follower");
    child?.layout(constraints.loosen(), parentUsesSize: true);

    if (constraints.hasBoundedWidth && constraints.hasBoundedHeight) {
      // `Follower` hit testing will only take place where the widget tree thinks
      // this widget resides. Therefore, `Follower`s take up all the space that they
      // can, even if their children are smaller.
      //
      // When a `Follower` is used in a widget tree, it must be placed at a location
      // where its size allows it to receive hit tests for any possible `Leader`
      // location. An `Overlay`, or a similar full-screen area should always works.
      // When a `Follower` is placed in a more narrow area of the layout, developers
      // need to take care that the resulting size facilitates all possible hit test
      // offsets.
      size = constraints.biggest;
    } else {
      size = child!.size;
    }
    FtlLogs.follower.finer(" - Follower bounds layout size: $size");
    FtlLogs.follower.finer(" - Follower content size: ${child?.size}");
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    FtlLogs.follower.finer("Painting Follower - paint offset: $offset");
    if (child == null) {
      return;
    }

    if (!link.leaderConnected && _followerOffsetFromLeader == null) {
      FtlLogs.follower.fine("The leader isn't connected and there's no cached offset. Not painting anything.");
      if (!_firstPaintOfCurrentLink) {
        // We already painted and we still don't have a leader connected.
        // Avoid subsequent paint requests.
        return;
      }
      _firstPaintOfCurrentLink = false;

      // In the first frame we are not connected to the leader.
      // Check again in the next frame only if it's the first paint of the current link.
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (link.leaderConnected) {
          markNeedsPaint();
        }
      });

      // Wait until the next frame to check if we have a leader connected.
      return;
    }

    if (link.leaderConnected) {
      _calculateFollowerOffset();
    }
    FtlLogs.follower.fine("Final follower offset relative to leader: $_followerOffsetFromLeader");

    if (layer == null) {
      layer = FollowerLayer(
        link: link,
        showWhenUnlinked: showWhenUnlinked,
        followerOffsetFromScreenOrigin: offset,
        leaderAnchor: _leaderAnchor,
        followerGap: _gapFromLeaderInScreenSpace ?? Offset.zero,
        followerAnchor: _followerAnchor,
        calculateGlobalFollowerRect: _calculateGlobalFollowerContentRect,
        aligner: _aligner,
        boundary: _boundary,
        linkedOffset: _followerOffsetFromLeader,
        unlinkedOffset: _followerOffsetFromLeader,
        followerSize: child!.size,
      );
    } else {
      layer
        ?..link = link
        ..showWhenUnlinked = showWhenUnlinked
        ..followerOffsetFromScreenOrigin = offset
        ..leaderAnchor = _leaderAnchor
        ..followerGap = _gapFromLeaderInScreenSpace ?? Offset.zero
        ..followerAnchor = _followerAnchor
        ..aligner = _aligner
        ..boundary = _boundary
        ..linkedOffset = _followerOffsetFromLeader
        ..unlinkedOffset = _followerOffsetFromLeader
        ..followerSize = child!.size;
    }

    context.pushLayer(
      layer!,
      (context, offset) {
        FtlLogs.follower.finer("Painting follower content in Follower's Layer. Painting offset: $offset");
        super.paint(context, offset);

        // Debug Paint
        //
        // Four corners of the follower content.
        context.canvas
          ..drawCircle(child!.size.topLeft(Offset.zero), 1, Paint()..color = Colors.orange)
          ..drawCircle(child!.size.topRight(Offset.zero), 1, Paint()..color = Colors.orange)
          ..drawCircle(child!.size.bottomRight(Offset.zero), 1, Paint()..color = Colors.orange)
          ..drawCircle(child!.size.bottomLeft(Offset.zero), 1, Paint()..color = Colors.orange);

        final followerOriginInScreenSpace = localToGlobal(Offset.zero);
        final screenOriginInFollowerSpace = globalToLocal(Offset.zero);
        print("Follower origin in screen space (paint): $followerOriginInScreenSpace");
        print("Screen origin in follower space (paint): $screenOriginInFollowerSpace");

        final childTransform = Matrix4.identity();
        applyPaintTransform(child!, childTransform);
        final childOriginInFollower = childTransform.transform3(Vector3.zero());
        context.canvas
          ..save()
          ..translate(-childOriginInFollower.x, -childOriginInFollower.y)
          ..drawCircle(Offset.zero, 20, Paint()..color = Colors.purpleAccent)
          ..translate(screenOriginInFollowerSpace.dx, screenOriginInFollowerSpace.dy)
          ..drawCircle(Offset.zero, 20, Paint()..color = Colors.cyanAccent)
          ..scale(1 / scaleInScreenSpace)
          ..translate(followerOriginInScreenSpace.dx, followerOriginInScreenSpace.dy)
          ..drawCircle(Offset.zero, 20, Paint()..color = Colors.amber)
          ..translate(childOriginInFollower.x * scaleInScreenSpace, childOriginInFollower.y * scaleInScreenSpace)
          ..drawCircle(Offset.zero, 20, Paint()..color = Colors.lightGreenAccent)
          ..translate(child!.size.width * scaleInScreenSpace, child!.size.height * scaleInScreenSpace)
          ..drawCircle(Offset.zero, 30, Paint()..color = Colors.lightGreenAccent)
          ..restore();

        final childGlobalRect = _calculateGlobalFollowerContentRect();
        context.canvas
          ..save()
          ..translate(-childOriginInFollower.x, -childOriginInFollower.y)
          ..translate(screenOriginInFollowerSpace.dx, screenOriginInFollowerSpace.dy)
          ..scale(1 / scaleInScreenSpace)
          ..drawRect(
              childGlobalRect,
              Paint()
                ..color = Colors.red
                ..strokeWidth = 5)
          ..restore();
      },
      Offset.zero,
      // We don't know where we'll end up, so we have no idea what our cull rect should be.
      childPaintBounds: Rect.largest,
    );
  }

  // TODO: replicate this calculation wherever we adjust the follower based
  //       on bounds.
  Rect _calculateGlobalFollowerContentRect() {
    // The global (screen) offset for the top-left of the Follower
    // widget (not the Follower child).
    final followerOriginInScreenSpace = localToGlobal(Offset.zero);

    // Get the child's transform so that we can find the top-left of the
    // child within the Follower.
    final childTransform = Matrix4.identity();
    applyPaintTransform(child!, childTransform);

    // The offset from the Follower's top-left to the child's top-left, using
    // distance as measured by screen-space. E.g., an offset of (150, 75) for
    // a Follower that's displayed at 2x scale, would become (300, 150) to
    // represent that same distance in screen-space.
    final childOriginInFollowerVec = childTransform.transform3(Vector3.zero());
    final followerToChildDeltaInScreenSpace =
        Offset(childOriginInFollowerVec.x, childOriginInFollowerVec.y) * scaleInScreenSpace;

    final childSizeInScreenSpace = child!.size * scaleInScreenSpace;

    // With all the relevant coordinates and offsets in screen space,
    // assemble the global rectangle for the follower child's bounds.
    final childTopLeftInScreen = followerOriginInScreenSpace + followerToChildDeltaInScreenSpace;
    final childBottomRightInScreen = childTopLeftInScreen + childSizeInScreenSpace.bottomRight(Offset.zero);
    return Rect.fromPoints(
      childTopLeftInScreen,
      childBottomRightInScreen,
    );
  }

  void _calculateFollowerOffset() {
    if (aligner != null) {
      _calculateFollowerOffsetWithAligner();
    } else {
      _calculateFollowerOffsetWithStaticValue();
    }
  }

  void _calculateFollowerOffsetWithAligner() {
    FtlLogs.follower.finer("Calculating Follower offset using an aligner.");

    final globalLeaderTopLeftVec = link.leaderToScreen!.transform3(
        Vector3(link.leaderContentBoundsInLeaderSpace!.left, link.leaderContentBoundsInLeaderSpace!.top, 0));
    final globalLeaderBottomRightVec = link.leaderToScreen!.transform3(
        Vector3(link.leaderContentBoundsInLeaderSpace!.right, link.leaderContentBoundsInLeaderSpace!.bottom, 0));
    final globalLeaderRect = Rect.fromPoints(
      Offset(globalLeaderTopLeftVec.x, globalLeaderTopLeftVec.y),
      Offset(globalLeaderBottomRightVec.x, globalLeaderBottomRightVec.y),
    );
    FtlLogs.follower.finer(" - Global leader rect: $globalLeaderRect");

    final Size? leaderSize = link.leaderSize;
    FtlLogs.follower.finer(" - Leader size: $leaderSize");
    FtlLogs.follower.finer(" - Leader layer offset: ${link.leader!.offset}");

    final followerAlignment = aligner!.align(globalLeaderRect, child!.size);
    final leaderAnchor = followerAlignment.leaderAnchor;
    final followerAnchor = followerAlignment.followerAnchor;

    final followerTransform = Matrix4.identity();
    applyPaintTransform(child!, followerTransform);

    final followerScale =
        (followerTransform.transform3(Vector3(1, 0, 0)) - followerTransform.transform3(Vector3.zero())).x;
    final followerSize = child!.size * followerScale;
    FtlLogs.follower.finer(" - Follower size: $followerSize ($followerScale scale)");

    // TODO: add follower gap to this calculation

    final followerOffsetRelativeToLeader = (leaderSize == null
            ? Offset.zero
            : leaderAnchor.alongSize(leaderSize) - followerAnchor.alongSize(followerSize)) +
        followerAlignment.followerOffset;
    FtlLogs.follower.finer(" - (Non-constrained) Follower offset relative to leader: $followerOffsetRelativeToLeader");

    _followerOffsetFromLeader = followerOffsetRelativeToLeader;
    // _followerOffsetFromLeader = boundary != null
    //     ? boundary!.constrain(link, child!, followerOffsetRelativeToLeader)
    //     : followerOffsetRelativeToLeader;
    FtlLogs.follower.finer(" - (Constrained) Follower offset relative to leader: $_followerOffsetFromLeader");
  }

  void _calculateFollowerOffsetWithStaticValue() {
    FtlLogs.follower.fine("Calculating Follower offset using a static Leader displacement.");
    FtlLogs.follower.finer("Leader global offset: ${link.offset}");
    FtlLogs.follower.finer("Leader local offset: ${link.leader!.offset}");
    FtlLogs.follower
        .finer("Leader anchor point: ${link.leaderSize != null ? leaderAnchor!.alongSize(link.leaderSize!) : null}");
    FtlLogs.follower.finer("Follower anchor point: ${followerAnchor!.alongSize(child!.size)}");

    final gap = _gapFromLeaderInScreenSpace ?? Offset.zero;
    final Offset desiredFollowerOffsetFromLeader = (link.leaderSize == null
        ? gap
        : leaderAnchor!.alongSize(link.leaderSize!) - followerAnchor!.alongSize(child!.size) + gap);
    FtlLogs.follower.finer("(Non-constrained) Follower offset: $desiredFollowerOffsetFromLeader");

    _followerOffsetFromLeader = desiredFollowerOffsetFromLeader;
    // _followerOffsetFromLeader = boundary != null
    //     ? boundary!.constrain(link, child!, desiredFollowerOffsetFromLeader)
    //     : desiredFollowerOffsetFromLeader;
    FtlLogs.follower.finer("(Constrained) Follower offset: $_followerOffsetFromLeader");
  }

  // This is what's used by localToGlobal() and globalToLocal()
  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    print("Follower applyPaintTransform() - previousFollowerOffset: $_followerOffsetFromLeader");
    transform.multiply(_getCurrentTransform());
  }

  /// Return the transform that was used in the last composition phase, if any.
  ///
  /// If the [FollowerLayer] has not yet been created, was never composited, or
  /// was unable to determine the transform (see
  /// [FollowerLayer.getLastTransform]), this returns the identity matrix (see
  /// [Matrix4.identity].
  Matrix4 _getCurrentTransform() {
    FtlLogs.follower.finest("RenderFollower - getCurrentTransform()");
    FtlLogs.follower
        .finest(" - has FollowerLayer? ${layer != null}, has existing transform? ${layer?.getLastTransform() != null}");
    FtlLogs.follower
        .finest(" - follower origin in screen-space (according to localToGlobal): ${localToGlobal(Offset.zero)}");
    FtlLogs.follower.finest(
        " - delta from follower content to follower origin (according to FollowerLayer): ${layer?._transformOffset(Offset.zero)}");
    FtlLogs.follower.finest(" - follower offset from leader: $_followerOffsetFromLeader");
    final transform = layer?.getLastTransform() ?? Matrix4.identity();

    if (_followerOffsetFromLeader != null) {
      transform.translate(_followerOffsetFromLeader!.dx, _followerOffsetFromLeader!.dy);
    }

    return transform;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<LeaderLink>('link', link));
    properties.add(DiagnosticsProperty<bool>('showWhenUnlinked', showWhenUnlinked));
    properties.add(DiagnosticsProperty<Offset>('offset', offset));
    properties.add(TransformProperty('current transform matrix', _getCurrentTransform()));
  }
}

/// A composited layer that applies a transformation matrix to its children such
/// that they are positioned to match a [LeaderLayer].
///
/// If any of the ancestors of this layer have a degenerate matrix (e.g. scaling
/// by zero), then the [FollowerLayer] will not be able to transform its child
/// to the coordinate space of the [LeaderLayer].
///
/// A [linkedOffset] property can be provided to further offset the child layer
/// from the leader layer, for example if the child is to follow the linked
/// layer at a distance rather than directly overlapping it.
class FollowerLayer extends ContainerLayer {
  FollowerLayer({
    required LeaderLink link,
    this.showWhenUnlinked = true,
    // TODO: find out if we really need this passed to us. Is this same
    //       information not available through our parent layers? It looks
    //       like this value is the RenderFollower paint `offset`. That
    //       would seem to suggest that the info isn't limited to RenderFollower.
    required this.followerOffsetFromScreenOrigin,
    this.leaderAnchor,
    this.followerGap = Offset.zero,
    this.followerAnchor,
    required this.calculateGlobalFollowerRect,
    this.aligner,
    this.boundary,
    this.unlinkedOffset = Offset.zero,
    this.linkedOffset = Offset.zero,
    this.followerSize,
  }) : _link = link;

  /// The link to the [LeaderLayer].
  ///
  /// The same object should be provided to a [LeaderLayer] that is earlier in
  /// the layer tree. When this layer is composited, it will apply a transform
  /// that moves its children to match the position of the [LeaderLayer].
  LeaderLink get link => _link;
  LeaderLink _link;
  set link(LeaderLink value) {
    if (value != _link && _leaderHandle != null) {
      _leaderHandle!.dispose();
      _leaderHandle = value.registerFollower();
    }
    _link = value;
  }

  Alignment? leaderAnchor;

  Offset followerGap;

  Alignment? followerAnchor;

  Rect Function() calculateGlobalFollowerRect;

  FollowerAligner? aligner;

  FollowerBoundary? boundary;

  /// Whether to show the layer's contents when the [link] does not point to a
  /// [LeaderLayer].
  ///
  /// When the layer is linked, children layers are positioned such that they
  /// have the same global position as the linked [LeaderLayer].
  ///
  /// When the layer is not linked, then: if [showWhenUnlinked] is true,
  /// children are positioned as if the [FollowerLayer] was a [ContainerLayer];
  /// if it is false, then children are hidden.
  ///
  /// The [showWhenUnlinked] property must be non-null before the compositing
  /// phase of the pipeline.
  bool? showWhenUnlinked;

  /// Offset from parent in the parent's coordinate system, used when the layer
  /// is not linked to a [LeaderLayer].
  ///
  /// The scene must be explicitly recomposited after this property is changed
  /// (as described at [Layer]).
  ///
  /// The [unlinkedOffset] property must be non-null before the compositing
  /// phase of the pipeline.
  ///
  /// See also:
  ///
  ///  * [linkedOffset], for when the layers are linked.
  Offset? unlinkedOffset;

  /// Offset from the origin of the leader layer to the origin of the child
  /// layers, used when the layer is linked to a [LeaderLayer].
  ///
  /// The scene must be explicitly recomposited after this property is changed
  /// (as described at [Layer]).
  ///
  /// The [linkedOffset] property must be non-null before the compositing phase
  /// of the pipeline.
  ///
  /// See also:
  ///
  ///  * [unlinkedOffset], for when the layer is not linked.
  Offset? linkedOffset;

  Offset followerOffsetFromScreenOrigin;

  Size? followerSize;

  CustomLayerLinkHandle? _leaderHandle;

  @override
  void attach(Object owner) {
    FtlLogs.follower.finer("Attaching FollowerLayer to owner: $owner");
    super.attach(owner);
    _leaderHandle = _link.registerFollower();
  }

  @override
  void detach() {
    FtlLogs.follower.finer("Detaching FollowerLayer from owner");
    super.detach();
    _leaderHandle?.dispose();
    _leaderHandle = null;
  }

  Offset? _lastOffset;
  Matrix4? _lastTransform;
  Matrix4? _invertedTransform;
  bool _inverseDirty = true;

  @override
  bool findAnnotations<S extends Object>(AnnotationResult<S> result, Offset localPosition, {required bool onlyFirst}) {
    if (_leaderHandle!.leader == null) {
      if (showWhenUnlinked!) {
        return super.findAnnotations(result, localPosition - unlinkedOffset!, onlyFirst: onlyFirst);
      }
      return false;
    }
    final Offset? transformedOffset = _transformOffset(localPosition);
    if (transformedOffset == null) {
      return false;
    }
    return super.findAnnotations<S>(result, transformedOffset, onlyFirst: onlyFirst);
  }

  Offset? _transformOffset(Offset localPosition) {
    if (_inverseDirty) {
      final lastTransform = getLastTransform();
      if (lastTransform == null) {
        return null;
      }
      _invertedTransform = Matrix4.tryInvert(getLastTransform()!);
      _inverseDirty = false;
    }
    if (_invertedTransform == null) {
      return null;
    }
    final Vector4 vector = Vector4(localPosition.dx, localPosition.dy, 0.0, 1.0);
    final Vector4 result = _invertedTransform!.transform(vector);
    return Offset(result[0], result[1]);
  }

  /// The transform that was used during the last composition phase.
  ///
  /// If the [link] was not linked to a [LeaderLayer], or if this layer has
  /// a degenerate matrix applied, then this will be null.
  ///
  /// This method returns a new [Matrix4] instance each time it is invoked.
  Matrix4? getLastTransform() {
    if (_lastTransform == null) {
      return null;
    }

    final lastOffset = _lastOffset ?? Offset.zero;
    final result = Matrix4.translationValues(
      // Because we're a Layer, we're responsible for reporting our
      // offset from our parent.
      // TODO: check whether this offset should really be from the
      //       screen origin, or whether it's our offset from our
      //       parent layer. If parent layer, rename from
      //       "followerOffsetFromScreenOrigin" to "followerOffsetFromParent"
      -followerOffsetFromScreenOrigin.dx - lastOffset.dx,
      -followerOffsetFromScreenOrigin.dy - lastOffset.dy,
      0.0,
    );

    // TODO: find out what _lastTransform is doing for us. Up above
    //       we apply our offset from parent, and _lastOffset. Why
    //       are we multiplying _lastTransform on top? Add a comment
    //       with the explanation.
    result.multiply(_lastTransform!);

    return result;
  }

  /// {@template flutter.rendering.FollowerLayer.alwaysNeedsAddToScene}
  /// This disables retained rendering.
  ///
  /// A [FollowerLayer] copies changes from a [LeaderLayer] that could be anywhere
  /// in the Layer tree, and that leader layer could change without notifying the
  /// follower layer. Therefore we have to always call a follower layer's
  /// [addToScene]. In order to call follower layer's [addToScene], leader layer's
  /// [addToScene] must be called first so leader layer must also be considered
  /// as [alwaysNeedsAddToScene].
  /// {@endtemplate}
  @override
  bool get alwaysNeedsAddToScene => true;

  @override
  void addToScene(ui.SceneBuilder builder) {
    FtlLogs.follower.finer("Adding FollowerLayer to scene");
    assert(showWhenUnlinked != null);
    if (_leaderHandle!.leader == null && !showWhenUnlinked!) {
      _lastTransform = null;
      _lastOffset = null;
      _inverseDirty = true;
      engineLayer = null;
      return;
    }
    _establishTransform();
    if (_lastTransform != null) {
      engineLayer = builder.pushTransform(
        _lastTransform!.storage,
        oldLayer: engineLayer as ui.TransformEngineLayer?,
      );
      addChildrenToScene(builder);
      builder.pop();
      _lastOffset = unlinkedOffset;
    } else {
      _lastOffset = null;
      final Matrix4 matrix = Matrix4.translationValues(unlinkedOffset!.dx, unlinkedOffset!.dy, .0);
      engineLayer = builder.pushTransform(
        matrix.storage,
        oldLayer: engineLayer as ui.TransformEngineLayer?,
      );
      addChildrenToScene(builder);
      builder.pop();
    }
    _inverseDirty = true;
  }

  /// Populate [_lastTransform] given the current state of the tree.
  void _establishTransform() {
    FtlLogs.follower.finest("Establishing FollowerLayer transform");
    FtlLogs.follower.finest(" - follower linked offset: $linkedOffset");
    _lastTransform = null;
    final LeaderLayer? leader = _leaderHandle!.leader;
    // Check to see if we are linked.
    if (leader == null) {
      return;
    }
    // If we're linked, check the link is valid.
    assert(
      leader.owner == owner,
      'Linked LeaderLayer anchor is not in the same layer tree as the FollowerLayer.',
    );
    assert(
      leader.lastOffset != null,
      'LeaderLayer anchor must come before FollowerLayer in paint order, but the reverse was true.',
    );

    // Stores [leader, ..., commonAncestor] after calling _pathsToCommonAncestor.
    final List<ContainerLayer?> leaderToAncestorLayers = <ContainerLayer>[leader];
    // Stores [this (follower), ..., commonAncestor] after calling
    // _pathsToCommonAncestor.
    final List<ContainerLayer?> followerToAncestorLayers = <ContainerLayer>[this];

    // final Layer? ancestor = _pathsToCommonAncestor(
    //   leader,
    //   this,
    //   leaderToAncestorLayers,
    //   followerToAncestorLayers,
    // );
    // assert(ancestor != null);

    _pathToRoot(
      leader,
      leaderToAncestorLayers,
    );
    FtlLogs.follower.finest(" - Leader ancestor path:");
    for (final layer in leaderToAncestorLayers) {
      FtlLogs.follower.finest("   - $layer");
    }

    _pathToRoot(
      this,
      followerToAncestorLayers,
    );
    FtlLogs.follower.finest(" - Follower ancestor path");
    for (final layer in followerToAncestorLayers) {
      FtlLogs.follower.finest("   - $layer");
    }

    final Matrix4 leaderTransform = _collectTransformForLayerChain(leaderToAncestorLayers);
    // Further transforms the coordinate system to a hypothetical child (null)
    // of the leader layer, to account for the leader's additional paint offset
    // and layer offset (LeaderLayer._lastOffset). In other words, leaderTransform
    // up above gets us to the top-left of the LeaderLayer, but we want
    // leaderTransform to get us to the top-left of the content inside the LeaderLayer.
    leader.applyTransform(null, leaderTransform);
    FtlLogs.follower.finest(" - Leader transform to screen-space \n$leaderTransform");

    final Matrix4 screenToFollowerTransform = _collectTransformForLayerChain(followerToAncestorLayers);
    if (screenToFollowerTransform.invert() == 0.0) {
      // We are in a degenerate transform, so there's not much we can do.
      return;
    }
    FtlLogs.follower.finest(" - Follower transform to screen-space \n$screenToFollowerTransform");

    // Verified: top-left corner of Leader
    final tempVec2 = leaderTransform.transform3(Vector3.zero());
    print("leaderTransform - (0,0) -> $tempVec2");

    // Verified: follower ancestor transforms, but not in the way that's
    // expected. For example, currently, the only transform above the
    // Follower is a Transform.scale widget. So at a scale of 1.2, this
    // transform is `offsetIn + (150, 72) -> offsetOut`
    final tempVec1 = screenToFollowerTransform.transform3(Vector3.zero());
    print("screenToFollowerTransform - (0,0) -> $tempVec1");

    // Calculate the leader and follower scale so that we can un-apply the
    // leader scale, and add the follower scale. We do this because we don't
    // want to force the follower to always be the scale of the leader.
    final leaderScale = (leaderTransform.transform3(Vector3(1, 0, 0)) - leaderTransform.transform3(Vector3.zero())).x;
    FtlLogs.follower.finest(" - Leader scale: $leaderScale");
    final followerScale = 1 /
        (screenToFollowerTransform.transform3(Vector3(1, 0, 0)) - screenToFollowerTransform.transform3(Vector3.zero()))
            .x; // We invert the scale because the transform is an inverse
    FtlLogs.follower.finest(" - Follower scale: $followerScale");

    // Put follower transform into leader space. This operation would be all
    // we need, if we didn't want to undo the leader's scale factor.
    final screenToLeaderTransform = screenToFollowerTransform.clone()..multiply(leaderTransform);

    // Not sure what this transform is. It puts a dot somewhere near the
    // Leader, but the dot moves small distances based on scale.
    final tempVec3 = screenToLeaderTransform.transform3(Vector3.zero());
    print("screenToLeaderTransform - (0,0) -> $tempVec3");

    // final followerOffsetVector = screenToFollowerTransform.transform3(Vector3.zero());
    // final followerOffset = Offset(followerOffsetVector.x, followerOffsetVector.y);
    final leaderOffsetVector = leaderTransform.transform3(Vector3.zero());
    final leaderOffset = Offset(leaderOffsetVector.x, leaderOffsetVector.y);
    FtlLogs.follower.finest(" - Leader origin in screen space: $leaderOffset");

    final leaderSize = _link.leaderSize! * leaderScale;
    FtlLogs.follower.finest(" - leader size: $leaderSize");

    final anchorMetrics = aligner != null
        ? _calculateAlignerAnchorMetrics(
            leaderSize: leaderSize,
            followerSize: followerSize!,
            followerScale: followerScale,
          )
        : _calculateStaticAnchorMetrics(
            leaderSize: leaderSize,
            followerSize: followerSize!,
          );

    // Build the full transform to get from follower-space to
    // screen-space, such that the Follower is aligned in the
    // desired way with the Leader.
    final focalPointToScreenTransform = screenToLeaderTransform
      // Scale from leader-space to screen-space. After the scale, the
      // origin will sit at the top-left corner of the leader, in screen-space.
      ..scale(1 / leaderScale) // <- inverted because we want to undo the Leader scale
      // Move the origin to the point on the Leader where we want to anchor
      // the Follower. This offset is in screen-space.
      ..translate(anchorMetrics.leaderAnchorInScreenSpace.dx, anchorMetrics.leaderAnchorInScreenSpace.dy)
      // Move the origin away from the Leader in the direction of the desired gap, which
      // adds space between the Leader and the Follower.
      ..translate(anchorMetrics.followerGapInScreenSpace.dx, anchorMetrics.followerGapInScreenSpace.dy)
      ..translate(anchorMetrics.followerAnchorInFollowerSpace.dx, anchorMetrics.followerAnchorInFollowerSpace.dy)
      // Scale from screen-space to follower-space. After this scale, the
      // origin remains in the same place, sitting a gap distance from the
      // Leader, but all further translations will be scaled based on the
      // the Follower's scale.
      ..scale(followerScale);
    // Move the origin such that when the Follower is painted, the
    // Follower's desired anchor point (bottom-center, top-center, etc)
    // sits at the gap point that we moved to above.
    //
    // This offset is in follower-space, e.g., if the natural width of
    // the follower is `100`, but the follower is scaled 2x to `200`, and
    // we want center alignment, then the `dx` will be `50`, because
    // that's horizontal center in follower-space.
    // ..translate(anchorMetrics.followerAnchorInFollowerSpace.dx, anchorMetrics.followerAnchorInFollowerSpace.dy);

    _lastTransform = focalPointToScreenTransform;

    // Make sure we don't display the Follower beyond the desired bounds.
    _constrainFollowerOffsetToBounds(focalPointToScreenTransform, followerScale);

    _inverseDirty = true;
  }

  _AnchorMetrics _calculateAlignerAnchorMetrics({
    required Size leaderSize,
    required Size followerSize,
    required double followerScale,
  }) {
    final leaderOriginOnScreenVec = _link.leaderToScreen!.transform3(Vector3.zero());
    final leaderOriginOnScreen = Offset(leaderOriginOnScreenVec.x, leaderOriginOnScreenVec.y);
    final leaderGlobalRect = leaderOriginOnScreen & leaderSize;

    final alignment = aligner!.align(leaderGlobalRect, followerSize);

    return _AnchorMetrics(
      leaderAnchorInScreenSpace: alignment.leaderAnchor.alongSize(leaderSize),
      followerGapInScreenSpace: alignment.followerOffset,
      followerAnchorInFollowerSpace: -alignment.followerAnchor.alongSize(followerSize * followerScale),
    );
  }

  _AnchorMetrics _calculateStaticAnchorMetrics({
    required Size leaderSize,
    required Size followerSize,
  }) {
    FtlLogs.follower.finest(" - leader anchor alignment: $leaderAnchor");
    final leaderAnchorAlignment = leaderAnchor ?? Alignment.bottomCenter;
    final leaderAnchorOffset = leaderAnchorAlignment.alongSize(leaderSize);

    FtlLogs.follower.finest(" - follower anchor alignment: $followerAnchor");
    final followerAnchorAlignment = followerAnchor ?? Alignment.topCenter;
    final followerAnchorOffset = -followerAnchorAlignment.alongSize(followerSize);

    return _AnchorMetrics(
      leaderAnchorInScreenSpace: leaderAnchorOffset,
      followerGapInScreenSpace: followerGap,
      followerAnchorInFollowerSpace: followerAnchorOffset,
    );
  }

  void _constrainFollowerOffsetToBounds(Matrix4 desiredTransform, double followerScale) {
    if (boundary == null) {
      return;
    }

    final leaderToFollower = desiredTransform.clone();
    print("screenToFollower top left: ${leaderToFollower.transform3(Vector3.zero())}");
    print(
        "screenToFollower Follower bottom right: ${leaderToFollower.transform3(Vector3(followerSize!.width, followerSize!.height, 0))}");

    final transform = getLastTransform()!;
    transform.translate(linkedOffset!.dx, linkedOffset!.dy);
    print("getLastTransform() Follower top left: ${transform.transform3(Vector3.zero())}");
    print(
        "getLastTransform() Follower bottom right: ${transform.transform3(Vector3(followerSize!.width, followerSize!.height, 0))}");

    final transformInScreen = _lastTransform!.clone();
    final transformInParent = getLastTransform()!;
    final unscaledScreenTopLeft = transformInScreen.transform3(Vector3.zero());
    final unscaledParentTopLeft = transformInParent.transform3(Vector3.zero());
    transformInScreen.translate(-unscaledScreenTopLeft.x, -unscaledScreenTopLeft.y);
    transformInScreen.scale(followerScale);
    transformInScreen.translate(unscaledParentTopLeft.x, unscaledParentTopLeft.y);

    final followerTopLeftVec = transformInScreen.transform3(Vector3.zero());
    print("Follower top left: $followerTopLeftVec");
    final followerBottomRightVec = transformInScreen.transform3(Vector3(followerSize!.width, followerSize!.height, 0));
    print("Follower bottom right: $followerBottomRightVec");

    print("Layer asking RenderFollower for global follower rect:");
    final globalFollowerRect = calculateGlobalFollowerRect();
    print(" - global rect: $globalFollowerRect");

    final followerAdjustment = boundary!.constrain(globalFollowerRect, followerScale);
    desiredTransform.translate(followerAdjustment.dx, followerAdjustment.dy);
  }

  /// Builds and returns a transform that goes from a layer-space to
  /// screen-space.
  ///
  /// To create a transform that goes from screen-space to layer-space,
  /// invert the returned transform.
  ///
  /// This method calls [applyTransform] for each layer in the provided list.
  ///
  /// The list is in reverse order (deepest first). The first layer will be
  /// treated as the child of the second, and so forth.
  ///
  /// The first layer in the list won't have [applyTransform] called on it.
  ///
  /// The first layer may be `null`.
  Matrix4 _collectTransformForLayerChain(List<ContainerLayer?> layers) {
    FtlLogs.follower.finest("_collectTransformForLayerChain()");
    // Initialize our result matrix.
    final Matrix4 result = Matrix4.identity();
    // Apply each layer to the matrix in turn, starting from the last layer,
    // and providing the previous layer as the child.
    for (int index = layers.length - 1; index > 0; index -= 1) {
      FtlLogs.follower.finest("Calling applyTransform() on layer: ${layers[index]}");
      layers[index]?.applyTransform(layers[index - 1], result);
    }
    return result;
  }

  /// Collects all of [layer]'s parents in the given [ancestors] list.
  ///
  /// The list of [ancestors] can be used to build up a single transform
  /// that goes from screen-space to [layer]-space, and vis-a-versa.
  ///
  /// The [ancestors] list should already contain [layer] when it's provided.
  /// The [ancestors] list starts with [layer] and proceeds parent-by-parent
  /// until it reaches the top-most [Layer] of the tree.
  void _pathToRoot(
    Layer layer,
    List<ContainerLayer?> ancestors,
  ) {
    Layer currentLayer = layer;
    while (currentLayer.parent != null) {
      ancestors.add(currentLayer.parent!);
      currentLayer = currentLayer.parent!;
    }
  }

  // TODO: Originally, Leader-to-and-from-Follower transforms were
  //       calculated by finding a common ancestor and then transforming
  //       from there. Debugging transforms was so difficult that I switched
  //       to using root screen-space. This adds a bunch of unnecessary
  //       transforms beyond the root ancestor, but it was the only way
  //       I could get things working. Determine whether using screen-space
  //       is a performance issue. If it is, bring back common layer ancestor
  //       searches. FYI - screen-space is always a possible worst-case common
  //       ancestor.
  // /// Find the common ancestor of two layers [a] and [b] by searching towards
  // /// the root of the tree, and append each ancestor of [a] or [b] visited along
  // /// the path to [ancestorsA] and [ancestorsB] respectively.
  // ///
  // /// Returns null if [a] [b] do not share a common ancestor, in which case the
  // /// results in [ancestorsA] and [ancestorsB] are undefined.
  // Layer? _pathsToCommonAncestor(
  //   Layer? a,
  //   Layer? b,
  //   List<ContainerLayer?> ancestorsA,
  //   List<ContainerLayer?> ancestorsB,
  // ) {
  //   // No common ancestor found.
  //   if (a == null || b == null) {
  //     return null;
  //   }
  //
  //   if (identical(a, b)) {
  //     return a;
  //   }
  //
  //   if (a.depth < b.depth) {
  //     ancestorsB.add(b.parent);
  //     return _pathsToCommonAncestor(a, b.parent, ancestorsA, ancestorsB);
  //   } else if (a.depth > b.depth) {
  //     ancestorsA.add(a.parent);
  //     return _pathsToCommonAncestor(a.parent, b, ancestorsA, ancestorsB);
  //   }
  //
  //   ancestorsA.add(a.parent);
  //   ancestorsB.add(b.parent);
  //   return _pathsToCommonAncestor(a.parent, b.parent, ancestorsA, ancestorsB);
  // }

  // Note: applyTransform() is called indirectly by establishTransform()
  //       when calculating the follower-to-screen transform.
  @override
  void applyTransform(Layer? child, Matrix4 transform) {
    FtlLogs.follower.finest("FollowerLayer - applyTransform()");
    FtlLogs.follower.finest("Transform before translation: \n$transform");

    assert(child != null);
    if (_lastTransform != null) {
      transform.multiply(_lastTransform!);
    } else {
      transform.multiply(Matrix4.translationValues(unlinkedOffset!.dx, unlinkedOffset!.dy, 0));
    }

    FtlLogs.follower.finest("Transform after translation: \n$transform");
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<LeaderLink>('link', link));
    properties.add(TransformProperty('transform', getLastTransform(), defaultValue: null));
  }
}

class _AnchorMetrics {
  const _AnchorMetrics({
    required this.leaderAnchorInScreenSpace,
    required this.followerGapInScreenSpace,
    required this.followerAnchorInFollowerSpace,
  });

  /// Delta offset from the Leader's origin to the Leader's anchor
  /// point, measured in screen-space distance.
  final Offset leaderAnchorInScreenSpace;

  /// Delta offset from the Leader's anchor point to the Follower's
  /// anchor point, measured in screen-space distance.
  final Offset followerGapInScreenSpace;

  /// Delta offset from the Follower's origin to the Follower's anchor
  /// point, measured in follower-space distance.
  final Offset followerAnchorInFollowerSpace;
}
