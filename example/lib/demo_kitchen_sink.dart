import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:follow_the_leader/follow_the_leader.dart';
import 'package:overlord/overlord.dart';
import 'package:overlord/follow_the_leader.dart';

class KitchenSinkDemo extends StatefulWidget {
  const KitchenSinkDemo({Key? key}) : super(key: key);

  @override
  State<KitchenSinkDemo> createState() => _KitchenSinkDemoState();
}

class _KitchenSinkDemoState extends State<KitchenSinkDemo> {
  final _screenBoundsKey = GlobalKey();
  final _innerBoundsKey = GlobalKey();
  final _pinLink = LeaderLink();

  final _pinOffset = ValueNotifier<Offset?>(null);
  _FollowerDirection _followerDirection = _FollowerDirection.up;
  _FollowerConstraint _followerConstraints = _FollowerConstraint.none;
  _MenuType _menuType = _MenuType.smallPopover;

  GlobalKey? _boundaryKey;
  FollowerBoundary? _boundary;
  FollowerAligner? _aligner;
  bool _fadeBeyondBoundary = false;

  void _onPanUpdate(DragUpdateDetails details) {
    _pinOffset.value = _pinOffset.value! + details.delta;
  }

  void _onNoLimitsTap() {
    setState(() {
      _followerConstraints = _FollowerConstraint.none;
      _boundaryKey = null;
      _boundary = null;
      _configureToolbarAligner(_followerDirection);
    });
  }

  void _onScreenBoundsTap() {
    setState(() {
      _followerConstraints = _FollowerConstraint.screen;
      _boundaryKey = _screenBoundsKey;
      _boundary = ScreenFollowerBoundary(MediaQuery.of(context).size);
      _configureToolbarAligner(_followerDirection);
    });
  }

  void _onWidgetBoundsTap() {
    setState(() {
      _followerConstraints = _FollowerConstraint.bounds;
      _boundaryKey = _innerBoundsKey;
      _boundary = WidgetFollowerBoundary(_innerBoundsKey);
      _configureToolbarAligner(_followerDirection);
    });
  }

  void _toggleFadeBeyondBoundary() {
    setState(() {
      _fadeBeyondBoundary = !_fadeBeyondBoundary;
    });
  }

  void _onGenericMenuTap() {
    setState(() {
      _menuType = _MenuType.smallPopover;
      _configureToolbarAligner(_followerDirection);
    });
  }

  void _onIOSToolbarTap() {
    setState(() {
      _menuType = _MenuType.iOSToolbar;
      _configureToolbarAligner(_followerDirection);
    });
  }

  void _onIOSPopoverMenuTap() {
    setState(() {
      _menuType = _MenuType.iOSMenu;
      _configureToolbarAligner(_followerDirection);
    });
  }

