import 'package:flutter/material.dart';

class HoverDemo extends StatefulWidget {
  const HoverDemo({Key? key}) : super(key: key);

  @override
  State<HoverDemo> createState() => _HoverDemoState();
}

class _HoverDemoState extends State<HoverDemo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF222222),
      child: Center(
        child: HoverPuck(
          color: Colors.red,
        ),
      ),
    );
  }
}

class HoverPuck extends StatelessWidget {
  const HoverPuck({
    Key? key,
    required this.color,
    this.elevation = 15,
  }) : super(key: key);

  final Color color;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      color: color,
      elevation: elevation,
      child: const SizedBox(
        width: 42,
        height: 42,
      ),
    );
  }
}
