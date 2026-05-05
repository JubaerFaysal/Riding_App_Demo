import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class AgoraController extends GetxController {
  final logger = Logger();

  late RtcEngine agoraEngine;

  // Tracks whether a join is currently in progress, so we can guard
  Completer<void>? _joinCompleter;

  // Observable state
  final Rx<bool> isInitialized = false.obs;
  final Rx<bool> isJoined = false.obs;
  final Rx<bool> isMicEnabled = true.obs;
  final Rx<bool> isCameraEnabled = true.obs;
  final RxList<int> remoteUids = <int>[].obs;

  static const String agoraAppId = '4debdf89c6f24ff8ad5ec4de7834ca67';
  static const String agoraToken = '';

  @override
  void onInit() {
    super.onInit();
    _initializeAgora();
  }

  Future<void> _initializeAgora() async {
    try {
      agoraEngine = createAgoraRtcEngine();

      await agoraEngine.initialize(
        RtcEngineContext(
          appId: agoraAppId,
          areaCode: AreaCode.areaCodeGlob.value(),
        ),
      );

      _registerEventHandlers();

      await agoraEngine.enableVideo();
      await agoraEngine.enableAudio();

      isInitialized.value = true;
      logger.i('✅ Agora SDK initialized');
    } catch (e) {
      logger.e('❌ Agora init failed: $e');
    }
  }

  void _registerEventHandlers() {
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          logger.i('✅ onJoinChannelSuccess – uid=${connection.localUid}');
          isJoined.value = true;
          final c = _joinCompleter;
          if (c != null && !c.isCompleted) c.complete();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          logger.i('👥 Remote user joined: $remoteUid');
          remoteUids.add(remoteUid);
        },
        onUserOffline: (
            RtcConnection connection,
            int remoteUid,
            UserOfflineReasonType reason,
            ) {
          logger.i('👥 Remote user left: $remoteUid');
          remoteUids.removeWhere((uid) => uid == remoteUid);
        },
        onError: (ErrorCodeType err, String msg) {
          logger.e('❌ Agora error $err: $msg');
          final c = _joinCompleter;
          if (c != null && !c.isCompleted) {
            c.completeError(Exception('Agora error: $msg ($err)'));
          }
        },
        onConnectionStateChanged: (
            RtcConnection connection,
            ConnectionStateType state,
            ConnectionChangedReasonType reason,
            ) {
          logger.i('🔄 Connection state: $state ($reason)');

          // Only treat a disconnection as a join failure when we are actively
          // waiting for the join to succeed (completer exists and not done).
          if (state == ConnectionStateType.connectionStateDisconnected) {
            final c = _joinCompleter;
            if (c != null && !c.isCompleted && !isJoined.value) {
              c.completeError(
                Exception('Connection failed before join: $reason'),
              );
            }
          }
        },
      ),
    );
  }

  /// Join as broadcaster (host).
  Future<void> joinChannelAsBroadcaster({
    required String channelName,
    required int uid,
  }) async {
    _joinCompleter = Completer<void>();

    try {
      await agoraEngine.setChannelProfile(
        ChannelProfileType.channelProfileLiveBroadcasting,
      );
      await agoraEngine.setClientRole(
        role: ClientRoleType.clientRoleBroadcaster,
      );
      await agoraEngine.joinChannel(
        token: agoraToken,
        channelId: channelName,
        uid: uid,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      );

      await _joinCompleter!.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException(
          'Timed out waiting for onJoinChannelSuccess',
        ),
      );

      logger.i('✅ Joined as broadcaster: $channelName');
    } catch (e) {
      isJoined.value = false;
      rethrow;
    } finally {
      _joinCompleter = null;
    }
  }

  /// Join as audience (viewer).
  Future<void> joinChannelAsAudience({
    required String channelName,
    required int uid,
  }) async {
    _joinCompleter = Completer<void>();
    try {
      await agoraEngine.setChannelProfile(
        ChannelProfileType.channelProfileLiveBroadcasting,
      );
      await agoraEngine.setClientRole(
        role: ClientRoleType.clientRoleAudience,
      );
      await agoraEngine.joinChannel(
        token: agoraToken,
        channelId: channelName,
        uid: uid,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
          clientRoleType: ClientRoleType.clientRoleAudience,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      );

      await _joinCompleter!.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException(
          'Timed out waiting for onJoinChannelSuccess',
        ),
      );

      logger.i('✅ Joined as audience: $channelName');
    } catch (e) {
      isJoined.value = false;
      rethrow;
    } finally {
      _joinCompleter = null;
    }
  }

  /// Leave the current channel and reset state.
  Future<void> leaveChannel() async {
    try {
      await agoraEngine.leaveChannel();
      isJoined.value = false;
      remoteUids.clear();
      logger.i('Left channel');
    } catch (e) {
      logger.e('Error leaving channel: $e');
    }
  }

  Future<void> toggleMic() async {
    try {
      isMicEnabled.value = !isMicEnabled.value;
      await agoraEngine.enableLocalAudio(isMicEnabled.value);
    } catch (e) {
      logger.e('toggleMic error: $e');
    }
  }

  Future<void> toggleCamera() async {
    try {
      isCameraEnabled.value = !isCameraEnabled.value;
      await agoraEngine.enableLocalVideo(isCameraEnabled.value);
    } catch (e) {
      logger.e('toggleCamera error: $e');
    }
  }

  Widget getLocalVideoWidget() {
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: agoraEngine,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  Widget getRemoteVideoWidget(int uid) {
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: agoraEngine,
        canvas: VideoCanvas(uid: uid),
      ),
    );
  }

  @override
  void onClose() {
    leaveChannel();
    agoraEngine.release();
    super.onClose();
  }
}