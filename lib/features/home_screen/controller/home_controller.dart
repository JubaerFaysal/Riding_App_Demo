import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common/widgets/app_snackber.dart';
import '../../../core/localization/language_controller.dart';

class HomeController extends GetxController {

  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocus = FocusNode();

  final List<String> banners = [
    'assets/images/img.png',
    'assets/images/img.png',
    'assets/images/img.png',
    'assets/images/img.png',
  ];

  final RxInt currentIndex = 0.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _startAutoSlide();
  }

  void onChangeLanguage(){
    final languageController = Get.find<LanguageController>();
    final currentLang = languageController.selectedLanguage.value;
    final newLang = currentLang == 'en' ? 'bn' : 'en';
    languageController.saveLanguage(newLang);
  }

  void onNotificationButtonTapped() {
    AppSnackBar.info('functionality coming soon');
  }

  void onBannerPressed() {
    AppSnackBar.info('functionality coming soon');
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (currentIndex.value < banners.length - 1) {
        currentIndex.value++;
      } else {
        currentIndex.value = 0;
      }
    });
  }


  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}