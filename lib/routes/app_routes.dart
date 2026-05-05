import 'package:get/get.dart';
import 'package:riding_app/features/home_screen/presentation/screen/courier_service.dart';
import 'package:riding_app/features/home_screen/presentation/screen/home_screen.dart';
import 'package:riding_app/features/live_stream/presentation/screen/live_stream_mode_screen.dart';
import 'package:riding_app/features/live_stream/presentation/screen/live_stream_host_screen.dart';
import 'package:riding_app/features/live_stream/presentation/screen/live_stream_audience_screen.dart';

import '../features/home_screen/presentation/screen/route_selection.dart';

class AppRoute {
  static String home = "/home";
  static String courier = "/courier";
  static String route_selection ="/route_selection";
  static String live_stream_mode = "/live_stream_mode";
  static String live_stream_host = "/live_stream_host";
  static String live_stream_audience = "/live_stream_audience";

  static List<GetPage> routes = [
    GetPage(name: home, page: () => HomeScreen()),
    GetPage(name: courier, page: () => CourierServicesScreen()),
    GetPage(name: route_selection, page: () => SelectRouteScreen()),
    GetPage(name: live_stream_mode, page: () => LiveStreamModeScreen()),
    GetPage(name: live_stream_host, page: () => LiveStreamHostScreen()),
    GetPage(name: live_stream_audience, page: () => LiveStreamAudienceScreen()),

  ];
}
