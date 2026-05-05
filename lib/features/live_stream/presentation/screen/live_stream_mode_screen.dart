import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riding_app/features/live_stream/controller/live_stream_controller.dart';

class LiveStreamModeScreen extends StatelessWidget {
  const LiveStreamModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LiveStreamController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Stream'),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Choose Your Role',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 60),
            // Go Live Button (Host)
            _buildModeButton(
              context,
              title: 'Go Live',
              subtitle: 'Stream to your audience',
              icon: Icons.videocam,
              color: Colors.red,
              onTap: () {
                controller.setMode(LiveStreamMode.host);
                Get.toNamed('/live_stream_host');
              },
            ),
            const SizedBox(height: 30),
            // Watch Live Button (Audience)
            _buildModeButton(
              context,
              title: 'Watch Live',
              subtitle: 'Watch other streams',
              icon: Icons.play_circle_outline,
              color: Colors.blue,
              onTap: () {
                controller.setMode(LiveStreamMode.audience);
                Get.toNamed('/live_stream_audience');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
          color: color.withOpacity(0.05),
        ),
        child: Column(
          children: [
            Icon(icon, size: 56, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
