import 'package:flutter/widgets.dart';
import 'package:follow_the_leader/follow_the_leader.dart';

/// A `Widget` that fades out when the [Leader] attached to the given [link]
/// exceeds the given [boundary].
///
/// For example, if the [boundary] represents the screen size, then when the
/// associated [Leader] widget moves outside the screen boundary, this widget
/// fades out. When the [Leader] re-enters the visible screen area, this
/// widget fades in.
class FollowerFadeOutBeyondBoundary extends StatelessWidget {
  const FollowerFadeOutBeyondBoundary({
    Key? key,
    required this.link,
    this.boundary,
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.linear,
    required this.child,
  }) : super(key: key);

  /// A [LeaderLink] that's attached to a [Leader] widget, whose offset
  /// determines whether this widget should be visible.
  final LeaderLink link;

  /// A [FollowerBoundary], which is combined with the [link] [Leader]'s
  /// offset, to determine whether this widget should be visible.
  final FollowerBoundary? boundary;

  /// [Duration] to fade out and fade in.
  final Duration duration;

  /// The animation [Curve] applied to the fade out and fade in animations.
  final Curve curve;

  /// A [Widget] that's following a [Leader] attached to the [link].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: link,
      builder: (context, value) {
        final isContentVisible = boundary == null || link.offset == null || boundary!.contains(link.offset!);
        return AnimatedOpacity(
          opacity: isContentVisible ? 1.0 : 0.0,
          duration: duration,
          curve: curve,
          child: child,
        );
      },
    );
  }
}
