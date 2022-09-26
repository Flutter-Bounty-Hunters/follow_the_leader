import 'package:flutter/material.dart';

import '_ios_popover_menu.dart';

class PopoverExample extends StatelessWidget {
  const PopoverExample({
    super.key,
    required this.focalPoint,
  });

  final Offset focalPoint;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IosPopoverMenu(
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
