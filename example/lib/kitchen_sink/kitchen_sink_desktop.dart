import 'package:example/kitchen_sink/demo_kitchen_sink.dart';
import 'package:example/kitchen_sink/pin_and_follower_drag_arena.dart';
import 'package:flutter/material.dart';

class KitchenSinkDesktopScaffold extends StatelessWidget {
  const KitchenSinkDesktopScaffold({
    super.key,
    required this.controller,
    required this.child,
  });

  final KitchenSinkDemoController controller;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: child,
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildControls(),
        ),
      ],
    );
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
            _buildVisibilityOptions(),
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
            isActive: controller.config.value.followerConstraints != FollowerConstraint.none,
            icon: Icons.settings_overscan,
            tooltip: "No Restrictions",
            onPressed: controller.onNoLimitsTap,
          ),
          const Spacer(),
          _CircleRadioButton(
            isActive: controller.config.value.followerConstraints != FollowerConstraint.screen,
            icon: Icons.check_box_outline_blank,
            tooltip: "Restrict to Screen",
            onPressed: controller.onScreenBoundsTap,
          ),
          const Spacer(),
          _CircleRadioButton(
            isActive: controller.config.value.followerConstraints != FollowerConstraint.safeArea,
            icon: Icons.check_box_outline_blank,
            tooltip: "Restrict to Safe Area",
            onPressed: controller.onSafeAreaBoundsTap,
          ),
          const Spacer(),
          _CircleRadioButton(
            isActive: controller.config.value.followerConstraints != FollowerConstraint.bounds,
            icon: Icons.picture_in_picture,
            tooltip: "Restrict to Bounds",
            onPressed: controller.onWidgetBoundsTap,
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildVisibilityOptions() {
    return _CircleButton(
      isActive: !controller.config.value.fadeBeyondBoundary,
      icon: Icons.account_circle,
      tooltip: controller.config.value.fadeBeyondBoundary ? "Don't fade at boundary" : "Fade at boundary",
      onPressed: controller.toggleFadeBeyondBoundary,
    );
  }

  Widget _buildMenuTypes() {
    return SizedBox(
      width: 200,
      child: Row(
        children: [
          const Spacer(),
          _CircleRadioButton(
            isActive: controller.config.value.followerMenuType != FollowerMenuType.smallPopover,
            icon: Icons.person_pin,
            tooltip: "Small Popover",
            onPressed: controller.useGenericMenu,
          ),
          const Spacer(),
          _CircleRadioButton(
            isActive: controller.config.value.followerMenuType != FollowerMenuType.iOSToolbar,
            icon: Icons.call_to_action_outlined,
            tooltip: "iOS Toolbar",
            onPressed: controller.useIOSToolbar,
          ),
          const Spacer(),
          _CircleRadioButton(
            isActive: controller.config.value.followerMenuType != FollowerMenuType.iOSMenu,
            icon: Icons.filter_frames,
            tooltip: "iOS Popover",
            onPressed: controller.useIOSPopover,
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
                currentFollowerDirection: controller.config.value.followerDirection,
                buttonDirection: FollowerDirection.up,
                onPressed: controller.configureToolbarAligner,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _DirectionButton(
                currentFollowerDirection: controller.config.value.followerDirection,
                buttonDirection: FollowerDirection.down,
                onPressed: controller.configureToolbarAligner,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: _DirectionButton(
                currentFollowerDirection: controller.config.value.followerDirection,
                buttonDirection: FollowerDirection.left,
                onPressed: controller.configureToolbarAligner,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: _DirectionButton(
                currentFollowerDirection: controller.config.value.followerDirection,
                buttonDirection: FollowerDirection.right,
                onPressed: controller.configureToolbarAligner,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: _DirectionButton(
                currentFollowerDirection: controller.config.value.followerDirection,
                buttonDirection: FollowerDirection.automatic,
                onPressed: controller.configureToolbarAligner,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DirectionButton extends StatelessWidget {
  const _DirectionButton({
    Key? key,
    required this.currentFollowerDirection,
    required this.buttonDirection,
    required this.onPressed,
  }) : super(key: key);

  final FollowerDirection currentFollowerDirection;
  final FollowerDirection buttonDirection;
  final void Function(FollowerDirection) onPressed;

  bool get _isActive => currentFollowerDirection != buttonDirection;

  IconData get _icon {
    switch (buttonDirection) {
      case FollowerDirection.up:
        return Icons.arrow_drop_up;
      case FollowerDirection.down:
        return Icons.arrow_drop_down;
      case FollowerDirection.left:
        return Icons.arrow_left;
      case FollowerDirection.right:
        return Icons.arrow_right;
      case FollowerDirection.automatic:
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
        backgroundColor: isActive ? Colors.white.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1),
        tooltip: tooltip,
        onPressed: onPressed,
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.4),
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
        backgroundColor: isActive ? Colors.white.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1),
        tooltip: tooltip,
        onPressed: isActive ? () => onPressed() : null,
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.4),
          size: 18,
        ),
      ),
    );
  }
}
