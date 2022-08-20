import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart' hide LeaderLayer;

import 'leader.dart';

class CustomLayerLink {
  /// Whether a [CustomLeaderLayer] is currently connected to this link.
  bool get leaderConnected => leader != null;
  CustomLeaderLayer? leader;

  /// The total size of the content of the connected [CustomLeaderLayer].
  ///
  /// Generally this should be set by the [RenderObject] that paints on the
  /// registered [CustomLeaderLayer] (for instance a [RenderLeaderLayer] that shares
  /// this link with its followers). This size may be outdated before and during
  /// layout.
  Size? leaderSize;

  bool get hasFollowers => _connectedFollowers > 0;
  int _connectedFollowers = 0;

  /// Called by the [FollowerLayer] to establish a link to a [CustomLeaderLayer].
  ///
  /// The returned [LayerLinkHandle] provides access to the leader via
  /// [LayerLinkHandle.leader].
  ///
  /// When the [FollowerLayer] no longer wants to follow the [CustomLeaderLayer],
  /// [LayerLinkHandle.dispose] must be called to disconnect the link.
  CustomLayerLinkHandle registerFollower() {
    assert(_connectedFollowers >= 0);
    _connectedFollowers++;
    return CustomLayerLinkHandle(this);
  }

  @override
  String toString() => '${describeIdentity(this)}(${leader != null ? "<linked>" : "<dangling>"})';
}

/// A handle provided by [CustomLayerLink.registerFollower] to a calling
/// [FollowerLayer] to establish a link between that [FollowerLayer] and a
/// [CustomLeaderLayer].
///
/// If the link is no longer needed, [dispose] must be called to disconnect it.
class CustomLayerLinkHandle {
  CustomLayerLinkHandle(this._link);

  CustomLayerLink? _link;

  /// The currently-registered [CustomLeaderLayer], if any.
  CustomLeaderLayer? get leader => _link!.leader;

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
