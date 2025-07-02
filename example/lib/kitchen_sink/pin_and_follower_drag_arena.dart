import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:follow_the_leader/follow_the_leader.dart';
import 'package:overlord/follow_the_leader.dart';
import 'package:overlord/overlord.dart';

class PinAndFollowerDragArena extends StatefulWidget {
  const PinAndFollowerDragArena({
    super.key,
    required this.boundsInsets,
    required this.screenBoundsKey,
    required this.widgetBoundsKey,
    required this.config,
  });

  final EdgeInsets boundsInsets;
  final GlobalKey screenBoundsKey;
  final GlobalKey widgetBoundsKey;

  final FollowerDemoConfiguration config;

  @override
  State<PinAndFollowerDragArena> createState() => _PinAndFollowerDragArenaState();
}

class _PinAndFollowerDragArenaState extends State<PinAndFollowerDragArena> {
  final _pinLink = LeaderLink();
  final _pinOffset = ValueNotifier<Offset?>(null);

  void _onPanUpdate(DragUpdateDetails details) {
    _pinOffset.value = _pinOffset.value! + details.delta;
  }

  @override
  Widget build(BuildContext context) {
    if (_pinOffset.value == null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          _pinOffset.value = (context.findRenderObject() as RenderBox).size.center(Offset.zero);
        });
      });
    }

    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      child: Container(
        key: widget.screenBoundsKey,
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF222222),
        child: Stack(
          children: [
            Positioned.fill(
              child: _buildInnerBounds(),
            ),
            _pinOffset.value != null
                ? BuildInOrder(
                    children: [
                      _buildPin(),
                      _buildMenuFollower(),
                    ],
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildInnerBounds() {
    return Padding(
      padding: widget.boundsInsets,
      child: DecoratedBox(
        key: widget.widgetBoundsKey,
        decoration: BoxDecoration(
          border: Border.all(width: 2, color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
    );
  }

  Widget _buildPin() {
    return AnimatedBuilder(
      animation: _pinOffset,
      builder: (context, value) {
        return Stack(
          children: [
            Positioned(
              left: _pinOffset.value!.dx,
              top: _pinOffset.value!.dy,
              child: FractionalTranslation(
                translation: const Offset(-0.5, -0.5),
                child: Leader(
                  link: _pinLink,
                  child: const _Pin(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuFollower() {
    final menu = _buildMenu();

    late Widget follower;
    if (widget.config.followerDirection != FollowerDirection.automatic) {
      follower = Follower.withOffset(
        link: _pinLink,
        offset: widget.config.followerDirection.toOffset(20) ?? Offset.zero,
        leaderAnchor: widget.config.followerDirection.leaderAlignment!,
        followerAnchor: widget.config.followerDirection.followerAlignment!,
        boundary: widget.config.followerBoundary,
        repaintWhenLeaderChanges: true,
        child: menu,
      );
    } else {
      follower = Follower.withAligner(
        link: _pinLink,
        aligner: widget.config.aligner!,
        boundary: widget.config.followerBoundary,
        repaintWhenLeaderChanges: true,
        child: menu,
      );
    }

    return FollowerFadeOutBeyondBoundary(
      link: _pinLink,
      boundary: widget.config.followerBoundary,
      enabled: widget.config.fadeBeyondBoundary,
      child: follower,
    );
  }

  Widget _buildMenu() {
    switch (widget.config.followerMenuType) {
      case FollowerMenuType.smallPopover:
        return Container(
          width: 100,
          height: 54,
          color: Colors.red,
        );
      case FollowerMenuType.iOSToolbar:
        return CupertinoPopoverToolbar(
          focalPoint: LeaderMenuFocalPoint(link: _pinLink),
          children: _toolbarMenuItems,
        );
      case FollowerMenuType.iOSMenu:
        return CupertinoPopoverMenu(
          focalPoint: LeaderMenuFocalPoint(link: _pinLink),
          padding: const EdgeInsets.all(12.0),
          child: const SizedBox(
            width: 100,
            height: 54,
            child: Center(
              child: Text(
                'Popover Content',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        );
    }
  }
}

class FollowerDemoConfiguration {
  const FollowerDemoConfiguration({
    required this.followerDirection,
    required this.followerConstraints,
    this.followerBoundary,
    this.boundaryKey,
    required this.followerMenuType,
    this.aligner,
    required this.fadeBeyondBoundary,
  });

  final FollowerDirection followerDirection;
  final FollowerConstraint followerConstraints;
  final FollowerBoundary? followerBoundary;
  final GlobalKey? boundaryKey;
  final FollowerMenuType followerMenuType;
  final FollowerAligner? aligner;
  final bool fadeBeyondBoundary;

  FollowerDemoConfiguration clearBoundary() => FollowerDemoConfiguration(
        followerDirection: followerDirection,
        followerConstraints: followerConstraints,
        followerBoundary: null,
        boundaryKey: boundaryKey,
        followerMenuType: followerMenuType,
        aligner: aligner,
        fadeBeyondBoundary: fadeBeyondBoundary,
      );

  FollowerDemoConfiguration clearBoundaryKey() => FollowerDemoConfiguration(
        followerDirection: followerDirection,
        followerConstraints: followerConstraints,
        followerBoundary: followerBoundary,
        boundaryKey: null,
        followerMenuType: followerMenuType,
        aligner: aligner,
        fadeBeyondBoundary: fadeBeyondBoundary,
      );

  FollowerDemoConfiguration clearAligner() => FollowerDemoConfiguration(
        followerDirection: followerDirection,
        followerConstraints: followerConstraints,
        followerBoundary: followerBoundary,
        boundaryKey: boundaryKey,
        followerMenuType: followerMenuType,
        aligner: null,
        fadeBeyondBoundary: fadeBeyondBoundary,
      );

  FollowerDemoConfiguration copyWith({
    FollowerDirection? followerDirection,
    FollowerConstraint? followerConstraints,
    FollowerBoundary? followerBoundary,
    GlobalKey? boundaryKey,
    FollowerMenuType? menuType,
    FollowerAligner? aligner,
    bool? fadeBeyondBoundary,
  }) {
    return FollowerDemoConfiguration(
      followerDirection: followerDirection ?? this.followerDirection,
      followerConstraints: followerConstraints ?? this.followerConstraints,
      followerBoundary: followerBoundary ?? this.followerBoundary,
      boundaryKey: boundaryKey ?? this.boundaryKey,
      followerMenuType: menuType ?? this.followerMenuType,
      aligner: aligner ?? this.aligner,
      fadeBeyondBoundary: fadeBeyondBoundary ?? this.fadeBeyondBoundary,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FollowerDemoConfiguration &&
          runtimeType == other.runtimeType &&
          followerDirection == other.followerDirection &&
          followerConstraints == other.followerConstraints &&
          followerBoundary == other.followerBoundary &&
          boundaryKey == other.boundaryKey &&
          followerMenuType == other.followerMenuType &&
          aligner == other.aligner &&
          fadeBeyondBoundary == other.fadeBeyondBoundary;

  @override
  int get hashCode =>
      followerDirection.hashCode ^
      followerConstraints.hashCode ^
      followerBoundary.hashCode ^
      boundaryKey.hashCode ^
      followerMenuType.hashCode ^
      aligner.hashCode ^
      fadeBeyondBoundary.hashCode;
}

enum FollowerConstraint {
  none,
  screen,
  safeArea,
  keyboardOnly,
  keyboardAndScreen,
  bounds,
}

enum FollowerMenuType {
  smallPopover,
  iOSToolbar,
  iOSMenu,
}

enum FollowerDirection {
  up,
  down,
  left,
  right,
  automatic;

  Alignment? get leaderAlignment {
    switch (this) {
      case FollowerDirection.up:
        return Alignment.topCenter;
      case FollowerDirection.down:
        return Alignment.bottomCenter;
      case FollowerDirection.left:
        return Alignment.centerLeft;
      case FollowerDirection.right:
        return Alignment.centerRight;
      case FollowerDirection.automatic:
        return null;
    }
  }

  Alignment? get followerAlignment {
    switch (this) {
      case FollowerDirection.up:
        return Alignment.bottomCenter;
      case FollowerDirection.down:
        return Alignment.topCenter;
      case FollowerDirection.left:
        return Alignment.centerRight;
      case FollowerDirection.right:
        return Alignment.centerLeft;
      case FollowerDirection.automatic:
        return null;
    }
  }

  Offset? toOffset(double gap) {
    switch (this) {
      case FollowerDirection.up:
        return Offset(0, -gap);
      case FollowerDirection.down:
        return Offset(0, gap);
      case FollowerDirection.left:
        return Offset(-gap, 0);
      case FollowerDirection.right:
        return Offset(gap, 0);
      case FollowerDirection.automatic:
        return null;
    }
  }
}

class _Pin extends StatefulWidget {
  const _Pin({Key? key}) : super(key: key);

  @override
  State<_Pin> createState() => _PinState();
}

class _PinState extends State<_Pin> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addStatusListener((status) {
        switch (status) {
          case AnimationStatus.dismissed:
            // Start over.
            if (mounted) {
              _pulseController.forward();
            }
            break;
          case AnimationStatus.completed:
            if (mounted) {
              _pulseController.reverse();
            }
            break;
          case AnimationStatus.forward:
          case AnimationStatus.reverse:
            // no-op
            break;
        }
      });
    // ..forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("From pin perspective...");
    print(" - bottom insets: ${MediaQuery.viewInsetsOf(context).bottom}");
    print(" - bottom view padding: ${MediaQuery.viewPaddingOf(context).bottom}");
    print(" - bottom padding: ${MediaQuery.paddingOf(context).bottom}");
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 2,
                color: Colors.white.withValues(alpha: lerpDouble(0.5, 0.2, _pulseController.value)!),
              ),
              color: Colors.white.withValues(alpha: lerpDouble(0.25, 0.1, _pulseController.value)!),
            ),
          );
        },
      ),
    );
  }
}

final _toolbarMenuItems = [
  CupertinoPopoverToolbarMenuItem(
    label: 'Style',
    onPressed: () {
      // ignore: avoid_print
      print("Tapped 'style'");
    },
  ),
  CupertinoPopoverToolbarMenuItem(
    label: 'Duplicate',
    onPressed: () {
      // ignore: avoid_print
      print("Tapped 'duplicate'");
    },
  ),
  CupertinoPopoverToolbarMenuItem(
    label: 'Cut',
    onPressed: () {
      // ignore: avoid_print
      print("Tapped 'cut'");
    },
  ),
  CupertinoPopoverToolbarMenuItem(
    label: 'Copy',
    onPressed: () {
      // ignore: avoid_print
      print("Tapped 'copy'");
    },
  ),
  CupertinoPopoverToolbarMenuItem(
    label: 'Paste',
    onPressed: () {
      // ignore: avoid_print
      print("Tapped 'paste'");
    },
  ),
];
