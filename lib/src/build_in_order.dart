import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

/// A [Widget] that builds its [children] in the order that they're provided,
/// using the constraints from this widget's parent.
///
/// Consider using [BuildInOrder] when you're building widgets that pull themselves
/// out of the standard layout protocol, such as `Follower` widgets. This widget
/// doesn't provide any special behavior for `Follower` widgets, or any others, but
/// this widget tells the reader that there's no intended layout behavior. Instead,
/// the only detail that matters is the build order of the children.
class BuildInOrder extends MultiChildRenderObjectWidget {
  const BuildInOrder({
    Key? key,
    required List<Widget> children,
  }) : super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderBuildInOrder();
  }
}

/// [RenderBox] for a [BuildInOrder] widget.
class RenderBuildInOrder extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, ContainerBoxParentData<RenderBox>>, RenderBoxContainerDefaultsMixin {
  @override
  ContainerBoxParentData<RenderBox> setupParentData(RenderBox child) {
    child.parentData = MultiChildLayoutParentData();
    return child.parentData as MultiChildLayoutParentData;
  }

  @override
  void performLayout() {
    size = constraints.biggest;

    final childConstraints = constraints.loosen();
    RenderBox? child = firstChild;
    while (child != null) {
      child.layout(childConstraints);
      child = childAfter(child);
    }
  }

  @override
  void paint(PaintingContext context, Offset? offset) {
    defaultPaint(context, offset ?? Offset.zero);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
