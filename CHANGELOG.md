# 0.0.4+7 - Nov, 2023
Added a `FunctionalAligner` for easier aligner implementations.

# 0.0.4+6 - Oct, 2023
Fix dirty paint state for `Follower`s in Linux golden tests.

# 0.0.4+5 - Sept, 2023
More fixes for `Follower` content alignment, e.g., iOS popovers. This fix schedules an extra paint frame if it tries to paint a `Follower` when the `FollowerLayer` isn't attached.

# 0.0.4+4 - Sept, 2023
Adjusted `Follower` internal transform management to solve iOS toolbar arrow alignment issues on
first frame, and when focal point moves.

# 0.0.4+3 - July, 2023
Fixes and adjustments.

 * FIX: Follower no longer drifts when it hits a boundary
 * CHANGE: Follower doesn't fade until the entire Leader leaves the boundary
 * Supports Dart 3

# 0.0.4+2 - Jan, 2023
`Leader` and `Follower` scaling.

 * Reworked `Follower` implementation to correctly handle scaling. Added bounds support for scaled `Leader`s and `Follower`s.

# 0.0.4+1 - Jan, 2023
Fix Leader offset reporting.

 * Fix `getOffsetInLeader` from last release by correctly applying `Leader` scale.

# 0.0.4 - Jan, 2023
Scrollables and scaling.

 * Added `recalculateGlobalOffset` to `Leader`, which should be used to notify `Leader`s when an ancestor `Scrollable` scrolls, so the `Leader` can notify `Follower`s that it moved.
 * Added `scale` and `getOffsetInLeader` to `LeaderLink` because the `Leader`'s scale was previously ignored.

# 0.0.3  - Dec, 2023
Easier following.

 * Breaking: `Follower.withDynamics` is now `Follower.withAligner`.
 * `LeaderLink` now mixes `ChangeNotifier` and notifies listeners when the `Leader` moves or changes size.
 * Added `Follower` property called `repaintWhenLeaderChanges`, which repaints the `Follower` child whenever the `Leader` moves or changes size.
 * Added `FollowerFadeOutBeyondBoundary` widget, which will fade out its child when the `Leader` exceeds a given `FollowerBoundary`.

# 0.0.2 - Dec, 2022
MVP release.

 * Primary widgets are now called `Leader` and `Follower`
 * The widget link in this package is now called `LeaderLink`
 * `Follower` supports customized alignment and boundaries
 * `BuildInOrder` lets you build `Follower`s without an implied layout

# 0.0.1 - Aug, 2022
Initial release.

 * Not ready for any production use, yet.