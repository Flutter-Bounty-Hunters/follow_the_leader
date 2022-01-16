import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class RenderFollowerLayer extends RenderProxyBox {
  /// Creates a render object that uses a [FollowerLayer].
  ///
  /// The [link] and [offset] arguments must not be null.
  RenderFollowerLayer({
    required LayerLink link,
    GlobalKey? boundaryKey,
    bool showWhenUnlinked = true,
    Offset offset = Offset.zero,
    Alignment leaderAnchor = Alignment.topLeft,
    Alignment followerAnchor = Alignment.topLeft,
    RenderBox? child,
  })  : _link = link,
        _boundaryKey = boundaryKey,
        _showWhenUnlinked = showWhenUnlinked,
        _offset = offset,
        _leaderAnchor = leaderAnchor,
        _followerAnchor = followerAnchor,
        super(child);

  /// The link object that connects this [RenderFollowerLayer] with a
  /// [RenderLeaderLayer] earlier in the paint order.
  LayerLink get link => _link;
  LayerLink _link;
  set link(LayerLink value) {
    assert(value != null);
    if (_link == value) return;
    _link = value;
    markNeedsPaint();
  }

  GlobalKey? get boundaryKey => _boundaryKey;
  GlobalKey? _boundaryKey;
  set boundaryKey(GlobalKey? newKey) {
    if (newKey == _boundaryKey) {
      return;
    }
    _boundaryKey = newKey;
    markNeedsPaint();
  }

  /// Whether to show the render object's contents when there is no
  /// corresponding [RenderLeaderLayer] with the same [link].
  ///
  /// When the render object is linked, the child is positioned such that it has
  /// the same global position as the linked [RenderLeaderLayer].
  ///
  /// When the render object is not linked, then: if [showWhenUnlinked] is true,
  /// the child is visible and not repositioned; if it is false, then child is
  /// hidden, and its hit testing is also disabled.
  bool get showWhenUnlinked => _showWhenUnlinked;
  bool _showWhenUnlinked;
  set showWhenUnlinked(bool value) {
    assert(value != null);
    if (_showWhenUnlinked == value) return;
    _showWhenUnlinked = value;
    markNeedsPaint();
  }

  /// The offset to apply to the origin of the linked [RenderLeaderLayer] to
  /// obtain this render object's origin.
  Offset get offset => _offset;
  Offset _offset;
  set offset(Offset value) {
    assert(value != null);
    if (_offset == value) return;
    _offset = value;
    markNeedsPaint();
  }

  /// The anchor point on the linked [RenderLeaderLayer] that [followerAnchor]
  /// will line up with.
  ///
  /// {@template flutter.rendering.RenderFollowerLayer.leaderAnchor}
  /// For example, when [leaderAnchor] and [followerAnchor] are both
  /// [Alignment.topLeft], this [RenderFollowerLayer] will be top left aligned
  /// with the linked [RenderLeaderLayer]. When [leaderAnchor] is
  /// [Alignment.bottomLeft] and [followerAnchor] is [Alignment.topLeft], this
  /// [RenderFollowerLayer] will be left aligned with the linked
  /// [RenderLeaderLayer], and its top edge will line up with the
  /// [RenderLeaderLayer]'s bottom edge.
  /// {@endtemplate}
  ///
  /// Defaults to [Alignment.topLeft].
  Alignment get leaderAnchor => _leaderAnchor;
  Alignment _leaderAnchor;
  set leaderAnchor(Alignment value) {
    assert(value != null);
    if (_leaderAnchor == value) return;
    _leaderAnchor = value;
    markNeedsPaint();
  }

  /// The anchor point on this [RenderFollowerLayer] that will line up with
  /// [followerAnchor] on the linked [RenderLeaderLayer].
  ///
  /// {@macro flutter.rendering.RenderFollowerLayer.leaderAnchor}
  ///
  /// Defaults to [Alignment.topLeft].
  Alignment get followerAnchor => _followerAnchor;
  Alignment _followerAnchor;
  set followerAnchor(Alignment value) {
    assert(value != null);
    if (_followerAnchor == value) return;
    _followerAnchor = value;
    markNeedsPaint();
  }

  @override
  void detach() {
    layer = null;
    super.detach();
  }

  @override
  bool get alwaysNeedsCompositing => true;

  /// The layer we created when we were last painted.
  @override
  FollowerLayer? get layer => super.layer as FollowerLayer?;

  /// Return the transform that was used in the last composition phase, if any.
  ///
  /// If the [FollowerLayer] has not yet been created, was never composited, or
  /// was unable to determine the transform (see
  /// [FollowerLayer.getLastTransform]), this returns the identity matrix (see
  /// [new Matrix4.identity].
  Matrix4 getCurrentTransform() {
    return layer?.getLastTransform() ?? Matrix4.identity();
  }

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
    return result.addWithPaintTransform(
      transform: getCurrentTransform(),
      position: position,
      hitTest: (BoxHitTestResult result, Offset position) {
        return super.hitTestChildren(result, position: position);
      },
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    print("Painting composited follower: $offset");
    final Size? leaderSize = link.leaderSize;
    assert(
      link.leaderSize != null || (!link.leaderConnected || leaderAnchor == Alignment.topLeft),
      '$link: layer is linked to ${link.debugLeader} but a valid leaderSize is not set. '
      'leaderSize is required when leaderAnchor is not Alignment.topLeft '
      '(current value is $leaderAnchor).',
    );
    final Offset effectiveLinkedOffset = leaderSize == null
        ? this.offset
        : leaderAnchor.alongSize(leaderSize) - followerAnchor.alongSize(size) + this.offset;
    print("Leader layer offset: ${link.debugLeader!.offset}");
    final boundaryBox = boundaryKey!.currentContext!.findRenderObject() as RenderBox;
    print("Boundary box size: ${boundaryBox.size}");
    print("Follower box size: $size");
    // final boundaryOffset = boundaryBox.globalToLocal(localToGlobal(Offset.zero));
    final boundaryOffset = link.debugLeader!.offset + effectiveLinkedOffset;
    final xAdjustment = boundaryOffset.dx < 0
        ? -boundaryOffset.dx
        : boundaryOffset.dx > (boundaryBox.size.width - size.width)
            ? (boundaryBox.size.width - size.width) - boundaryOffset.dx
            : 0.0;
    final yAdjustment = boundaryOffset.dy < 0
        ? -boundaryOffset.dy
        : boundaryOffset.dy > (boundaryBox.size.height - size.height)
            ? (boundaryBox.size.height - size.height) - boundaryOffset.dy
            : 0.0;
    final adjustment = Offset(xAdjustment, yAdjustment);
    print("Adjustment: $adjustment");
    assert(showWhenUnlinked != null);
    if (layer == null) {
      layer = FollowerLayer(
        link: link,
        showWhenUnlinked: showWhenUnlinked,
        linkedOffset: effectiveLinkedOffset + adjustment,
        unlinkedOffset: offset,
      );
    } else {
      layer
        ?..link = link
        ..showWhenUnlinked = showWhenUnlinked
        ..linkedOffset = effectiveLinkedOffset + adjustment
        ..unlinkedOffset = offset;
    }
    context.pushLayer(
      layer!,
      (context, offset) {
        print("Painting follower content. Incoming offset: $offset");
        super.paint(context, offset);
      },
      Offset.zero,
      childPaintBounds: const Rect.fromLTRB(
        // We don't know where we'll end up, so we have no idea what our cull rect should be.
        double.negativeInfinity,
        double.negativeInfinity,
        double.infinity,
        double.infinity,
      ),
    );
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.multiply(getCurrentTransform());
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<LayerLink>('link', link));
    properties.add(DiagnosticsProperty<bool>('showWhenUnlinked', showWhenUnlinked));
    properties.add(DiagnosticsProperty<Offset>('offset', offset));
    properties.add(TransformProperty('current transform matrix', getCurrentTransform()));
  }
}
