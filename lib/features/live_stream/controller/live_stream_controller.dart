import 'package:get/get.dart';

enum LiveStreamMode { host, audience }

class LiveStreamController extends GetxController {
  Rx<LiveStreamMode?> mode = Rx<LiveStreamMode?>(null);
  RxString channelName = ''.obs;
  RxInt userId = 0.obs;

  /// Set livestream mode (Host or Audience)
  void setMode(LiveStreamMode selectedMode) {
    mode.value = selectedMode;
  }

  /// Set channel name
  void setChannelName(String name) {
    channelName.value = name;
  }

  /// Set user ID
  void setUserId(int id) {
    userId.value = id;
  }

  /// Reset mode and channel
  void reset() {
    mode.value = null;
    channelName.value = '';
    userId.value = 0;
  }

  /// Check if mode is host
  bool get isHost => mode.value == LiveStreamMode.host;

  /// Check if mode is audience
  bool get isAudience => mode.value == LiveStreamMode.audience;
}
