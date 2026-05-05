import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riding_app/core/common/widgets/custom_search_field.dart';

import '../../../../core/localization/app_texts.dart';
import '../../../../core/localization/reusable_language_tile.dart';
import '../../controller/home_controller.dart';
import '../widgets/activity_item.dart';
import '../widgets/nav_items.dart';
import '../widgets/service_card.dart';
import 'courier_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppText.helloGreeting.tr,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppText.whereHeadedToday.tr,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        IconButton(onPressed: controller.onChangeLanguage, icon: Icon(Icons.language_outlined))
                        // Stack(
                        //   children: [
                        //     IconButton(
                        //       onPressed: controller.onNotificationButtonTapped,
                        //       icon: const Icon(
                        //         Icons.notifications_none,
                        //         size: 28,
                        //         color: Colors.black,
                        //       ),
                        //     ),
                        //     Positioned(
                        //       right: 8,
                        //       top: 8,
                        //       child: Container(
                        //         width: 18,
                        //         height: 18,
                        //         decoration: const BoxDecoration(
                        //           color: Colors.red,
                        //           shape: BoxShape.circle,
                        //         ),
                        //         alignment: Alignment.center,
                        //         child: const Text(
                        //           '3',
                        //           style: TextStyle(
                        //             color: Colors.white,
                        //             fontSize: 10,
                        //             fontWeight: FontWeight.bold,
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    CustomSearchField(
                      borderRadius: 16,
                      hintText: AppText.searchHint.tr,
                      controller: controller.searchController,
                      focusNode: controller.searchFocus,
                    ),

                    const SizedBox(height: 24),

                    Text(
                      AppText.announcement.tr,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Obx(() {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Image.asset(
                              controller.banners[controller.currentIndex.value],
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),

                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 60,
                              child: Text(
                                AppText.bannerText.tr,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child:  IconButton(
                                  onPressed: controller.onBannerPressed,
                                 icon: Icon(Icons.arrow_forward_ios,size: 16, color: Colors.black,) ,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 10),

                    Obx(() {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(controller.banners.length, (i) {
                          final active = i == controller.currentIndex.value;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: active ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: active
                                  ? const Color(0xFFF5A623)
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      );
                    }),

                    const SizedBox(height: 24),

                    Text(
                      AppText.services.tr,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children:  [
                          ServiceCard(
                            label: AppText.hireDriver.tr,
                            imagePath: 'assets/images/img_1.png',
                          ),
                          SizedBox(width: 12),
                          ServiceCard(
                            label: AppText.rentCar.tr,
                            imagePath: 'assets/images/img_2.png',
                          ),
                          SizedBox(width: 12),
                          ServiceCard(
                            label: AppText.bookFreight.tr,
                            imagePath: 'assets/images/img_3.png',
                          ),
                          SizedBox(width: 12),
                          ServiceCard(
                            label: AppText.hireArtisan.tr,
                            imagePath: 'assets/images/img_6.png',
                          ),
                          SizedBox(width: 12),
                          ServiceCard(
                            label: AppText.courierServices.tr,
                            onTap: () => Get.to(() => CourierServicesScreen()),
                            imagePath: 'assets/images/img_5.png',
                          ),
                          SizedBox(width: 12),
                          ServiceCard(
                            label: 'Live Stream',
                            onTap: () => Get.toNamed('/live_stream_mode'),
                            imagePath: 'assets/images/img_1.png',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      AppText.recentActivity.tr,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ActivityItem(
                      icon: 'assets/icons/img.png',
                      title: AppText.rideArriving.tr,
                      subtitle: 'John Doe | Toyota Corolla | KTU123AZ',
                      actionLabel: AppText.track.tr,
                      onAction: () {},
                    ),
                    const Divider(height: 1),
                    ActivityItem(
                      icon: 'assets/icons/img_1.png',
                      title: AppText.carRentalEnds.tr,
                      subtitle: 'BMW X5 | Rental ends: 2:00pm',
                      actionLabel: AppText.extend.tr,
                      onAction: () {},
                    ),
                    const Divider(height: 1),
                    ActivityItem(
                      icon: 'assets/icons/img.png',
                      title: AppText.rideArriving.tr,
                      subtitle: 'John Doe | Toyota Corolla | KTU123AZ',
                      actionLabel: AppText.track.tr,
                      onAction: () {},
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  NavItem(
                    icon: Icons.home_filled,
                    label: 'Home',
                    active: true,
                  ),
                  NavItem(icon: Icons.grid_view_rounded, label: 'Services'),
                  NavItem(icon: Icons.access_time_rounded, label: 'Orders'),
                  NavItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Profile',
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