  void _configureToolbarAligner(_FollowerDirection direction) {
    setState(() {
      _followerDirection = direction;

      if (direction == _FollowerDirection.automatic) {
        switch (_menuType) {
          case _MenuType.iOSToolbar:
            _aligner = CupertinoPopoverToolbarAligner(_boundaryKey);
            break;
          case _MenuType.smallPopover:
          case _MenuType.iOSMenu:
            _aligner = CupertinoPopoverMenuAligner(_boundaryKey);
            break;
        }
      }
    });
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

    return Theme(
      data: ThemeData.dark(),
      child: GestureDetector(
        onPanUpdate: _onPanUpdate,
        child: Container(
          key: _screenBoundsKey,
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
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildControls(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInnerBounds() {
    return Padding(
      padding: const EdgeInsets.only(left: 100, right: 100, top: 75, bottom: 175),
      child: DecoratedBox(
        key: _innerBoundsKey,
        decoration: BoxDecoration(
          border: Border.all(width: 2, color: Colors.white.withOpacity(0.05)),
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
    if (_followerDirection != _FollowerDirection.automatic) {
      follower = Follower.withOffset(
        link: _pinLink,
        offset: _followerDirection.toOffset(20) ?? Offset.zero,
        leaderAnchor: _followerDirection.leaderAlignment!,
        followerAnchor: _followerDirection.followerAlignment!,
        boundary: _boundary,
        repaintWhenLeaderChanges: true,
        child: menu,
      );
    } else {
      follower = Follower.withAligner(
        link: _pinLink,
        aligner: _aligner!,
        boundary: _boundary,
        repaintWhenLeaderChanges: true,
        child: menu,
      );
    }

    return FollowerFadeOutBeyondBoundary(
      link: _pinLink,
      boundary: _boundary,
      enabled: _fadeBeyondBoundary,
      child: follower,
    );
  }

  Widget _buildMenu() {
    switch (_menuType) {
      case _MenuType.smallPopover:
        return Container(
          width: 100,
          height: 54,
          color: Colors.red,
        );
      case _MenuType.iOSToolbar:
        return CupertinoPopoverToolbar(
          focalPoint: LeaderMenuFocalPoint(link: _pinLink),
          children: _toolbarMenuItems,
        );
      case _MenuType.iOSMenu:
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

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: SizedBox(
        width: double.infinity,
        height: 120,
        child: Row(
          children: [
            const Spacer(),
            _buildFollowerOptions(),
            const Spacer(),
            _buildDirectionPad(),
            const Spacer(),
            _buildVisabilityOptions(),
            const Spacer(),
            _buildMenuTypes(),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowerOptions() {
    return SizedBox(
      width: 200,
      child: Row(
        children: [
          const Spacer(),
          _CircleRadioButton(
            isActive: _followerConstraints != _FollowerConstraint.none,
            icon: Icons.settings_overscan,
            tooltip: "No Restrictions",
            onPressed: _onNoLimitsTap,
          ),
          const Spacer(),
          _CircleRadioButton(
            isActive: _followerConstraints != _FollowerConstraint.screen,
            icon: Icons.check_box_outline_blank,
            tooltip: "Restrict to Screen",
            onPressed: _onScreenBoundsTap,
          ),
          const Spacer(),
          _CircleRadioButton(
            isActive: _followerConstraints != _FollowerConstraint.bounds,
            icon: Icons.picture_in_picture,
            tooltip: "Restrict to Bounds",
            onPressed: _onWidgetBoundsTap,
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildVisabilityOptions() {
    return _CircleButton(
      isActive: !_fadeBeyondBoundary,
      icon: Icons.account_circle,
      tooltip: _fadeBeyondBoundary ? "Don't fade at boundary" : "Fade at boundary",
      onPressed: _toggleFadeBeyondBoundary,
    );
  }

  Widget _buildMenuTypes() {
    return SizedBox(
      width: 200,
      child: Row(
        children: [
          const Spacer(),
          _CircleRadioButton(
            isActive: _menuType != _MenuType.smallPopover,
            icon: Icons.person_pin,
            tooltip: "Small Popover",
            onPressed: _onGenericMenuTap,
          ),
          const Spacer(),
          _CircleRadioButton(
            isActive: _menuType != _MenuType.iOSToolbar,
            icon: Icons.call_to_action_outlined,
            tooltip: "iOS Toolbar",
            onPressed: _onIOSToolbarTap,
          ),
          const Spacer(),
          _CircleRadioButton(
            isActive: _menuType != _MenuType.iOSMenu,
            icon: Icons.filter_frames,
            tooltip: "iOS Popover",
            onPressed: _onIOSPopoverMenuTap,
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildDirectionPad() {
    return RepaintBoundary(
      child: SizedBox(
        width: 120,
        height: 120,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: _DirectionButton(
                currentFollowerDirection: _followerDirection,
                buttonDirection: _FollowerDirection.up,
                onPressed: _configureToolbarAligner,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _DirectionButton(
                currentFollowerDirection: _followerDirection,
                buttonDirection: _FollowerDirection.down,
                onPressed: _configureToolbarAligner,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: _DirectionButton(
                currentFollowerDirection: _followerDirection,
                buttonDirection: _FollowerDirection.left,
                onPressed: _configureToolbarAligner,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: _DirectionButton(
                currentFollowerDirection: _followerDirection,
                buttonDirection: _FollowerDirection.right,
                onPressed: _configureToolbarAligner,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: _DirectionButton(
                currentFollowerDirection: _followerDirection,
                buttonDirection: _FollowerDirection.automatic,
                onPressed: _configureToolbarAligner,
              ),
            ),
          ],
        ),
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

class _DirectionButton extends StatelessWidget {
  const _DirectionButton({
    Key? key,
    required this.currentFollowerDirection,
    required this.buttonDirection,
    required this.onPressed,
  }) : super(key: key);

  final _FollowerDirection currentFollowerDirection;
  final _FollowerDirection buttonDirection;
  final void Function(_FollowerDirection) onPressed;

  bool get _isActive => currentFollowerDirection != buttonDirection;

  IconData get _icon {
    switch (buttonDirection) {
      case _FollowerDirection.up:
        return Icons.arrow_drop_up;
      case _FollowerDirection.down:
        return Icons.arrow_drop_down;
      case _FollowerDirection.left:
        return Icons.arrow_left;
      case _FollowerDirection.right:
        return Icons.arrow_right;
      case _FollowerDirection.automatic:
        return Icons.smart_toy_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _CircleRadioButton(
      isActive: _isActive,
      icon: _icon,
      onPressed: () => onPressed(buttonDirection),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    Key? key,
    required this.isActive,
    required this.icon,
    this.tooltip,
    required this.onPressed,
  }) : super(key: key);

  final bool isActive;
  final IconData icon;
  final String? tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: FloatingActionButton(
        mini: true,
        backgroundColor: isActive ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.1),
        tooltip: tooltip,
        onPressed: onPressed,
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
          size: 18,
        ),
      ),
    );
  }
}

class _CircleRadioButton extends StatelessWidget {
  const _CircleRadioButton({
    Key? key,
    required this.isActive,
    required this.icon,
    this.tooltip,
    required this.onPressed,
  }) : super(key: key);

  final bool isActive;
  final IconData icon;
  final String? tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: FloatingActionButton(
        mini: true,
        backgroundColor: isActive ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.1),
        tooltip: tooltip,
        onPressed: isActive ? () => onPressed() : null,
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
          size: 18,
        ),
      ),
    );
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
    )
      ..addStatusListener((status) {
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
      })
      ..forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
                  Border.all(width: 2, color: Colors.white.withOpacity(lerpDouble(0.5, 0.2, _pulseController.value)!)),
              color: Colors.white.withOpacity(lerpDouble(0.25, 0.1, _pulseController.value)!),
            ),
          );
        },
      ),
    );
  }
}

enum _FollowerConstraint {
  none,
  screen,
  bounds,
}

enum _MenuType {
  smallPopover,
  iOSToolbar,
  iOSMenu,
}

enum _FollowerDirection {
  up,
  down,
  left,
  right,
  automatic;

  Alignment? get leaderAlignment {
    switch (this) {
      case _FollowerDirection.up:
        return Alignment.topCenter;
      case _FollowerDirection.down:
        return Alignment.bottomCenter;
      case _FollowerDirection.left:
        return Alignment.centerLeft;
      case _FollowerDirection.right:
        return Alignment.centerRight;
      case _FollowerDirection.automatic:
        return null;
    }
  }

  Alignment? get followerAlignment {
    switch (this) {
      case _FollowerDirection.up:
        return Alignment.bottomCenter;
      case _FollowerDirection.down:
        return Alignment.topCenter;
      case _FollowerDirection.left:
        return Alignment.centerRight;
      case _FollowerDirection.right:
        return Alignment.centerLeft;
      case _FollowerDirection.automatic:
        return null;
    }
  }

  Offset? toOffset(double gap) {
    switch (this) {
      case _FollowerDirection.up:
        return Offset(0, -gap);
      case _FollowerDirection.down:
        return Offset(0, gap);
      case _FollowerDirection.left:
        return Offset(-gap, 0);
      case _FollowerDirection.right:
        return Offset(gap, 0);
      case _FollowerDirection.automatic:
        return null;
    }
  }
}
