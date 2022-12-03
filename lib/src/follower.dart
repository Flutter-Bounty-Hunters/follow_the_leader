import 'dart:ui' as ui;

import 'package:flutter/rendering.dart' hide LeaderLayer;
import 'package:flutter/widgets.dart';
import 'package:follow_the_leader/follow_the_leader.dart';
import 'package:vector_math/vector_math_64.dart';

class Follower extends SingleChildRenderObjectWidget {
  // Follower.withOffset()
  //
  // Follower.withinBoundingRect()
  //
  // Follower.withinBoundingWidget()
  //
  // Follower.withDynamics()

  const Follower.withOffset({
    Key? key,
    required this.link,
    required this.boundaryKey,
    this.showWhenUnlinked = true,
    this.offset = Offset.zero,
    this.leaderAnchor = Alignment.topLeft,
    this.followerAnchor = Alignment.topLeft,
    Widget? child,
  })  : aligner = null,
        super(key: key, child: child);

  const Follower.withDynamics({
    Key? key,
    required this.link,
    required this.boundaryKey,
    required this.aligner,
    this.showWhenUnlinked = false,
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

  final GlobalKey boundaryKey;

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
  /// [CompositedTransformTarget] with the same [link].
  ///
  /// When the widget is linked, the child is positioned such that it has the
  /// same global position as the linked [CompositedTransformTarget].
  ///
  /// When the widget is not linked, then: if [showWhenUnlinked] is true, the
  /// child is visible and not repositioned; if it is false, then child is
  /// hidden.
  final bool showWhenUnlinked;

  @override
  RenderFollowerLayer createRenderObject(BuildContext context) {
    return RenderFollowerLayer(
      link: link,
      boundaryKey: boundaryKey,
      aligner: aligner,
      showWhenUnlinked: showWhenUnlinked,
      offset: offset,
      leaderAnchor: leaderAnchor,
      followerAnchor: followerAnchor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderFollowerLayer renderObject) {
    renderObject
      ..link = link
      ..boundaryKey = boundaryKey
      ..aligner = aligner
      ..showWhenUnlinked = showWhenUnlinked
      ..offset = offset
      ..leaderAnchor = leaderAnchor
      ..followerAnchor = followerAnchor;
  }
}

typedef FollowerAligner = FollowerAlignment Function(Rect globalLeaderRect, Size followerSize);

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

class RenderFollowerLayer extends RenderProxyBox {
  RenderFollowerLayer({
    required LeaderLink link,
    GlobalKey? boundaryKey,
    FollowerAligner? aligner,
    Alignment? leaderAnchor = Alignment.topLeft,
    Alignment? followerAnchor = Alignment.topLeft,
    Offset? offset = Offset.zero,
    bool showWhenUnlinked = true,
    RenderBox? child,
  })  : _link = link,
        _boundaryKey = boundaryKey,
        _aligner = aligner,
        _showWhenUnlinked = showWhenUnlinked,
        _offset = offset,
        _leaderAnchor = leaderAnchor,
        _followerAnchor = followerAnchor,
        super(child);

  @override
  void detach() {
    layer = null;
    super.detach();
  }

  /// The link object that connects this [RenderFollowerLayer] with a
  /// [RenderLeaderLayer] earlier in the paint order.
  LeaderLink get link => _link;
  LeaderLink _link;
  set link(LeaderLink value) {
    if (_link == value) return;
    FtlLogs.follower.fine("Setting new link");
    _link = value;
    _firstPaintOfCurrentLink = true;
    markNeedsPaint();
  }

  GlobalKey? get boundaryKey => _boundaryKey;
  GlobalKey? _boundaryKey;
  set boundaryKey(GlobalKey? newKey) {
    if (newKey == _boundaryKey) {
      return;
    }
    FtlLogs.follower.fine("Setting new boundaryKey");
    _boundaryKey = newKey;
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
    if (_showWhenUnlinked == value) return;
    _showWhenUnlinked = value;
    markNeedsPaint();
  }

  /// The offset to apply to the origin of the linked [RenderLeaderLayer] to
  /// obtain this render object's origin.
  Offset? get offset => _offset;
  Offset? _offset;
  set offset(Offset? value) {
    if (_offset == value) return;
    FtlLogs.follower.fine("Setting new follower offset");
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
  Alignment? get leaderAnchor => _leaderAnchor;
  Alignment? _leaderAnchor;
  set leaderAnchor(Alignment? value) {
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
  Alignment? get followerAnchor => _followerAnchor;
  Alignment? _followerAnchor;
  set followerAnchor(Alignment? value) {
    if (_followerAnchor == value) return;
    _followerAnchor = value;
    markNeedsPaint();
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
    final followerOffset = _previousFollowerOffset ?? Offset.zero;
    final transform = layer?.getLastTransform()?..translate(followerOffset.dx, followerOffset.dy);

    return result.addWithPaintTransform(
      transform: transform,
      position: position,
      hitTest: (BoxHitTestResult result, Offset position) {
        return super.hitTestChildren(result, position: position);
      },
    );
  }

  Offset? _previousFollowerOffset;
  Offset? get previousFollowerOffset => _previousFollowerOffset;

  /// Indicates whether or not we are in the first paint of the current [LeaderLink].
  bool _firstPaintOfCurrentLink = true;

  @override
  void paint(PaintingContext context, Offset offset) {
    FtlLogs.follower.fine("Painting composited follower: $offset");

    if (!link.leaderConnected && _previousFollowerOffset == null) {
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

    if (layer == null) {
      layer = FollowerLayer(
        link: link,
        showWhenUnlinked: showWhenUnlinked,
        linkedOffset: _previousFollowerOffset,
        unlinkedOffset: _previousFollowerOffset,
      );
    } else {
      layer
        ?..link = link
        ..showWhenUnlinked = showWhenUnlinked
        ..linkedOffset = _previousFollowerOffset
        ..unlinkedOffset = _previousFollowerOffset;
    }

    context.pushLayer(
      layer!,
      (context, offset) {
        FtlLogs.follower.fine("Painting follower content. Incoming offset: $offset");
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

  void _calculateFollowerOffset() {
    if (aligner != null) {
      _calculateFollowerOffsetWithAligner();
    } else {
      _calculateFollowerOffsetWithStaticValue();
    }
  }

  void _calculateFollowerOffsetWithAligner() {
    final globalLeaderRect = link.leader!.offset & link.leaderSize!;
    print("Global leader rect: $globalLeaderRect");
    final followerAlignment = aligner!.call(globalLeaderRect, size);
    final leaderAnchor = followerAlignment.leaderAnchor;
    final followerAnchor = followerAlignment.followerAnchor;

    final Size? leaderSize = link.leaderSize;
    assert(
      link.leaderSize != null || (!link.leaderConnected || leaderAnchor == Alignment.topLeft),
      '$link: layer is linked to ${link.leader} but a valid leaderSize is not set. '
      'leaderSize is required when leaderAnchor is not Alignment.topLeft '
      '(current value is $leaderAnchor).',
    );

    print("Leader alignment: $leaderAnchor, follower alignment: $followerAnchor");
    final Offset effectiveLinkedOffset =
        (leaderSize == null ? Offset.zero : leaderAnchor.alongSize(leaderSize) - followerAnchor.alongSize(size)) +
            followerAlignment.followerOffset;
    FtlLogs.follower.fine("Leader layer offset: ${link.leader!.offset}");
    final boundaryBox = boundaryKey!.currentContext!.findRenderObject() as RenderBox;
    FtlLogs.follower.fine("Boundary box size: ${boundaryBox.size}");
    FtlLogs.follower.fine("Follower box size: $size");
    // final boundaryOffset = boundaryBox.globalToLocal(localToGlobal(Offset.zero));
    final boundaryOffset = link.leader!.offset + effectiveLinkedOffset;
    print(
        "Boundary offset: $boundaryOffset, leader offset: ${link.leader!.offset}, effective offset: $effectiveLinkedOffset, offset: $offset, leader size: ${leaderAnchor.alongSize(leaderSize!)}, follower size: ${followerAnchor.alongSize(size)}");
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
    FtlLogs.follower.fine("Adjustment: $adjustment");

    _previousFollowerOffset = effectiveLinkedOffset + adjustment;
  }

  void _calculateFollowerOffsetWithStaticValue() {
    final globalLeaderRect = link.leader!.offset & link.leaderSize!;
    print("Global leader rect: $globalLeaderRect");

    final Size? leaderSize = link.leaderSize;
    assert(
      link.leaderSize != null || (!link.leaderConnected || leaderAnchor == Alignment.topLeft),
      '$link: layer is linked to ${link.leader} but a valid leaderSize is not set. '
      'leaderSize is required when leaderAnchor is not Alignment.topLeft '
      '(current value is $leaderAnchor).',
    );

    print("Leader alignment: $leaderAnchor, follower alignment: $followerAnchor, layer offset: $offset");
    final Offset effectiveLinkedOffset = (leaderSize == null
        ? offset!
        : leaderAnchor!.alongSize(leaderSize) - followerAnchor!.alongSize(size) + offset!);
    FtlLogs.follower.fine("Leader layer offset: ${link.leader!.offset}");
    final boundaryBox = boundaryKey!.currentContext!.findRenderObject() as RenderBox;
    FtlLogs.follower.fine("Boundary box size: ${boundaryBox.size}");
    FtlLogs.follower.fine("Follower box size: $size");
    // final boundaryOffset = boundaryBox.globalToLocal(localToGlobal(Offset.zero));
    final boundaryOffset = link.leader!.offset + effectiveLinkedOffset;
    print(
        "Boundary offset: $boundaryOffset, leader offset: ${link.leader!.offset}, effective offset: $effectiveLinkedOffset, offset: $offset, leader size: ${leaderAnchor!.alongSize(leaderSize!)}, follower size: ${followerAnchor!.alongSize(size)}");
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
    FtlLogs.follower.fine("Adjustment: $adjustment");

    _previousFollowerOffset = effectiveLinkedOffset + adjustment;
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.multiply(getCurrentTransform());
  }

  /// Return the transform that was used in the last composition phase, if any.
  ///
  /// If the [FollowerLayer] has not yet been created, was never composited, or
  /// was unable to determine the transform (see
  /// [FollowerLayer.getLastTransform]), this returns the identity matrix (see
  /// [Matrix4.identity].
  Matrix4 getCurrentTransform() {
    // return layer?.getLastTransform() ?? Matrix4.identity();

    final transform = layer?.getLastTransform() ?? Matrix4.identity();
    if (_previousFollowerOffset != null) {
      transform.translate(_previousFollowerOffset!.dx, _previousFollowerOffset!.dy);
    }
    return transform;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<LeaderLink>('link', link));
    properties.add(DiagnosticsProperty<bool>('showWhenUnlinked', showWhenUnlinked));
    properties.add(DiagnosticsProperty<Offset>('offset', offset));
    properties.add(TransformProperty('current transform matrix', getCurrentTransform()));
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
  /// Creates a follower layer.
  ///
  /// The [link] property must not be null.
  ///
  /// The [unlinkedOffset], [linkedOffset], and [showWhenUnlinked] properties
  /// must be non-null before the compositing phase of the pipeline.
  FollowerLayer({
    required LeaderLink link,
    this.showWhenUnlinked = true,
    this.unlinkedOffset = Offset.zero,
    this.linkedOffset = Offset.zero,
  }) : _link = link;

  /// The link to the [LeaderLayer].
  ///
  /// The same object should be provided to a [LeaderLayer] that is earlier in
  /// the layer tree. When this layer is composited, it will apply a transform
  /// that moves its children to match the position of the [LeaderLayer].
  LeaderLink get link => _link;
  set link(LeaderLink value) {
    if (value != _link && _leaderHandle != null) {
      _leaderHandle!.dispose();
      _leaderHandle = value.registerFollower();
    }
    _link = value;
  }

  LeaderLink _link;

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

  CustomLayerLinkHandle? _leaderHandle;

  @override
  void attach(Object owner) {
    super.attach(owner);
    _leaderHandle = _link.registerFollower();
  }

  @override
  void detach() {
    super.detach();
    _leaderHandle?.dispose();
    _leaderHandle = null;
  }

  Offset? _lastOffset;
  Matrix4? _lastTransform;
  Matrix4? _invertedTransform;
  bool _inverseDirty = true;

  Offset? _transformOffset(Offset localPosition) {
    if (_inverseDirty) {
      _invertedTransform = Matrix4.tryInvert(getLastTransform()!);
      _inverseDirty = false;
    }
    if (_invertedTransform == null) {
      return null;
    }
    final Vector4 vector = Vector4(localPosition.dx, localPosition.dy, 0.0, 1.0);
    final Vector4 result = _invertedTransform!.transform(vector);
    return Offset(result[0] - linkedOffset!.dx, result[1] - linkedOffset!.dy);
  }

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
    final Matrix4 result = Matrix4.translationValues(-_lastOffset!.dx, -_lastOffset!.dy, 0.0);
    result.multiply(_lastTransform!);
    return result;
  }

  /// Call [applyTransform] for each layer in the provided list.
  ///
  /// The list is in reverse order (deepest first). The first layer will be
  /// treated as the child of the second, and so forth. The first layer in the
  /// list won't have [applyTransform] called on it. The first layer may be
  /// null.
  static Matrix4 _collectTransformForLayerChain(List<ContainerLayer?> layers) {
    // Initialize our result matrix.
    final Matrix4 result = Matrix4.identity();
    // Apply each layer to the matrix in turn, starting from the last layer,
    // and providing the previous layer as the child.
    for (int index = layers.length - 1; index > 0; index -= 1) {
      layers[index]?.applyTransform(layers[index - 1], result);
    }
    return result;
  }

  /// Find the common ancestor of two layers [a] and [b] by searching towards
  /// the root of the tree, and append each ancestor of [a] or [b] visited along
  /// the path to [ancestorsA] and [ancestorsB] respectively.
  ///
  /// Returns null if [a] [b] do not share a common ancestor, in which case the
  /// results in [ancestorsA] and [ancestorsB] are undefined.
  static Layer? _pathsToCommonAncestor(
    Layer? a,
    Layer? b,
    List<ContainerLayer?> ancestorsA,
    List<ContainerLayer?> ancestorsB,
  ) {
    // No common ancestor found.
    if (a == null || b == null) {
      return null;
    }

    if (identical(a, b)) {
      return a;
    }

    if (a.depth < b.depth) {
      ancestorsB.add(b.parent);
      return _pathsToCommonAncestor(a, b.parent, ancestorsA, ancestorsB);
    } else if (a.depth > b.depth) {
      ancestorsA.add(a.parent);
      return _pathsToCommonAncestor(a.parent, b, ancestorsA, ancestorsB);
    }

    ancestorsA.add(a.parent);
    ancestorsB.add(b.parent);
    return _pathsToCommonAncestor(a.parent, b.parent, ancestorsA, ancestorsB);
  }

  /// Populate [_lastTransform] given the current state of the tree.
  void _establishTransform() {
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
    final List<ContainerLayer?> forwardLayers = <ContainerLayer>[leader];
    // Stores [this (follower), ..., commonAncestor] after calling
    // _pathsToCommonAncestor.
    final List<ContainerLayer?> inverseLayers = <ContainerLayer>[this];

    final Layer? ancestor = _pathsToCommonAncestor(
      leader,
      this,
      forwardLayers,
      inverseLayers,
    );
    assert(ancestor != null);

    final Matrix4 forwardTransform = _collectTransformForLayerChain(forwardLayers);
    // Further transforms the coordinate system to a hypothetical child (null)
    // of the leader layer, to account for the leader's additional paint offset
    // and layer offset (LeaderLayer._lastOffset).
    leader.applyTransform(null, forwardTransform);
    forwardTransform.translate(linkedOffset!.dx, linkedOffset!.dy);

    final Matrix4 inverseTransform = _collectTransformForLayerChain(inverseLayers);

    if (inverseTransform.invert() == 0.0) {
      // We are in a degenerate transform, so there's not much we can do.
      return;
    }
    // Combine the matrices and store the result.
    inverseTransform.multiply(forwardTransform);
    _lastTransform = inverseTransform;
    _inverseDirty = true;
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

  @override
  void applyTransform(Layer? child, Matrix4 transform) {
    assert(child != null);
    if (_lastTransform != null) {
      transform.multiply(_lastTransform!);
    } else {
      transform.multiply(Matrix4.translationValues(unlinkedOffset!.dx, unlinkedOffset!.dy, 0));
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<LeaderLink>('link', link));
    properties.add(TransformProperty('transform', getLastTransform(), defaultValue: null));
  }
}
