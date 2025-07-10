# 0.5.0
### July 10, 2025
This release is the same as `0.0.5` - we're pushing up the version number to
opt-in to `0.` semver Pub upgrade rules. This will hopefully avoid unexpected
dependency upgrades for our users in the future.

# 0.0.5
### July 9, 2025
FEATURE: Created `KeyboardFollowerBoundary` based on the height reported by `super_keyboard`.
FEATURE: Created `SafeAreaFollowerBoundary` based on the padding reported by `MediaQuery`.
BREAKING: `FollowerBoundary` and `FollowerAligner` contracts have changed:
 * `FollowerBoundary` no longer does any positioning - it just returns a global rectangle.
 * `FollowerBoundary` now receives a `BuildContext` to help choose the boundary.
 * `FollowerAligner`s are now given the desired `globalBounds` and they make the decision
    about where to align the `Follower` given those bounds.
   * If the aligner still tries to position the `Follower` outside the `globalBounds`, then
     the `Follower` internally constrains itself to the nearest bounded offset.

# 0.0.4+8
### May, 2024
Hacked around a bug in tests related to render objects still being dirty after the test finishes.

# 0.0.4+7
### Nov, 2023
Added a `FunctionalAligner` for easier aligner implementations.

# 0.0.4+6
### Oct, 2023
Fix dirty paint state for `Follower`s in Linux golden tests.

# 0.0.4+5
### Sept, 2023
More fixes for `Follower` content alignment, e.g., iOS popovers. This fix schedules an extra paint frame if it tries to paint a `Follower` when the `FollowerLayer` isn't attached.

# 0.0.4+4
### Sept, 2023
Adjusted `Follower` internal transform management to solve iOS toolbar arrow alignment issues on
first frame, and when focal point moves.

# 0.0.4+3
### July, 2023
Fixes and adjustments.

 * FIX: Follower no longer drifts when it hits a boundary
 * CHANGE: Follower doesn't fade until the entire Leader leaves the boundary
 * Supports Dart 3

# 0.0.4+2
### Jan, 2023
`Leader` and `Follower` scaling.

 * Reworked `Follower` implementation to correctly handle scaling. Added bounds support for scaled `Leader`s and `Follower`s.

# 0.0.4+1
### Jan, 2023
Fix Leader offset reporting.

 * Fix `getOffsetInLeader` from last release by correctly applying `Leader` scale.

# 0.0.4
### Jan, 2023
Scrollables and scaling.

 * Added `recalculateGlobalOffset` to `Leader`, which should be used to notify `Leader`s when an ancestor `Scrollable` scrolls, so the `Leader` can notify `Follower`s that it moved.
 * Added `scale` and `getOffsetInLeader` to `LeaderLink` because the `Leader`'s scale was previously ignored.

# 0.0.3
### Dec, 2023
Easier following.

 * Breaking: `Follower.withDynamics` is now `Follower.withAligner`.
 * `LeaderLink` now mixes `ChangeNotifier` and notifies listeners when the `Leader` moves or changes size.
 * Added `Follower` property called `repaintWhenLeaderChanges`, which repaints the `Follower` child whenever the `Leader` moves or changes size.
 * Added `FollowerFadeOutBeyondBoundary` widget, which will fade out its child when the `Leader` exceeds a given `FollowerBoundary`.

# 0.0.2
### Dec, 2022
MVP release.

 * Primary widgets are now called `Leader` and `Follower`
 * The widget link in this package is now called `LeaderLink`
 * `Follower` supports customized alignment and boundaries
 * `BuildInOrder` lets you build `Follower`s without an implied layout

# 0.0.1
### Aug, 2022
Initial release.

 * Not ready for any production use, yet.