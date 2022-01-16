import 'package:flutter/widgets.dart';

import 'render_follower_layer.dart';

class LocationAwareCompositedTransformFollower extends SingleChildRenderObjectWidget {
  /// Creates a composited transform target widget.
  ///
  /// The [link] property must not be null. If it was also provided to a
  /// [CompositedTransformTarget], that widget must come earlier in the paint
  /// order.
  ///
  /// The [showWhenUnlinked] and [offset] properties must also not be null.
  const LocationAwareCompositedTransformFollower({
    Key? key,
    required this.link,
    required this.boundaryKey,
    this.showWhenUnlinked = true,
    this.offset = Offset.zero,
    this.targetAnchor = Alignment.topLeft,
    this.followerAnchor = Alignment.topLeft,
    Widget? child,
  }) : super(key: key, child: child);

  /// The link object that connects this [CompositedTransformFollower] with a
  /// [CompositedTransformTarget].
  ///
  /// This property must not be null.
  final LayerLink link;

  final GlobalKey boundaryKey;

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

  /// The anchor point on the linked [CompositedTransformTarget] that
  /// [followerAnchor] will line up with.
  ///
  /// {@template flutter.widgets.CompositedTransformFollower.targetAnchor}
  /// For example, when [targetAnchor] and [followerAnchor] are both
  /// [Alignment.topLeft], this widget will be top left aligned with the linked
  /// [CompositedTransformTarget]. When [targetAnchor] is
  /// [Alignment.bottomLeft] and [followerAnchor] is [Alignment.topLeft], this
  /// widget will be left aligned with the linked [CompositedTransformTarget],
  /// and its top edge will line up with the [CompositedTransformTarget]'s
  /// bottom edge.
  /// {@endtemplate}
  ///
  /// Defaults to [Alignment.topLeft].
  final Alignment targetAnchor;

  /// The anchor point on this widget that will line up with [followerAnchor] on
  /// the linked [CompositedTransformTarget].
  ///
  /// {@macro flutter.widgets.CompositedTransformFollower.targetAnchor}
  ///
  /// Defaults to [Alignment.topLeft].
  final Alignment followerAnchor;

  /// The additional offset to apply to the [targetAnchor] of the linked
  /// [CompositedTransformTarget] to obtain this widget's [followerAnchor]
  /// position.
  final Offset offset;

  @override
  RenderFollowerLayer createRenderObject(BuildContext context) {
    return RenderFollowerLayer(
      link: link,
      boundaryKey: boundaryKey,
      showWhenUnlinked: showWhenUnlinked,
      offset: offset,
      leaderAnchor: targetAnchor,
      followerAnchor: followerAnchor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderFollowerLayer renderObject) {
    renderObject
      ..link = link
      ..boundaryKey = boundaryKey
      ..showWhenUnlinked = showWhenUnlinked
      ..offset = offset
      ..leaderAnchor = targetAnchor
      ..followerAnchor = followerAnchor;
  }
}
