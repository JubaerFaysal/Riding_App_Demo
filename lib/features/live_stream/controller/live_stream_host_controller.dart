import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riding_app/features/live_stream/controller/agora_controller.dart';
import 'package:riding_app/features/live_stream/controller/live_stream_controller.dart';
import 'package:riding_app/features/live_stream/presentation/screen/live_stream_host_screen.dart';

class LiveStreamHostController extends GetxController {
  final logger = Logger();
  final channelController = TextEditingController();
  final Rx<bool> isJoining = false.obs;

  final agoraController = Get.find<AgoraController>();
  final liveStreamController = Get.find<LiveStreamController>();

  @override
  void onInit() {
    super.onInit();
    channelController.text = 'riding_live';
  }

  @override
  void dispose() {
    channelController.dispose();
    super.dispose();
  }

  /// Request camera and microphone permissions
  Future<bool> _requestStreamPermissions() async {
    logger.i('🔐 PERMISSIONS: Requesting camera and microphone...');

    final cameraStatus = await Permission.camera.request();
    logger.i('   📷 Camera permission: $cameraStatus');

    final microphoneStatus = await Permission.microphone.request();
    logger.i('   🎤 Microphone permission: $microphoneStatus');

    if (cameraStatus.isDenied || microphoneStatus.isDenied) {
      logger.w('   ⚠️ Permissions DENIED by user');
      Get.snackbar(
        'Permissions Required',
        'Camera and microphone permissions are required to broadcast',
        duration: const Duration(seconds: 3),
      );
      return false;
    }

    if (cameraStatus.isPermanentlyDenied ||
        microphoneStatus.isPermanentlyDenied) {
      logger.w('   ⚠️ Permissions PERMANENTLY DENIED');
      Get.snackbar(
        'Permissions Denied',
        'Please enable camera and microphone permissions in app settings',
        mainButton: TextButton(
          onPressed: openAppSettings,
          child: const Text('Settings'),
        ),
        duration: const Duration(seconds: 5),
      );
      return false;
    }

    logger.i('   ✅ All permissions GRANTED');
    return true;
  }

  /// Start broadcasting
  Future<void> startBroadcast() async {
    logger.i('═══════════════════════════════════════════════════════════');
    logger.i('🎬 START BROADCAST: Initializing broadcast flow');

    if (channelController.text.isEmpty) {
      logger.w('   ❌ Channel name is empty');
      Get.snackbar('Error', 'Please enter a channel name');
      return;
    }

    logger.i('   📺 Channel: ${channelController.text}');
    isJoining.value = true;

    try {
      // Step 1: Request permissions
      logger.i('📍 Step 1: Requesting permissions...');
      final permissionsGranted = await _requestStreamPermissions();
      if (!permissionsGranted) {
        logger.e('   ❌ Permissions not granted, aborting');
        isJoining.value = false;
        return;
      }
      logger.i('   ✅ Permissions granted');

      // Step 2: Set channel name
      logger.i('📍 Step 2: Setting channel name in LiveStreamController...');
      liveStreamController.setChannelName(channelController.text);
      logger.i('   ✅ Channel name saved');

      // Step 3: Join Agora channel
      logger.i(
        '📍 Step 3: Calling agoraController.joinChannelAsBroadcaster()...',
      );
      await agoraController.joinChannelAsBroadcaster(
        channelName: channelController.text,
        uid: 0,
      );
      logger.i('   ✅ joinChannelAsBroadcaster() returned successfully');

      // Step 4: Navigate to broadcast screen
      logger.i('📍 Step 4: Navigating to active broadcast screen...');
      Get.off(() => const LiveStreamActiveBroadcastScreen());
      logger.i('✅ BROADCAST STARTED - Navigation complete');
      logger.i('═══════════════════════════════════════════════════════════');
    } catch (e) {
      logger.e('❌ BROADCAST FAILED');
      logger.e('   🔴 Exception Type: ${e.runtimeType}');
      logger.e('   🔴 Exception: $e');
      logger.e('═══════════════════════════════════════════════════════════');

      String errorMessage = 'Failed to start broadcast';

      final errorStr = e.toString().toLowerCase();
      
      if (errorStr.contains('timeout')) {
        errorMessage = 'Connection timeout - Check your internet connection';
      } else if (errorStr.contains('token')) {
        errorMessage = 'Invalid authentication token - Contact support';
      } else if (errorStr.contains('permission')) {
        errorMessage = 'Permission denied - Check app permissions';
      } else if (errorStr.contains('network')) {
        errorMessage = 'Network error - Check your internet connection';
      } else if (errorStr.contains('connection failed')) {
        errorMessage = 'Failed to connect to Agora servers - Check your internet';
      } else if (errorStr.contains('app id')) {
        errorMessage = 'Invalid App ID - Please contact support';
      }

      Get.snackbar(
        '❌ Broadcast Failed',
        errorMessage,
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.red[900],
        colorText: Colors.white,
      );
    } finally {
      isJoining.value = false;
      logger.i('📊 Broadcast flow completed - isJoining set to false');
    }
  }

  /// Update channel name
  void updateChannelName(String name) {
    channelController.text = name;
  }
}
