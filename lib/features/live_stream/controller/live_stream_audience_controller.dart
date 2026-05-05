import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riding_app/features/live_stream/controller/agora_controller.dart';
import 'package:riding_app/features/live_stream/controller/live_stream_controller.dart';
import 'package:riding_app/features/live_stream/presentation/screen/live_stream_audience_screen.dart';

class LiveStreamAudienceController extends GetxController {
  final channelController = TextEditingController();
  final Rx<bool> isJoining = false.obs;

  final agoraController = Get.find<AgoraController>();
  final liveStreamController = Get.find<LiveStreamController>();

  @override
  void dispose() {
    channelController.dispose();
    super.dispose();
  }

  /// Request camera permission for audience (optional, for future video chat)
  Future<bool> _requestStreamPermissions() async {
    final cameraStatus = await Permission.camera.request();

    if (cameraStatus.isDenied) {
      // Audience doesn't strictly need camera, so we allow the join to proceed
      return true;
    }

    if (cameraStatus.isPermanentlyDenied) {
      Get.snackbar(
        'Camera Permission Denied',
        'You can enable it later in app settings if needed',
        duration: const Duration(seconds: 3),
      );
    }

    return true;
  }

  /// Join live stream as audience
  Future<void> joinStream() async {
    if (channelController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a channel name');
      return;
    }

    isJoining.value = true;

    try {
      // Request permissions before joining
      await _requestStreamPermissions();

      // Set channel name
      liveStreamController.setChannelName(channelController.text);

      // Join channel as audience
      await agoraController.joinChannelAsAudience(
        channelName: channelController.text,
        uid: 0, // 0 means Agora assigns UID automatically
      );

      // Navigate to watching screen
      Get.off(() => const LiveStreamWatchingScreen());
    } catch (e) {
      String errorMessage = 'Failed to join stream';
      
      // Provide more specific error messages
      if (e.toString().contains('timeout')) {
        errorMessage = 'Connection timeout - Check your internet connection';
      } else if (e.toString().contains('token')) {
        errorMessage = 'Invalid authentication token - Contact support';
      } else if (e.toString().contains('channel')) {
        errorMessage = 'Channel not found - Check the channel name and try again';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error - Check your internet connection';
      }
      
      Get.snackbar(
        '❌ Join Failed',
        errorMessage,
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.red[900],
        colorText: Colors.white,
      );
    } finally {
      isJoining.value = false;
    }
  }

  /// Update channel name
  void updateChannelName(String name) {
    channelController.text = name;
  }
}
