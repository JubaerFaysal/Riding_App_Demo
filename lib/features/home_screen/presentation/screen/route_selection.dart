import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riding_app/core/common/widgets/custom_search_field.dart';

import '../../controller/route_selection_controller.dart';

class SelectRouteScreen extends StatelessWidget {
  const SelectRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SelectRouteController>();

    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      body: Column(
        children: [
           _MapPeek(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 16),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Get.back(),
                              child: const Icon(Icons.chevron_left,
                                  size: 32, color: Colors.black),
                            ),
                            const Expanded(
                              child: Text(
                                'Select your route',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 32),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Remove Obx from here - CustomSearchField doesn't need it
                        CustomSearchField(
                          controller: controller.pickupController,
                          focusNode: controller.pickupFocus,
                          hintText: 'Pickup location?',
                          onClear: controller.clearPickup,
                        ),
                        const SizedBox(height: 12),
                        CustomSearchField(
                          controller: controller.dropController,
                          focusNode: controller.dropFocus,
                          hintText: 'Drop-off location?',
                          onClear: controller.clearDrop,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  // Only wrap the list that actually uses observables
                  Expanded(
                    child: Obx(() {
                      // These directly use observable values
                      final pickupList = controller.searchPickup();
                      final dropList = controller.searchDrop();

                      // Determine which list to show based on active field
                      final isPickupActive = controller.pickupFocus.hasFocus;
                      final isDropActive = controller.dropFocus.hasFocus;

                      // Show suggestions based on which field is active
                      if (isPickupActive) {
                        return _buildSuggestionList(
                          title: controller.pickupQuery.value.isNotEmpty
                              ? "Pickup suggestions"
                              : "All locations",
                          list: pickupList,
                          query: controller.pickupQuery.value,
                          onTap: controller.selectPickup,
                        );
                      } else if (isDropActive) {
                        return _buildSuggestionList(
                          title: controller.dropQuery.value.isNotEmpty
                              ? "Drop-off suggestions"
                              : "All locations",
                          list: dropList,
                          query: controller.dropQuery.value,
                          onTap: controller.selectDrop,
                        );
                      } else {
                        return _buildSuggestionList(
                          title: "All locations",
                          list: controller.allSuggestions,
                          query: '',
                          onTap: (loc) {
                            Get.snackbar(
                              'Info',
                              'Tap on a search field first',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        );
                      }
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionList({
    required String title,
    required List<LocationResult> list,
    required String query,
    required Function(LocationResult) onTap,
  }) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...list.map((loc) => _LocationTile(
          location: loc,
          query: query,
          onTap: () => onTap(loc),
        )),
      ],
    );
  }
}

class _MapPeek extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Replace with a real map widget (e.g. google_maps_flutter) later.
    return Container(
      height: 160,
      width: double.infinity,
      color: const Color(0xFFE8E8E8),
      child: CustomPaint(painter: _FakeMapPainter()),
    );
  }
}

class _FakeMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Fake road lines
    final paths = [
      [Offset(-20, 60), Offset(size.width * 0.4, 40), Offset(size.width + 20, 80)],
      [Offset(-20, 110), Offset(size.width * 0.6, 90), Offset(size.width + 20, 130)],
      [Offset(size.width * 0.3, -10), Offset(size.width * 0.35, size.height + 10)],
      [Offset(size.width * 0.7, -10), Offset(size.width * 0.65, size.height + 10)],
    ];

    for (final pts in paths) {
      final path = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (int i = 1; i < pts.length; i++) {
        path.lineTo(pts[i].dx, pts[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Location Tile ─────────────────────────────────────────────────────────────

class _LocationTile extends StatelessWidget {
  final LocationResult location;
  final String query;
  final VoidCallback onTap;

  const _LocationTile({
    required this.location,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFDEEAF5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.location_on_outlined,
                color: Color(0xFF4A7FC1),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HighlightedText(
                    text: location.name,
                    query: query,
                    baseStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    highlightStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF5A623),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    location.address,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ── Highlighted Text ──────────────────────────────────────────────────────────

class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle baseStyle;
  final TextStyle highlightStyle;

  const _HighlightedText({
    required this.text,
    required this.query,
    required this.baseStyle,
    required this.highlightStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: baseStyle);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final matchIndex = lowerText.indexOf(lowerQuery);

    if (matchIndex == -1) {
      return Text(text, style: baseStyle);
    }

    return RichText(
      text: TextSpan(
        children: [
          if (matchIndex > 0)
            TextSpan(
              text: text.substring(0, matchIndex),
              style: baseStyle,
            ),
          TextSpan(
            text: text.substring(matchIndex, matchIndex + query.length),
            style: highlightStyle,
          ),
          if (matchIndex + query.length < text.length)
            TextSpan(
              text: text.substring(matchIndex + query.length),
              style: baseStyle,
            ),
        ],
      ),
    );
  }
}