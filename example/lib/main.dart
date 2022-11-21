import 'package:example/demo_boucing_ball.dart';
import 'package:example/ios_popover/demo_toolbar.dart';
import 'package:example/logging.dart';
import 'package:flutter/material.dart';
import 'package:follow_the_leader/follow_the_leader.dart';
import 'package:logging/logging.dart';

import 'demo_orbiting_circles.dart';
import 'ios_popover/demo_popover.dart';

void main() {
  FollowTheLeaderLogs.initLoggers(Level.FINEST, {
    followerLog,
    appLog,
  });
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
      debugShowCheckedModeBanner: false,
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
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  _MenuItem _selectedMenu = _items.first;

  void _closeDrawer() {
    if (_scaffoldKey.currentState!.isDrawerOpen) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      extendBodyBehindAppBar: true,
      body: _selectedMenu.pageBuilder(context),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SingleChildScrollView(
        primary: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final item in _items) ...[
                _DrawerButton(
                  title: item.title,
                  onPressed: () => setState(() {
                    _selectedMenu = item;
                    _closeDrawer();
                  }),
                  isSelected: _selectedMenu == item,
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

final _items = [
  _MenuItem(
    title: 'Orbiting Circles',
    pageBuilder: (context) => const OrbitingCirclesDemo(),
  ),
  _MenuItem(
    title: 'iOS Popover',
    pageBuilder: (context) => const PopoverDemo(),
  ),
  _MenuItem(
    title: 'iOS Toolbar',
    pageBuilder: (context) => const ToolbarDemo(),
  ),
  _MenuItem(
    title: 'Bouncing Ball',
    pageBuilder: (context) => const BoucingBallDemo(),
  ),
];

class _DrawerButton extends StatelessWidget {
  const _DrawerButton({
    Key? key,
    required this.title,
    this.isSelected = false,
    required this.onPressed,
  }) : super(key: key);

  final String title;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateColor.resolveWith((states) {
              if (isSelected) {
                return const Color(0xFFBBBBBB);
              }

              if (states.contains(MaterialState.hovered)) {
                return Colors.grey.withOpacity(0.1);
              }

              return Colors.transparent;
            }),
            foregroundColor:
                MaterialStateColor.resolveWith((states) => isSelected ? Colors.white : const Color(0xFFBBBBBB)),
            elevation: MaterialStateProperty.resolveWith((states) => 0),
            padding: MaterialStateProperty.resolveWith((states) => const EdgeInsets.all(16))),
        onPressed: isSelected ? null : onPressed,
        child: Center(child: Text(title)),
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem({
    required this.title,
    required this.pageBuilder,
  });

  final String title;
  final WidgetBuilder pageBuilder;
}
