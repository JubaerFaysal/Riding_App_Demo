import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocationResult {
  final String name;
  final String address;

  const LocationResult({
    required this.name,
    required this.address,
  });
}
enum SearchField { pickup, drop }

class SelectRouteController extends GetxController {

  final FocusNode pickupFocus = FocusNode();
  final FocusNode dropFocus = FocusNode();

  final TextEditingController pickupController = TextEditingController();
  final TextEditingController dropController = TextEditingController();

  final RxString pickupQuery = ''.obs;
  final RxString dropQuery = ''.obs;

  final Rx<LocationResult?> selectedPickup = Rx<LocationResult?>(null);
  final Rx<LocationResult?> selectedDrop = Rx<LocationResult?>(null);

  final List<LocationResult> allSuggestions = const [
    LocationResult(name: 'Ikeja City Mall', address: 'Ikeja, Lagos'),
    LocationResult(name: 'Muri Okunola Park', address: 'Victoria island, Lagos'),
    LocationResult(name: 'Filmhouse IMAX Cinema', address: 'Lekki, Lagos'),
    LocationResult(name: 'Filmhouse IMAX Cinema', address: 'Lekki, Lagos'),
    LocationResult(name: 'Filmhouse IMAX Cinema', address: 'Lekki, Lagos'),
    LocationResult(name: 'Filmhouse IMAX Cinema', address: 'Lekki, Lagos'),
    LocationResult(name: 'Filmhouse IMAX Cinema', address: 'Lekki, Lagos'),
    LocationResult(name: 'Adeshina Street, Somewhere Ville', address: 'Ikeja, Lagos'),
    LocationResult(name: 'Adeola Court Estate, Somewhere', address: 'Victoria island, Lagos'),
    LocationResult(name: 'Addide Store, Somewhere', address: 'Lekki, Lagos'),
  ];

  List<LocationResult> searchPickup() {
    if (pickupQuery.value.isEmpty) {
      return allSuggestions.toList();
    }

    final q = pickupQuery.value.toLowerCase();

    return allSuggestions.where((l) {
      return l.name.toLowerCase().contains(q) ||
          l.address.toLowerCase().contains(q);
    }).toList();
  }

  List<LocationResult> searchDrop() {
    if (dropQuery.value.isEmpty) {
      return allSuggestions.toList();
    }

    final q = dropQuery.value.toLowerCase();

    return allSuggestions.where((l) {
      return l.name.toLowerCase().contains(q) ||
          l.address.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();

    pickupController.addListener(() {
      pickupQuery.value = pickupController.text;
    });

    dropController.addListener(() {
      dropQuery.value = dropController.text;
    });
  }

  void selectPickup(LocationResult loc) {
    selectedPickup.value = loc;
    pickupController.text = loc.name;
    pickupQuery.value = loc.name;
  }

  void selectDrop(LocationResult loc) {
    selectedDrop.value = loc;
    dropController.text = loc.name;
    dropQuery.value = loc.name;
  }

  void clearPickup() {
    pickupController.clear();
    pickupQuery.value = '';
  }

  void clearDrop() {
    dropController.clear();
    dropQuery.value = '';
  }


  void goToNextPage() {
    if (selectedPickup.value != null && selectedDrop.value != null) {
      // Get.toNamed(
      //   '/confirm-route',
      //   arguments: {
      //     'pickup': selectedPickup.value,
      //     'drop': selectedDrop.value,
      //   },
      // );
    } else {
      Get.snackbar('Error', 'Please select both pickup and drop locations');
    }
  }

  @override
  void onClose() {
    pickupController.dispose();
    dropController.dispose();
    super.onClose();
  }
}