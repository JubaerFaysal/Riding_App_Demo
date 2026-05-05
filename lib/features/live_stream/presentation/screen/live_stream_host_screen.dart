import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riding_app/features/live_stream/controller/agora_controller.dart';
import 'package:riding_app/features/live_stream/controller/live_stream_controller.dart';
import 'package:riding_app/features/live_stream/controller/live_stream_host_controller.dart';

class LiveStreamHostScreen extends StatelessWidget {
  const LiveStreamHostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LiveStreamHostController>(
      init: LiveStreamHostController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: const Text('Go Live'), centerTitle: true),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Channel Name',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller.channelController,
                    decoration: InputDecoration(
                      hintText: 'Enter channel name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.tag),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Before You Go Live',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSettingItem(
                          icon: Icons.videocam,
                          label: 'Camera',
                          value: 'Enabled',
                          color: Colors.green,
                        ),
                        const SizedBox(height: 12),
                        _buildSettingItem(
                          icon: Icons.mic,
                          label: 'Microphone',
                          value: 'Enabled',
                          color: Colors.green,
                        ),
                        const SizedBox(height: 12),
                        _buildSettingItem(
                          icon: Icons.broadcast_on_home,
                          label: 'Broadcast Mode',
                          value: 'Live Broadcasting',
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                  Obx(
                        () => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: controller.isJoining.value
                            ? null
                            : controller.startBroadcast,
                        icon: controller.isJoining.value
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                            : const Icon(Icons.videocam),
                        label: Text(
                          controller.isJoining.value ? 'Connecting...' : 'Go Live',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                        () => SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: controller.isJoining.value
                            ? null
                            : () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildSettingItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'ON',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Active Broadcast Screen
// ─────────────────────────────────────────────────────────────────────────────

class LiveStreamActiveBroadcastScreen extends StatelessWidget {
  const LiveStreamActiveBroadcastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final liveStreamController = Get.find<LiveStreamController>();
    final agoraController = Get.find<AgoraController>();

    return WillPopScope(
      onWillPop: () async {
        await Get.defaultDialog(
          title: 'End Stream',
          content: const Text('Are you sure you want to stop broadcasting?'),
          textConfirm: 'Yes, End',
          textCancel: 'No, Continue',
          confirmTextColor: Colors.white,
          onConfirm: () async {
            Get.back(); // close dialog
            await agoraController.leaveChannel();
            liveStreamController.reset();
            Get.offNamed('/live_stream_mode');
          },
        );
        return false; // never pop automatically; we handle it above
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Local video feed
            Obx(() {
              if (!agoraController.isJoined.value) {
                return Container(
                  color: Colors.black,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Connecting to stream...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return agoraController.getLocalVideoWidget();
            }),

            // Top bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black45,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Obx(() => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              liveStreamController.channelName.value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        )),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.fiber_manual_record,
                              color: Colors.white,
                              size: 8,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'REC',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black45,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Obx(() => _buildControlButton(
                        icon: agoraController.isMicEnabled.value
                            ? Icons.mic
                            : Icons.mic_off,
                        label: agoraController.isMicEnabled.value ? 'Mic' : 'Mic Off',
                        onPressed: agoraController.toggleMic,
                        backgroundColor: agoraController.isMicEnabled.value
                            ? Colors.grey[700]
                            : Colors.red,
                      )),
                      Obx(() => _buildControlButton(
                        icon: agoraController.isCameraEnabled.value
                            ? Icons.videocam
                            : Icons.videocam_off,
                        label: agoraController.isCameraEnabled.value
                            ? 'Camera'
                            : 'Cam Off',
                        onPressed: agoraController.toggleCamera,
                        backgroundColor: agoraController.isCameraEnabled.value
                            ? Colors.grey[700]
                            : Colors.red,
                      )),
                      _buildControlButton(
                        icon: Icons.call_end,
                        label: 'End',
                        onPressed: () async {
                          await agoraController.leaveChannel();
                          liveStreamController.reset();
                          Get.offNamed('/live_stream_mode');
                        },
                        backgroundColor: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? backgroundColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor ?? Colors.grey[700],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}