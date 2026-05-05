
import 'package:get/get.dart';
import 'package:riding_app/core/localization/language_controller.dart';
import 'package:riding_app/features/home_screen/controller/courier_controller.dart';
import 'package:riding_app/features/home_screen/controller/home_controller.dart';
import 'package:riding_app/features/home_screen/controller/route_selection_controller.dart';
import 'package:riding_app/features/live_stream/controller/agora_controller.dart';
import 'package:riding_app/features/live_stream/controller/live_stream_controller.dart';
import 'package:riding_app/features/live_stream/controller/live_stream_host_controller.dart';
import 'package:riding_app/features/live_stream/controller/live_stream_audience_controller.dart';


class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LanguageController>(() => LanguageController(),
      fenix: true,
    );
    Get.lazyPut<HomeController>(() => HomeController(),
      fenix: true,
    );
    Get.lazyPut<CourierController>(() => CourierController(),
      fenix: true,
    );
    Get.lazyPut<SelectRouteController>(() => SelectRouteController(),
      fenix: true,
    );

    Get.put(AgoraController(), permanent: true);

    Get.put(LiveStreamController(), permanent: true);

    Get.lazyPut<LiveStreamHostController>(() => LiveStreamHostController(),
      fenix: true,
    );
    Get.lazyPut<LiveStreamAudienceController>(() => LiveStreamAudienceController(),
      fenix: true,
    );
  }
}