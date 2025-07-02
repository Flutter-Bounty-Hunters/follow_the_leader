import 'package:example/kitchen_sink/kitchen_sink_desktop.dart';
import 'package:example/kitchen_sink/kitchen_sink_mobile.dart';
import 'package:example/kitchen_sink/pin_and_follower_drag_arena.dart';
import 'package:flutter/material.dart';
import 'package:follow_the_leader/follow_the_leader.dart';
import 'package:overlord/follow_the_leader.dart';

class KitchenSinkDemo extends StatefulWidget {
  const KitchenSinkDemo({Key? key}) : super(key: key);

  @override
  State<KitchenSinkDemo> createState() => _KitchenSinkDemoState();
}

class _KitchenSinkDemoState extends State<KitchenSinkDemo> {
  final _controller = KitchenSinkDemoController(
    screenBoundsKey: GlobalKey(),
    widgetBoundsKey: GlobalKey(),
  );

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: LayoutBuilder(builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return isMobile //
            ? KitchenSinkMobileScaffold(
                controller: _controller,
                child: _buildPinArena(isMobile: true),
              )
            : KitchenSinkDesktopScaffold(
                controller: _controller,
                child: _buildPinArena(isMobile: false),
              );
      }),
    );
  }

  Widget _buildPinArena({
    required bool isMobile,
  }) {
    return ListenableBuilder(
        listenable: _controller.config,
        builder: (context, child) {
          return PinAndFollowerDragArena(
            boundsInsets: isMobile //
                ? const EdgeInsets.only(left: 48, right: 48, top: 75, bottom: 48)
                : const EdgeInsets.only(left: 100, right: 100, top: 75, bottom: 175),
            screenBoundsKey: _controller.screenBoundsKey,
            widgetBoundsKey: _controller.widgetBoundsKey,
            config: _controller.config.value,
          );
        });
  }
}

class KitchenSinkDemoController {
  KitchenSinkDemoController({
    required this.screenBoundsKey,
    required this.widgetBoundsKey,
  });

  final GlobalKey screenBoundsKey;
  final GlobalKey widgetBoundsKey;

  final config = ValueNotifier(const FollowerDemoConfiguration(
    followerDirection: FollowerDirection.up,
    followerConstraints: FollowerConstraint.none,
    followerMenuType: FollowerMenuType.smallPopover,
    fadeBeyondBoundary: false,
  ));

  void onNoLimitsTap() {
    config.value = config.value
        .copyWith(
          followerConstraints: FollowerConstraint.none,
        )
        .clearBoundary()
        .clearBoundaryKey();

    configureToolbarAligner(config.value.followerDirection);
  }

  void onScreenBoundsTap() {
    config.value = config.value.copyWith(
      followerConstraints: FollowerConstraint.screen,
      followerBoundary: const ScreenFollowerBoundary(),
      boundaryKey: screenBoundsKey,
    );

    configureToolbarAligner(config.value.followerDirection);
  }

  void onSafeAreaBoundsTap() {
    config.value = config.value
        .copyWith(
          followerConstraints: FollowerConstraint.safeArea,
          followerBoundary: const SafeAreaFollowerBoundary(),
        )
        .clearBoundaryKey();

    configureToolbarAligner(config.value.followerDirection);
  }

  void onKeyboardOnlyBoundsTap() {
    config.value = config.value
        .copyWith(
          followerConstraints: FollowerConstraint.keyboardOnly,
          followerBoundary: const KeyboardFollowerBoundary(keepWithinScreen: false),
        )
        .clearBoundaryKey();

    configureToolbarAligner(config.value.followerDirection);
  }

  void onKeyboardAndScreenBoundsTap() {
    config.value = config.value
        .copyWith(
          followerConstraints: FollowerConstraint.keyboardAndScreen,
          followerBoundary: const KeyboardFollowerBoundary(),
        )
        .clearBoundaryKey();

    configureToolbarAligner(config.value.followerDirection);
  }

  void onWidgetBoundsTap() {
    config.value = config.value.copyWith(
      followerConstraints: FollowerConstraint.bounds,
      followerBoundary: WidgetFollowerBoundary(boundaryKey: widgetBoundsKey),
      boundaryKey: widgetBoundsKey,
    );

    configureToolbarAligner(config.value.followerDirection);
  }

  void toggleFadeBeyondBoundary() {
    config.value = config.value.copyWith(
      fadeBeyondBoundary: !config.value.fadeBeyondBoundary,
    );
  }

  void useGenericMenu() {
    config.value = config.value.copyWith(
      followerMenuType: FollowerMenuType.smallPopover,
    );

    configureToolbarAligner(config.value.followerDirection);
  }

  void useIOSToolbar() {
    config.value = config.value.copyWith(
      followerMenuType: FollowerMenuType.iOSToolbar,
    );

    configureToolbarAligner(config.value.followerDirection);
  }

  void useIOSPopover() {
    config.value = config.value.copyWith(
      followerMenuType: FollowerMenuType.iOSMenu,
    );

    configureToolbarAligner(config.value.followerDirection);
  }

  void configureToolbarAligner(FollowerDirection direction) {
    if (direction == FollowerDirection.automatic) {
      switch (config.value.followerMenuType) {
        case FollowerMenuType.iOSToolbar:
          config.value = config.value.copyWith(
            followerDirection: direction,
            aligner: CupertinoPopoverToolbarAligner(config.value.boundaryKey),
          );
          break;
        case FollowerMenuType.smallPopover:
        case FollowerMenuType.iOSMenu:
          config.value = config.value.copyWith(
            followerDirection: direction,
            aligner: CupertinoPopoverMenuAligner(config.value.boundaryKey),
          );
          break;
      }
    } else {
      config.value = config.value.copyWith(
        followerDirection: direction,
      )..clearAligner();
    }
  }
}
