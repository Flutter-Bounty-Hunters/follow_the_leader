import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'layer_link.dart';

/// A widget that can be targeted by a [CompositedTransformFollower].
///
/// When this widget is composited during the compositing phase (which comes
/// after the paint phase, as described in [WidgetsBinding.drawFrame]), it
/// updates the [link] object so that any [CompositedTransformFollower] widgets
/// that are subsequently composited in the same frame and were given the same
/// [LayerLink] can position themselves at the same screen location.
///
/// A single [Leader] can be followed by multiple
/// [CompositedTransformFollower] widgets.
///
/// The [Leader] must come earlier in the paint order than
/// any linked [CompositedTransformFollower]s.
///
/// See also:
///
///  * [CompositedTransformFollower], the widget that can target this one.
///  * [LeaderLayer], the layer that implements this widget's logic.
class Leader extends SingleChildRenderObjectWidget {
  /// Creates a composited transform target widget.
  ///
  /// The [link] property must not be null, and must not be currently being used
  /// by any other [Leader] object that is in the tree.
  const Leader({
    Key? key,
    required this.link,
    Widget? child,
  }) : super(key: key, child: child);

  /// The link object that connects this [Leader] with one or
  /// more [CompositedTransformFollower]s.
  ///
  /// This property must not be null. The object must not be associated with
  /// another [Leader] that is also being painted.
  final LeaderLink link;

  @override
  CustomRenderLeaderLayer createRenderObject(BuildContext context) {
    return CustomRenderLeaderLayer(
      link: link,
    );
  }

  @override
  void updateRenderObject(BuildContext context, CustomRenderLeaderLayer renderObject) {
    renderObject.link = link;
  }
}

/// Provides an anchor for a [RenderFollowerLayer].
///
/// See also:
///
///  * [CompositedTransformTarget], the corresponding widget.
///  * [LeaderLayer], the layer that this render object creates.
class CustomRenderLeaderLayer extends RenderProxyBox {
  /// Creates a render object that uses a [LeaderLayer].
  ///
  /// The [link] must not be null.
  CustomRenderLeaderLayer({
    required LeaderLink link,
    RenderBox? child,
  })  : _link = link,
        super(child);

  /// The link object that connects this [CustomRenderLeaderLayer] with one or more
  /// [RenderFollowerLayer]s.
  ///
  /// This property must not be null. The object must not be associated with
  /// another [CustomRenderLeaderLayer] that is also being painted.
  LeaderLink get link => _link;
  LeaderLink _link;
  set link(LeaderLink value) {
    if (_link == value) {
      return;
    }
    _link.leaderSize = null;
    _link = value;
    if (_previousLayoutSize != null) {
      _link.leaderSize = _previousLayoutSize;
    }

    // TODO: Do we need to repaint? We're just updating logical information.
    //       Create a demo that moves the leader link to different leaders
    //       and see if this call makes a difference.
    markNeedsPaint();
  }

  @override
  bool get alwaysNeedsCompositing => true;

  // The latest size of this [RenderBox], computed during the previous layout
  // pass. It should always be equal to [size], but can be accessed even when
  // [debugDoingThisResize] and [debugDoingThisLayout] are false.
  Size? _previousLayoutSize;

  @override
  void performLayout() {
    super.performLayout();
    _previousLayoutSize = size;
    link.leaderSize = size;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (layer == null) {
      layer = LeaderLayer(link: link, offset: offset);
    } else {
      final LeaderLayer leaderLayer = layer! as LeaderLayer;
      leaderLayer
        ..link = link
        ..offset = offset;
    }
    context.pushLayer(layer!, super.paint, Offset.zero);
    assert(layer != null);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<LeaderLink>('link', link));
  }
}

/// A composited layer that can be followed by a [FollowerLayer].
///
/// This layer collapses the accumulated offset into a transform and passes
/// [Offset.zero] to its child layers in the [addToScene]/[addChildrenToScene]
/// methods, so that [applyTransform] will work reliably.
class LeaderLayer extends ContainerLayer {
  /// Creates a leader layer.
  ///
  /// The [link] property must not be null, and must not have been provided to
  /// any other [LeaderLayer] layers that are [attached] to the layer tree at
  /// the same time.
  ///
  /// The [offset] property must be non-null before the compositing phase of the
  /// pipeline.
  LeaderLayer({required LeaderLink link, Offset offset = Offset.zero})
      : _link = link,
        _offset = offset;

  /// The object with which this layer should register.
  ///
  /// The link will be established when this layer is [attach]ed, and will be
  /// cleared when this layer is [detach]ed.
  LeaderLink get link => _link;
  LeaderLink _link;
  set link(LeaderLink value) {
    if (_link == value) {
      return;
    }
    _link.leader = null;
    _link = value;
  }

  /// Offset from parent in the parent's coordinate system.
  ///
  /// The scene must be explicitly recomposited after this property is changed
  /// (as described at [Layer]).
  ///
  /// The [offset] property must be non-null before the compositing phase of the
  /// pipeline.
  Offset get offset => _offset;
  Offset _offset;
  set offset(Offset value) {
    if (value == _offset) {
      return;
    }
    _offset = value;
    if (!alwaysNeedsAddToScene) {
      markNeedsAddToScene();
    }
  }

  /// {@macro flutter.rendering.FollowerLayer.alwaysNeedsAddToScene}
  @override
  bool get alwaysNeedsAddToScene => _link.hasFollowers;

  @override
  void attach(Object owner) {
    super.attach(owner);
    _lastOffset = null;
    link.leader = this;
  }

  @override
  void detach() {
    link.leader = null;
    _lastOffset = null;
    super.detach();
  }

  /// The offset the last time this layer was composited.
  ///
  /// This is reset to null when the layer is attached or detached, to help
  /// catch cases where the follower layer ends up before the leader layer, but
  /// not every case can be detected.
  Offset? get lastOffset => _lastOffset;
  Offset? _lastOffset;

  @override
  bool findAnnotations<S extends Object>(AnnotationResult<S> result, Offset localPosition, {required bool onlyFirst}) {
    return super.findAnnotations<S>(result, localPosition - offset, onlyFirst: onlyFirst);
  }

  @override
  void addToScene(ui.SceneBuilder builder) {
    _lastOffset = offset;
    if (_lastOffset != Offset.zero) {
      engineLayer = builder.pushTransform(
        Matrix4.translationValues(_lastOffset!.dx, _lastOffset!.dy, 0.0).storage,
        oldLayer: engineLayer as ui.TransformEngineLayer?,
      );
    }
    addChildrenToScene(builder);
    if (_lastOffset != Offset.zero) {
      builder.pop();
    }
  }

  /// Applies the transform that would be applied when compositing the given
  /// child to the given matrix.
  ///
  /// See [ContainerLayer.applyTransform] for details.
  ///
  /// The `child` argument may be null, as the same transform is applied to all
  /// children.
  // TODO: The ContainerLayer docs about this end by saying "Used by [FollowerLayer] to
  //  transform its child to a [LeaderLayer]'s position". This is weird because it seems to
  //  suggest that ContainerLayer was given an API to serve a specific subclass.
  @override
  void applyTransform(Layer? child, Matrix4 transform) {
    assert(_lastOffset != null);
    if (_lastOffset != Offset.zero) {
      transform.translate(_lastOffset!.dx, _lastOffset!.dy);
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Offset>('offset', offset));
    properties.add(DiagnosticsProperty<LeaderLink>('link', link));
  }
}
