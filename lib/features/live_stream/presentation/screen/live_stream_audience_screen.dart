import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riding_app/features/live_stream/controller/agora_controller.dart';
import 'package:riding_app/features/live_stream/controller/live_stream_controller.dart';
import 'package:riding_app/features/live_stream/controller/live_stream_audience_controller.dart';

class LiveStreamAudienceScreen extends StatelessWidget {
  const LiveStreamAudienceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LiveStreamAudienceController>(
      init: LiveStreamAudienceController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Watch Live'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 80,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Enter Channel Name',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller.channelController,
                    decoration: InputDecoration(
                      hintText: 'Enter the channel you want to watch',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.tag),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Info Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Ask the broadcaster for the channel name to join their live stream.',
                            style: TextStyle(
                              color: Colors.blue[900],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Join Button
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: controller.isJoining.value ? null : controller.joinStream,
                        icon: controller.isJoining.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.play_arrow),
                        label: Text(controller.isJoining.value ? 'Joining...' : 'Join Stream'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
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
                  // Cancel Button
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: controller.isJoining.value ? null : () => Get.back(),
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
}

// Watching Screen
class LiveStreamWatchingScreen extends StatelessWidget {
  const LiveStreamWatchingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final agoraController = Get.find<AgoraController>();
    final liveStreamController = Get.find<LiveStreamController>();

    return WillPopScope(
      onWillPop: () async {
        // Ask for confirmation before leaving
        final confirm = await Get.defaultDialog(
          title: 'Leave Stream',
          content: const Text('Are you sure you want to stop watching?'),
          textConfirm: 'Yes, Leave',
          textCancel: 'No, Continue',
          confirmTextColor: Colors.white,
          onConfirm: () {
            Get.back(); // Close dialog
            Get.back(); // Go back
          },
        );
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Remote Video Stream
            Obx(
              () {
                if (agoraController.remoteUids.isEmpty) {
                  return Container(
                    color: Colors.black,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.videocam_off,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Waiting for broadcaster...',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Show first broadcaster's video
                return agoraController.getRemoteVideoWidget(
                  agoraController.remoteUids[0],
                );
              },
            ),
            // Top Bar
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(
                              () => agoraController.remoteUids.isNotEmpty
                                  ? const Row(
                                      children: [
                                        Icon(
                                          Icons.fiber_manual_record,
                                          color: Colors.red,
                                          size: 8,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'LIVE',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Text(
                                      'Connecting...',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                        ),
                      ),
                      Obx(
                        () => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.people,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${agoraController.remoteUids.length + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom Controls
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
                      // Share Button
                      _buildControlButton(
                        icon: Icons.share,
                        label: 'Share',
                        onPressed: () {
                          Get.snackbar(
                            'Share',
                            'Channel: ${liveStreamController.channelName.value}',
                          );
                        },
                      ),
                      // Leave Button
                      _buildControlButton(
                        icon: Icons.call_end,
                        label: 'Leave',
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
