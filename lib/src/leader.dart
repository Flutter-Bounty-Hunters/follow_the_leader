import 'dart:ui' as ui;

import 'package:flutter/rendering.dart' hide FollowerLayer;
import 'package:flutter/widgets.dart';
import 'package:follow_the_leader/follow_the_leader.dart';

/// A widget that can be followed by a [Follower].
///
/// When this widget is composited during the compositing phase (which comes
/// after the paint phase, as described in [WidgetsBinding.drawFrame]), it
/// updates the [link] object so that any [Follower] widgets
/// that are subsequently composited in the same frame and were given the same
/// [LeaderLink] can position themselves at the same screen location.
///
/// A single [Leader] can be followed by multiple [Follower] widgets.
///
/// The [Leader] must come earlier in the paint order than any linked [Follower]s.
///
/// See also:
///
///  * [Follower], the widget that can target this one.
///  * [LeaderLayer], the layer that implements this widget's logic.
class Leader extends SingleChildRenderObjectWidget {
  /// Creates a leader widget.
  ///
  /// The [link] property must not be null, and must not currently be used
  /// by any other [Leader] object that is in the tree.
  const Leader({
    Key? key,
    required this.link,
    this.recalculateGlobalOffset,
    Widget? child,
  }) : super(key: key, child: child);

  /// The link object that connects this [Leader] with one or
  /// more [Follower]s.
  ///
  /// This property must not be null. The object must not be associated with
  /// another [Leader] that is also being painted.
  final LeaderLink link;

  /// Signal that instructs the [Leader] to update its global offset in its
  /// [LeaderLink].
  ///
  /// This signal needs to be sent whenever a [Leader]'s ancestor widget moves
  /// relative to the screen origin without rebuilding its subtree. For example,
  /// `ListView`s, by default, wrap their children in `RepaintBoundary`s. This means
  /// that when the `ListView` scrolls up and down, it doesn't re-build, re-layout or
  /// re-paint the list items. If a [Leader] sits inside of a list item, the [Leader]
  /// doesn't get any opportunity to update its [LeaderLink] with its latest position.
  /// Therefore, in that case, you should pass the `ScrollController` as [recalculateGlobalOffset] so
  /// that the [Leader] can listen for every scroll change and then re-calculate its
  /// global offset for [Follower]s.
  ///
  /// This signal causes the [Leader] to schedule a repaint, because that's where
  /// [Leader]s calculate and report their global offsets.
  final Listenable? recalculateGlobalOffset;

  @override
  RenderLeader createRenderObject(BuildContext context) {
    return RenderLeader(
      link: link,
      recalculateGlobalOffset: recalculateGlobalOffset,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderLeader renderObject) {
    renderObject
      ..link = link
      ..recalculateGlobalOffset = recalculateGlobalOffset;
  }
}

/// [RenderObject] for a [Leader] widget, which reports an offset that
/// can be followed by a [Follower].
class RenderLeader extends RenderProxyBox {
  RenderLeader({
    required LeaderLink link,
    Listenable? recalculateGlobalOffset,
    RenderBox? child,
  })  : _link = link,
        super(child) {
    // Call the setter so that the listener is added.
    this.recalculateGlobalOffset = recalculateGlobalOffset;
  }

  @override
  void dispose() {
    _recalculateGlobalOffset?.removeListener(markNeedsPaint);
    super.dispose();
  }

  /// The link object that connects this [RenderLeader] with one or more
  /// [RenderFollowerLayer]s.
  ///
  /// This property must not be null. The object must not be associated with
  /// another [RenderLeader] that is also being painted.
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

  Listenable? _recalculateGlobalOffset;
  set recalculateGlobalOffset(Listenable? recalculateGlobalOffset) {
    if (recalculateGlobalOffset == _recalculateGlobalOffset) {
      return;
    }

    _recalculateGlobalOffset?.removeListener(markNeedsPaint);
    _recalculateGlobalOffset = recalculateGlobalOffset;
    _recalculateGlobalOffset?.addListener(markNeedsPaint);
  }

  @override
  bool get alwaysNeedsCompositing => true;

  // The latest size of this [RenderBox], computed during the previous layout
  // pass. It should always be equal to [size], but can be accessed even when
  // [debugDoingThisResize] and [debugDoingThisLayout] are false.
  Size? _previousLayoutSize;

  @override
  void performLayout() {
    FtlLogs.leader.finer(() => "Laying out Leader - $hashCode");
    super.performLayout();
    FtlLogs.leader.finer(() => " - leader size: $size");
    _previousLayoutSize = size;
    link.leaderSize = size;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    FtlLogs.leader.finer(() => "Painting Leader ($hashCode)");

    final globalOffset = localToGlobal(Offset.zero);
    final scale = (localToGlobal(const Offset(1, 0)) - localToGlobal(Offset.zero)).dx;
    final halfChildSize = child != null ? Offset(child!.size.width / 2, child!.size.height / 2) : Offset.zero;
    final scaledOffset = offset + halfChildSize - (halfChildSize * scale);
    FtlLogs.leader.finer(() => " - paint offset: $offset");
    FtlLogs.leader.finer(() => " - child: $child");
    FtlLogs.leader.finer(() => " - scaled paint offset: $scaledOffset");
    FtlLogs.leader.finer(() => " - global offset: $globalOffset");
    FtlLogs.leader.finer(() => " - follower content size (unscaled): ${child?.size}");
    FtlLogs.leader.finer(() => " - scale: $scale");

    final leaderToScreenTransform = getTransformTo(null);

    final screenToLeaderTransform = getTransformTo(null)..invert();

    link
      ..screenToLeader = screenToLeaderTransform
      ..leaderToScreen = leaderToScreenTransform
      ..leaderContentBoundsInLeaderSpace = child != null
          ? Offset.zero & child!.size // TODO: query the actual child offset for cases where its not zero
          : Rect.zero
      ..offset = globalOffset
      ..scale = scale;

    if (layer == null) {
      layer = LeaderLayer(
        link: link,
        offset: offset,
      );
    } else {
      final LeaderLayer leaderLayer = layer! as LeaderLayer;
      leaderLayer
        ..link = link
        ..offset = offset;
    }

    context.pushLayer(layer!, (paintContext, offset) {
      FtlLogs.leader.finer(() => "Painting leader content within LeaderLayer. Paint offset: $offset");
      super.paint(paintContext, offset);
    }, Offset.zero);
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
    FtlLogs.leader.finer(() => "Attaching LeaderLayer to owner: $owner");
    super.attach(owner);
    _lastOffset = null;
    link.leader = this;
  }

  @override
  void detach() {
    FtlLogs.leader.finer(() => "Detaching LeaderLayer from owner");
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
    FtlLogs.leader.finer(() => "Adding LeaderLayer to scene. Offset: $offset");
    _lastOffset = offset;
    if (offset != Offset.zero) {
      engineLayer = builder.pushTransform(
        Matrix4.translationValues(offset.dx, offset.dy, 0.0).storage,
        oldLayer: engineLayer as ui.TransformEngineLayer?,
      );
    }
    addChildrenToScene(builder);
    if (offset != Offset.zero) {
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
      transform.translateByDouble(_lastOffset!.dx, _lastOffset!.dy, 0, 0);
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Offset>('offset', offset));
    properties.add(DiagnosticsProperty<LeaderLink>('link', link));
  }
}
