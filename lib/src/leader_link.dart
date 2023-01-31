import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math_64.dart';

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

  /// Transform that maps a coordinate in screen-space to a coordinate
  /// in leader space.
  Matrix4? screenToLeader;

  /// Transform that maps a coordinate in leader-space to a coordinate
  /// in screen space.
  Matrix4? leaderToScreen;

  /// The bounds of the leader's child widget in leader-space.
  ///
  /// For example, if the leader's child sits at the leader's origin,
  /// the top-left of this [Rect] will be (0, 0).
  Rect? leaderContentBoundsInLeaderSpace;

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

  /// The current scale of the [Leader].
  double? get scale => _scale;
  double? _scale;
  set scale(double? newScale) {
    if (newScale == _scale) {
      return;
    }

    _scale = newScale;
    notifyListeners();
  }

  /// The size of the content of the connected [LeaderLayer].
  ///
  /// This is the un-scaled size of the [Leader] widget. The final [Leader]
  /// painting might be scaled up or down from this point. See [scale] for
  /// access to that information.
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

  Offset? getOffsetInLeader(Alignment alignment) {
    if (_offset == null || _leaderSize == null || _scale == null) {
      return null;
    }

    final leaderOriginOnScreenVec = leaderToScreen!.transform3(Vector3.zero());
    final leaderOriginOnScreen = Offset(leaderOriginOnScreenVec.x, leaderOriginOnScreenVec.y);
    final offsetInLeader = alignment.alongSize(leaderSize! * scale!);
    return leaderOriginOnScreen + offsetInLeader;

    // FtlLogs.link.fine("getOffsetInLeader - _offset: $_offset, _leaderSize: $_leaderSize, _scale: $_scale");
    // FtlLogs.link.fine(" - answer: ${_offset! + alignment.alongSize(_leaderSize! * _scale!)}");
    //
    // Offset leaderOrigin = Offset.zero;
    // if (_leader!.lastOffset != null) {
    //   final transform = Matrix4.identity();
    //   _leader!.applyTransform(null, transform);
    //   final leaderOriginVec = transform.transform3(Vector3(0, 0, 0));
    //   leaderOrigin = Offset(leaderOriginVec.x, leaderOriginVec.y);
    //   print(" - leader origin: $leaderOrigin");
    // } else {
    //   leaderOrigin = Offset.zero; //Offset(560, 0);
    // }
    // print(" - offset in leader without leader origin: ${_offset! + alignment.alongSize(_leaderSize! * _scale!)}");
    // print(
    //     " - offset in leader with leader origin: ${_offset! + alignment.alongSize(_leaderSize! * _scale!) + leaderOrigin}");
    //
    // return _offset! + alignment.alongSize(_leaderSize! * _scale!) + leaderOrigin;
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
