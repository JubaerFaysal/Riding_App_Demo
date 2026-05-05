import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riding_app/features/home_screen/presentation/screen/route_selection.dart';
import 'package:riding_app/features/home_screen/presentation/widgets/courier_card.dart';

class CourierServicesScreen extends StatelessWidget {
  const CourierServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: const Icon(Icons.chevron_left, size: 32, color: Colors.black),
              ),

              const SizedBox(height: 20),

              const Text(
                'Send your\npackage with ease',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Send documents, parcels or goods to any\nlocation with trusted couriers',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: ListView(
                  children: [
                    // Send a package card
                    CourierCard(
                      label: 'Send a package',
                      backgroundColor: const Color(0xFFFFF3D6),
                      imagePath: 'assets/images/img_4.png',
                      onTap: () {
                        Get.to(() => SelectRouteScreen());
                        // Get.to(() => const SendPackageScreen());
                      },
                    ),

                    const SizedBox(height: 16),

                    // Receive a package card
                    CourierCard(
                      label: 'Receive a package',
                      backgroundColor: const Color(0xFFE8E8E8),
                      imagePath: 'assets/images/img_7.png',
                      onTap: () {
                        Get.to(() => SelectRouteScreen());                      },
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


