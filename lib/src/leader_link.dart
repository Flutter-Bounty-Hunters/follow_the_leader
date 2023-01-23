import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart' hide LeaderLayer;
import 'package:flutter/scheduler.dart';

import 'leader.dart';

/// Links one or more [Follower] positions to a [Leader].
class LeaderLink with ChangeNotifier {
  /// Whether a [LeaderLayer] is currently connected to this link.
  bool get leaderConnected => _leader != null;

  LeaderLayer? get leader => _leader;
  LeaderLayer? _leader;
  set leader(LeaderLayer? newLeader) {
    if (newLeader == _leader) {
      return;
    }

    _leader = newLeader;
  }

  /// Global offset for the top-left corner of the [Leader]'s content.
  Offset? get offset => _offset;
  Offset? _offset;
  set offset(Offset? newOffset) {
    if (newOffset == _offset) {
      return;
    }

    _offset = newOffset;
    notifyListeners();
  }

  /// The total size of the content of the connected [LeaderLayer].
  ///
  /// Generally this should be set by the [RenderObject] that paints on the
  /// registered [LeaderLayer] (for instance a [RenderLeaderLayer] that shares
  /// this link with its followers). This size may be outdated before and during
  /// layout.
  Size? get leaderSize => _leaderSize;
  Size? _leaderSize;
  set leaderSize(Size? newSize) {
    if (newSize == _leaderSize) {
      return;
    }

    _leaderSize = newSize;
    notifyListeners();
  }

  bool get hasFollowers => _connectedFollowers > 0;
  int _connectedFollowers = 0;

  /// Called by the [FollowerLayer] to establish a link to a [LeaderLayer].
  ///
  /// The returned [LayerLinkHandle] provides access to the leader via
  /// [LayerLinkHandle.leader].
  ///
  /// When the [FollowerLayer] no longer wants to follow the [LeaderLayer],
  /// [LayerLinkHandle.dispose] must be called to disconnect the link.
  CustomLayerLinkHandle registerFollower() {
    assert(_connectedFollowers >= 0);
    _connectedFollowers++;
    return CustomLayerLinkHandle(this);
  }

  @override
  void notifyListeners() {
    if (WidgetsBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      // We're in the middle of a layout and paint phase. Notify listeners
      // at the end of the frame.
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        super.notifyListeners();
      });
      return;
    }

    // We're not in a layout/paint phase. Immediately notify listeners.
    super.notifyListeners();
  }

  @override
  String toString() => '${describeIdentity(this)}(${leader != null ? "<linked>" : "<dangling>"})';
}

/// A handle provided by [LeaderLink.registerFollower] to a calling
/// [FollowerLayer] to establish a link between that [FollowerLayer] and a
/// [LeaderLayer].
///
/// If the link is no longer needed, [dispose] must be called to disconnect it.
class CustomLayerLinkHandle {
  CustomLayerLinkHandle(this._link);

  LeaderLink? _link;

  /// The currently-registered [LeaderLayer], if any.
  LeaderLayer? get leader => _link!.leader;

  /// Disconnects the link between the [FollowerLayer] owning this handle and
  /// the [leader].
  ///
  /// The [LayerLinkHandle] becomes unusable after calling this method.
  void dispose() {
    assert(_link!._connectedFollowers > 0);
    _link!._connectedFollowers--;
    _link = null;
  }
}
