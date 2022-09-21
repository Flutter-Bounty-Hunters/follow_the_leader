import 'package:flutter/material.dart';
import 'package:follow_the_leader/follow_the_leader.dart';

import '_ios_popover_menu.dart';

class PopoverExample extends StatefulWidget {
  const PopoverExample({
    Key? key,
    required this.arrowDirection,
    required this.targetAnchor,
    required this.followerAnchor,
    required this.offset,
    required this.targetBuilder,
    this.targetPosition,
    this.targetAlignment,
  })  : assert(targetPosition != null || targetAlignment != null,
            'You must provide either a targetPosition or a targetAlignment'),
        assert(targetPosition == null || targetAlignment == null,
            "You can't provide both targetPosition and targetAlignment"),
        super(key: key);

  final ArrowDirection arrowDirection;
  final Alignment targetAnchor;
  final Alignment followerAnchor;
  final Offset offset;
  final WidgetBuilder targetBuilder;
  final TargetPosition? targetPosition;
  final Alignment? targetAlignment;

  @override
  State<PopoverExample> createState() => PopoverExampleState();
}

class PopoverExampleState extends State<PopoverExample> {
  final _screenBoundKey = GlobalKey();
  final CustomLayerLink _link = CustomLayerLink();  

  @override
  Widget build(BuildContext context) {
    final target = CustomCompositedTransformTarget(
      link: _link,
      child: widget.targetBuilder(context),
    );

    return SizedBox(
      key: _screenBoundKey,
      child: Stack(
        children: [
          if (widget.targetPosition != null) _buildTargetPosition(target),
          if (widget.targetAlignment != null) _buildTargetAlignment(target),
          _buildPopover(),
        ],
      ),
    );
  }

  Widget _buildTargetPosition(Widget target) {
    final position = widget.targetPosition!;
    return Positioned(
      left: position.left,
      right: position.right,
      top: position.top,
      bottom: position.bottom,
      child: target,
    );
  }

  Widget _buildTargetAlignment(Widget target) {
    return Align(
      alignment: widget.targetAlignment!,
      child: target,
    );
  }

  Widget _buildPopover() {
    return Positioned(
      left: 0,
      top: 0,
      child: LocationAwareCompositedTransformFollower(
        link: _link,
        boundaryKey: _screenBoundKey,
        targetAnchor: widget.targetAnchor,
        followerAnchor: widget.followerAnchor,
        offset: widget.offset,
        child: IosPopoverMenu(
          arrowDirection: widget.arrowDirection,
          radius: const Radius.circular(12),
          padding: const EdgeInsets.all(12.0),
          arrowWidth: 21,
          arrowLength: 20,
          backgroundColor: const Color(0xFF474747),
          child: const SizedBox(
            width: 254,
            height: 159,
            child: Center(
              child: Text(
                'Popover Content',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TargetPosition {
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;

  TargetPosition({
    this.top,
    this.left,
    this.right,
    this.bottom,
  });
}