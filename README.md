<p align="center">
  <img src="https://github.com/Flutter-Bounty-Hunters/follow_the_leader/assets/7259036/fbf53127-4d2b-4e8e-901c-340dcd75c4a5" alt="Follow the Leader - Widgets following widgets">
</p>

<p align="center">
  <a href="https://flutterbountyhunters.com" target="_blank">
    <img src="https://github.com/Flutter-Bounty-Hunters/flutter_test_robots/assets/7259036/1b19720d-3dad-4ade-ac76-74313b67a898" alt="Built by the Flutter Bounty Hunters">
  </a>
</p>

---

## Getting Started
Select a widget that you want to follow and wrap it with a `Leader` widget. Give the `Leader`
widget a `LeaderLink`, to share with `Follower`s.

```dart
Leader(
  link: _leaderLink,
  child: YourLeaderWidget(),
);
```

Add a widget that you want to follow your `Leader`, and wrap it with a `Follower` widget.

```dart
// Follower appears 20px above the Leader.
Follower.withOffset(
  link: _leaderLink,
  offset: const Offset(0, -20),
  leaderAnchor: Alignment.topCenter,
  followerAnchor: Alignment.bottomCenter,
  child: YourFollowerWidget(),
);
```

`Follower`'s can position themselves with a constant distance from a `Leader` using `.withOffset()`,
as shown above. Or, `Follower`'s can choose their exact location on every frame by using
`.withAligner()`.

```dart
// Follower appears where the aligner says it should.
Follower.withAligner(
  link: _leaderLink,
  aligner: _aligner,
  child: YourFollowerWidget(),
);
```

To constrain where your `Follower` is allowed to appear, pass a `boundary` to your `Follower`.

```dart
// Follower is constrained by the given boundary.
Follower.withAligner(
  link: _leaderLink,
  aligner: _aligner,
  boundary: _boundary,
  child: YourFollowerWidget(),
);
```

## Building multiple widgets without layouts
Building follower widgets is a bit unusual with Flutter. Typically, whenever we build multiple
widgets in Flutter, we place them in a layout container, such as `Column`, `Row`, or `Stack`.
But follower widgets don't respect ancestor layout rules. That's the whole point.

`follow_the_leader` introduces a new container widget, which builds children, but doesn't attempt
to apply any particular layout rules. The primary purpose of this widget is to make it clear to
readers that you aren't trying to layout the children.

```dart
BuildInOrder(
  children: [
    MyContentWithALeader(),
    Follower.withOffset(),
    Follower.withDynamics(),
  ],
);
```

The `BuildInOrder` widget builds each child widget in the order that it's provided. This fact is
important because `Leader` widgets must be built before their `Follower`s. But `BuildInOrder` does
not impose any `Offset` on its children. `BuildInOrder` passes its parent's constraints down to the
`children`.
