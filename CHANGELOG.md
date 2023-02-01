# 0.0.4+2
`Leader` and `Follower` scaling (January, 2023)

 * Reworked `Follower` implementation to correctly handle scaling. Added bounds support for scaled `Leader`s and `Follower`s.

# 0.0.4+1
Fix Leader offset reporting (January, 2023)

 * Fix `getOffsetInLeader` from last release by correctly applying `Leader` scale.

# 0.0.4
Scrollables and scaling (January, 2023)

 * Added `recalculateGlobalOffset` to `Leader`, which should be used to notify `Leader`s when an ancestor `Scrollable` scrolls, so the `Leader` can notify `Follower`s that it moved.
 * Added `scale` and `getOffsetInLeader` to `LeaderLink` because the `Leader`'s scale was previously ignored.

# 0.0.3 
Easier following (December, 2022)

 * Breaking: `Follower.withDynamics` is now `Follower.withAligner`.
 * `LeaderLink` now mixes `ChangeNotifier` and notifies listeners when the `Leader` moves or changes size.
 * Added `Follower` property called `repaintWhenLeaderChanges`, which repaints the `Follower` child whenever the `Leader` moves or changes size.
 * Added `FollowerFadeOutBeyondBoundary` widget, which will fade out its child when the `Leader` exceeds a given `FollowerBoundary`.

# 0.0.2
MVP release (December, 2022)

 * Primary widgets are now called `Leader` and `Follower`
 * The widget link in this package is now called `LeaderLink`
 * `Follower` supports customized alignment and boundaries
 * `BuildInOrder` lets you build `Follower`s without an implied layout

# 0.0.1
Initial release (August, 2022)

 * Not ready for any production use, yet.