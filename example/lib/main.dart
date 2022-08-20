import 'package:flutter/material.dart';

import 'demo_orbiting_circles.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Aware Follower',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ExampleApp(),
    );
  }
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  _ExampleAppState createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      extendBodyBehindAppBar: true,
      body: const OrbitingCirclesDemo(),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildDrawer() {
    return Drawer();
  }
}
