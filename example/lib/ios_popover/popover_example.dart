import 'package:flutter/material.dart';
import 'package:overlord/overlord.dart';

/// An example of an [IosPopoverMenu] usage.
///
/// This example includes an [IosPopoverMenu] with fixed content.
class PopoverExample extends StatelessWidget {
  const PopoverExample({
    super.key,
    required this.focalPoint,
  });

  final Offset focalPoint;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CupertinoPopoverMenu(
        globalFocalPoint: focalPoint,
        padding: const EdgeInsets.all(12.0),
        arrowBaseWidth: 21,
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
    );
  }
}
