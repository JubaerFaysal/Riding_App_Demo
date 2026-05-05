# Live Stream Feature: Complete Step-by-Step Guide

## Overview Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     USER OPENS APP                              │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
        ┌────────────────────────────────────┐
        │   HomeScreen (with LiveStream      │
        │   service card)                    │
        └────────────┬───────────────────────┘
                     │ User taps "Live Stream"
                     ▼
        ┌────────────────────────────────────┐
        │  LiveStreamModeScreen              │
        │  Choose: Go Live or Watch Live     │
        └─────────┬──────────────┬───────────┘
                  │              │
        ┌─────────▼──┐    ┌──────▼─────────┐
        │   Go Live  │    │  Watch Live    │
        │   (HOST)   │    │  (AUDIENCE)    │
        └─────┬──────┘    └────────┬───────┘
              │                    │
              ▼                    ▼
   HOST FLOW                AUDIENCE FLOW
```

---

## PART 1: HOST FLOW (Go Live / Broadcaster)

### Step 1: User Taps "Live Stream" on Home Screen

**File:** [lib/features/home_screen/presentation/screen/home_screen.dart](lib/features/home_screen/presentation/screen/home_screen.dart)

```dart
ServiceCard(
  label: 'Live Stream',
  onTap: () => Get.toNamed('/live_stream_mode'),  // ← Navigate to mode selection
  imagePath: 'assets/images/img_1.png',
),
```

**Role:** Provides entry point to livestream feature

---

### Step 2: Mode Selection Screen Appears

**File:** [lib/features/live_stream/presentation/screen/live_stream_mode_screen.dart](lib/features/live_stream/presentation/screen/live_stream_mode_screen.dart)

```dart
class LiveStreamModeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LiveStreamController>();

    return Column(
      children: [
        _buildModeButton(
          title: 'Go Live',
          subtitle: 'Stream to your audience',
          icon: Icons.videocam,
          color: Colors.red,
          onTap: () {
            controller.setMode(LiveStreamMode.host);  // ← Set as HOST
            Get.toNamed('/live_stream_host');         // ← Go to setup screen
          },
        ),
        // ... Watch Live button
      ],
    );
  }
}
```

**Role:** Allows user to choose between HOST (Go Live) or AUDIENCE (Watch Live) role

**What Happens:**
- `controller.setMode(LiveStreamMode.host)` - Sets the user as a broadcaster
- `Get.toNamed('/live_stream_host')` - Navigates to host setup screen

---

### Step 3: Host Setup Screen (Channel Configuration)

**File:** [lib/features/live_stream/presentation/screen/live_stream_host_screen.dart](lib/features/live_stream/presentation/screen/live_stream_host_screen.dart)

```dart
class LiveStreamHostScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LiveStreamHostController>(
      init: LiveStreamHostController(),  // ← Initialize Host Controller
      builder: (controller) {
        return Scaffold(
          body: Column(
            children: [
              TextField(
                controller: controller.channelController,  // ← Input channel name
                decoration: InputDecoration(
                  hintText: 'Enter channel name',
                ),
              ),
              ElevatedButton.icon(
                onPressed: controller.startBroadcast,  // ← Start broadcast
                label: Text('Go Live'),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

**Role:** UI for host to enter channel name and settings

**User Interaction:**
- User enters channel name (e.g., "riding_live")
- User clicks "Go Live" button
- This triggers `controller.startBroadcast()`

---

### Step 4: Controller Handles Broadcast Logic

**File:** [lib/features/live_stream/controller/live_stream_host_controller.dart](lib/features/live_stream/controller/live_stream_host_controller.dart)

```dart
class LiveStreamHostController extends GetxController {
  final channelController = TextEditingController();
  final Rx<bool> isJoining = false.obs;
  
  final agoraController = Get.find<AgoraController>();
  final liveStreamController = Get.find<LiveStreamController>();

  @override
  void onInit() {
    super.onInit();
    channelController.text = 'riding_live';  // ← Default channel name
  }

  /// Start broadcasting
  Future<void> startBroadcast() async {
    if (channelController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a channel name');
      return;
    }

    isJoining.value = true;  // ← Show loading indicator

    try {
      // STEP 4A: Save channel name
      liveStreamController.setChannelName(channelController.text);

      // STEP 4B: Join Agora channel as broadcaster
      await agoraController.joinChannelAsBroadcaster(
        channelName: channelController.text,
        uid: 0,
      );

      // STEP 4C: Navigate to active broadcast screen
      Get.off(() => const LiveStreamActiveBroadcastScreen());
    } catch (e) {
      Get.snackbar('Error', 'Failed to start broadcast: $e');
    } finally {
      isJoining.value = false;  // ← Hide loading indicator
    }
  }
}
```

**Role:** Orchestrates the broadcast startup process

**What Happens Here:**
1. **Step 4A:** Save channel name in `LiveStreamController`
2. **Step 4B:** Call `agoraController.joinChannelAsBroadcaster()`
3. **Step 4C:** Navigate to active broadcast screen

---

### Step 5: Agora SDK Initializes & Joins Channel

**File:** [lib/features/live_stream/controller/agora_controller.dart](lib/features/live_stream/controller/agora_controller.dart)

#### 5A: Agora Initialization (happens in `onInit()`)

```dart
class AgoraController extends GetxController {
  late RtcEngine agoraEngine;
  
  static const String agoraAppId = 'YOUR_AGORA_APP_ID';
  
  @override
  void onInit() {
    super.onInit();
    initializeAgora();  // ← Initialize on controller creation
  }

  Future<void> initializeAgora() async {
    try {
      // STEP 1: Create Agora engine
      agoraEngine = createAgoraRtcEngine();
      
      // STEP 2: Initialize with app ID
      await agoraEngine.initialize(RtcEngineContext(
        appId: agoraAppId,
        areaCode: AreaCode.areaCodeGlob.value(),
      ));

      // STEP 3: Register event handlers
      _registerEventHandlers();

      // STEP 4: Enable video and audio
      await agoraEngine.enableVideo();
      await agoraEngine.enableAudio();

      isInitialized.value = true;
    } catch (e) {
      logger.e('Error initializing Agora: $e');
    }
  }
}
```

**Role:** Initializes Agora SDK once when the app starts

**What Happens:**
1. Creates Agora engine instance
2. Authenticates with Agora using App ID
3. Registers event listeners
4. Enables video and audio capabilities

---

#### 5B: Event Handlers Setup

```dart
void _registerEventHandlers() {
  agoraEngine.registerEventHandler(
    RtcEngineEventHandler(
      // When LOCAL user successfully joins channel
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        logger.i('Local user joined channel: ${connection.channelId}');
        isJoined.value = true;  // ← Broadcast started!
      },
      
      // When REMOTE user joins the channel
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        logger.i('Remote user joined: $remoteUid');
        remoteUids.add(remoteUid);  // ← Add to list of viewers
      },
      
      // When REMOTE user leaves
      onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
        logger.i('Remote user offline: $remoteUid');
        remoteUids.removeWhere((uid) => uid == remoteUid);
      },
      
      // When ERROR occurs
      onError: (ErrorCodeType err, String msg) {
        logger.e('Error: $err, Message: $msg');
      },
    ),
  );
}
```

**Role:** Listens to real-time events from Agora service

**Key Events:**
- `onJoinChannelSuccess` - Triggered when host joins
- `onUserJoined` - Triggered when audience member joins
- `onUserOffline` - Triggered when audience member leaves

---

#### 5C: Join Channel as Broadcaster

```dart
/// Join channel as broadcaster (host)
Future<void> joinChannelAsBroadcaster({
  required String channelName,
  required int uid,
}) async {
  try {
    // STEP 1: Set channel profile to live broadcasting
    await agoraEngine.setChannelProfile(
      ChannelProfileType.channelProfileLiveBroadcasting,
    );

    // STEP 2: Set user role as broadcaster
    await agoraEngine.setClientRole(
      role: ClientRoleType.clientRoleBroadcaster,
    );

    // STEP 3: Join the channel
    await agoraEngine.joinChannel(
      token: agoraToken,
      channelId: channelName,  // ← "riding_live"
      uid: uid,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );

    logger.i('Joined channel as broadcaster: $channelName');
  } catch (e) {
    logger.e('Error joining channel as broadcaster: $e');
    rethrow;
  }
}
```

**Role:** Connects host to Agora's streaming channel

**What Each Part Does:**
1. **`setChannelProfile()`** - Sets mode to "Live Broadcasting" (has broadcaster/audience roles)
2. **`setClientRole()`** - Declares this user is a broadcaster (can send video/audio)
3. **`joinChannel()`** - Actually joins the channel "riding_live" on Agora's servers

**Data Flow:**
```
┌──────────────────────────┐
│ setChannelProfile()      │
│ (Live Broadcasting mode) │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│ setClientRole()          │
│ (Broadcaster role)       │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│ joinChannel()            │
│ (Connect to Agora)       │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│ onJoinChannelSuccess()   │
│ EVENT FIRED!             │
│ isJoined = true          │
└──────────────────────────┘
```

---

### Step 6: Active Broadcast Screen

**File:** [lib/features/live_stream/presentation/screen/live_stream_host_screen.dart](lib/features/live_stream/presentation/screen/live_stream_host_screen.dart) (Line 172+)

```dart
class LiveStreamActiveBroadcastScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final agoraController = Get.find<AgoraController>();
    final liveStreamController = Get.find<LiveStreamController>();

    return Scaffold(
      body: Stack(
        children: [
          // 1. DISPLAY LOCAL VIDEO FEED
          Obx(
            () => agoraController.isJoined.value
                ? agoraController.getLocalVideoWidget()  // ← Shows host's camera
                : const Center(child: CircularProgressIndicator()),
          ),
          
          // 2. TOP BAR (Live Indicator & Channel Name)
          Positioned(
            top: 0,
            child: Container(
              child: Column(
                children: [
                  const Text('LIVE', style: TextStyle(color: Colors.red)),
                  Text(liveStreamController.channelName.value),  // ← "riding_live"
                ],
              ),
            ),
          ),
          
          // 3. BOTTOM CONTROLS
          Positioned(
            bottom: 0,
            child: Row(
              children: [
                // Microphone Toggle
                Obx(
                  () => _buildControlButton(
                    icon: agoraController.isMicEnabled.value
                        ? Icons.mic
                        : Icons.mic_off,
                    onPressed: () => agoraController.toggleMic(),
                  ),
                ),
                
                // Camera Toggle
                Obx(
                  () => _buildControlButton(
                    icon: agoraController.isCameraEnabled.value
                        ? Icons.videocam
                        : Icons.videocam_off,
                    onPressed: () => agoraController.toggleCamera(),
                  ),
                ),
                
                // End Stream Button
                _buildControlButton(
                  icon: Icons.call_end,
                  onPressed: () async {
                    await agoraController.leaveChannel();
                    liveStreamController.reset();
                    Get.offNamed('/live_stream_mode');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

**Role:** Displays live broadcast and provides controls

**What's Visible:**
1. Host's camera feed (video widget from Agora)
2. "LIVE" indicator and channel name
3. Mic toggle button
4. Camera toggle button
5. End stream button

**Reactive Behavior:**
- Uses `Obx()` to listen to `agoraController` state
- When `isJoined` becomes true, shows video
- When `isMicEnabled` changes, icon updates

---

### Step 7: Control Toggles (Mic & Camera)

```dart
/// Toggle microphone
Future<void> toggleMic() async {
  try {
    isMicEnabled.value = !isMicEnabled.value;  // ← Flip state
    await agoraEngine.enableLocalAudio(isMicEnabled.value);  // ← Send to Agora
    logger.i('Mic ${isMicEnabled.value ? 'enabled' : 'disabled'}');
  } catch (e) {
    logger.e('Error toggling mic: $e');
  }
}

/// Toggle camera
Future<void> toggleCamera() async {
  try {
    isCameraEnabled.value = !isCameraEnabled.value;  // ← Flip state
    await agoraEngine.enableLocalVideo(isCameraEnabled.value);  // ← Send to Agora
    logger.i('Camera ${isCameraEnabled.value ? 'enabled' : 'disabled'}');
  } catch (e) {
    logger.e('Error toggling camera: $e');
  }
}
```

**Role:** Allows host to control audio/video during broadcast

**Flow:**
1. User taps mic/camera button
2. State variable is toggled (`isMicEnabled` = !`isMicEnabled`)
3. Agora SDK is told to enable/disable
4. UI automatically updates (through `Obx`)

---

### Step 8: End Broadcast

```dart
/// Leave channel
Future<void> leaveChannel() async {
  try {
    await agoraEngine.leaveChannel();  // ← Tell Agora we're leaving
    isJoined.value = false;             // ← Update state
    remoteUids.clear();                 // ← Clear audience list
    logger.i('Left channel');
  } catch (e) {
    logger.e('Error leaving channel: $e');
  }
}
```

**Role:** Stops broadcast and cleans up

**What Happens:**
1. `leaveChannel()` - Tells Agora server we're done
2. `isJoined = false` - UI updates to show disconnected state
3. `remoteUids.clear()` - Clears any audience members list
4. Navigation back to mode selection screen

---

## PART 2: AUDIENCE FLOW (Watch Live / Viewer)

### Step 1-2: Mode Selection (Same as Host)

User selects "Watch Live" instead of "Go Live"

```dart
onTap: () {
  controller.setMode(LiveStreamMode.audience);  // ← Set as AUDIENCE
  Get.toNamed('/live_stream_audience');         // ← Go to join screen
},
```

---

### Step 3: Audience Join Screen

**File:** [lib/features/live_stream/presentation/screen/live_stream_audience_screen.dart](lib/features/live_stream/presentation/screen/live_stream_audience_screen.dart)

```dart
class LiveStreamAudienceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LiveStreamAudienceController>(
      init: LiveStreamAudienceController(),  // ← Initialize Audience Controller
      builder: (controller) {
        return Scaffold(
          body: Column(
            children: [
              TextField(
                controller: controller.channelController,  // ← Input channel name
                decoration: InputDecoration(
                  hintText: 'Enter the channel you want to watch',
                ),
              ),
              ElevatedButton.icon(
                onPressed: controller.joinStream,  // ← Join stream
                label: Text('Join Stream'),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

**Role:** UI for audience to enter channel name to watch

---

### Step 4: Audience Controller Joins Channel

**File:** [lib/features/live_stream/controller/live_stream_audience_controller.dart](lib/features/live_stream/controller/live_stream_audience_controller.dart)

```dart
class LiveStreamAudienceController extends GetxController {
  final channelController = TextEditingController();
  final Rx<bool> isJoining = false.obs;

  final agoraController = Get.find<AgoraController>();
  final liveStreamController = Get.find<LiveStreamController>();

  /// Join live stream as audience
  Future<void> joinStream() async {
    if (channelController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a channel name');
      return;
    }

    isJoining.value = true;  // ← Show loading

    try {
      // STEP 4A: Save channel name
      liveStreamController.setChannelName(channelController.text);

      // STEP 4B: Join Agora channel as audience
      await agoraController.joinChannelAsAudience(
        channelName: channelController.text,  // ← "riding_live"
        uid: 0,
      );

      // STEP 4C: Navigate to watching screen
      Get.off(() => const LiveStreamWatchingScreen());
    } catch (e) {
      Get.snackbar('Error', 'Failed to join stream: $e');
    } finally {
      isJoining.value = false;
    }
  }
}
```

**Role:** Orchestrates audience joining the broadcast

**Similar to Host, but:**
- Calls `joinChannelAsAudience()` instead of `joinChannelAsBroadcaster()`
- Navigates to `LiveStreamWatchingScreen` instead of broadcast screen

---

### Step 5: Join as Audience (Agora SDK)

```dart
/// Join channel as audience (viewer)
Future<void> joinChannelAsAudience({
  required String channelName,
  required int uid,
}) async {
  try {
    // STEP 1: Set channel profile to live broadcasting
    await agoraEngine.setChannelProfile(
      ChannelProfileType.channelProfileLiveBroadcasting,
    );

    // STEP 2: Set user role as AUDIENCE (not broadcaster)
    await agoraEngine.setClientRole(
      role: ClientRoleType.clientRoleAudience,  // ← DIFFERENT FROM HOST
    );

    // STEP 3: Join the SAME channel
    await agoraEngine.joinChannel(
      token: agoraToken,
      channelId: channelName,  // ← Same as host: "riding_live"
      uid: uid,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType: ClientRoleType.clientRoleAudience,  // ← AUDIENCE role
      ),
    );

    logger.i('Joined channel as audience: $channelName');
  } catch (e) {
    logger.e('Error joining channel as audience: $e');
    rethrow;
  }
}
```

**Key Differences from Host:**
- `setClientRole(role: ClientRoleType.clientRoleAudience)` - Can ONLY receive, not send
- Same `channelId` ("riding_live") - Joins host's channel
- Cannot send camera/audio (receive-only)

---

### Step 6: Watching Screen

**File:** [lib/features/live_stream/presentation/screen/live_stream_audience_screen.dart](lib/features/live_stream/presentation/screen/live_stream_audience_screen.dart) (Line 124+)

```dart
class LiveStreamWatchingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final agoraController = Get.find<AgoraController>();
    final liveStreamController = Get.find<LiveStreamController>();

    return Scaffold(
      body: Stack(
        children: [
          // 1. DISPLAY REMOTE (HOST'S) VIDEO FEED
          Obx(
            () {
              if (agoraController.remoteUids.isEmpty) {
                return Center(child: Text('Waiting for broadcaster...'));
              }

              // Show broadcaster's video
              return agoraController.getRemoteVideoWidget(
                agoraController.remoteUids[0],  // ← Get first (broadcaster)
              );
            },
          ),
          
          // 2. TOP BAR (Live Indicator)
          Positioned(
            top: 0,
            child: Container(
              child: Obx(
                () => agoraController.remoteUids.isNotEmpty
                    ? const Text('LIVE', style: TextStyle(color: Colors.red))
                    : const Text('Connecting...'),
              ),
            ),
          ),
          
          // 3. VIEWER COUNT
          Obx(
            () => Container(
              child: Text(
                '${agoraController.remoteUids.length + 1} viewers',
              ),
            ),
          ),
          
          // 4. BOTTOM CONTROLS
          Positioned(
            bottom: 0,
            child: Row(
              children: [
                // Share Button
                _buildControlButton(
                  icon: Icons.share,
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
                  onPressed: () async {
                    await agoraController.leaveChannel();
                    liveStreamController.reset();
                    Get.offNamed('/live_stream_mode');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

**Role:** Displays live broadcast to audience

**What's Visible:**
1. Broadcaster's video feed (remote video)
2. "LIVE" indicator when broadcaster is connected
3. Viewer count
4. Share button
5. Leave button

**Reactive Behavior:**
- `remoteUids` - List of remote users connected
- When host joins: `onUserJoined` fires, adds to `remoteUids`
- When host leaves: `onUserOffline` fires, removes from `remoteUids`

---

## PART 3: Data Flow Diagram

### Host Broadcast Flow

```
┌─────────┐
│  Host   │
└────┬────┘
     │
     ▼
┌──────────────────────────────────────┐
│ Mode Selection → "Go Live"           │
│ LiveStreamModeScreen                 │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│ Host Setup Screen                    │
│ LiveStreamHostScreen                 │
│ - Enter channel name: "riding_live"  │
│ - Click "Go Live"                    │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│ LiveStreamHostController             │
│ .startBroadcast()                    │
│ - isJoining = true                   │
│ - Set channel name                   │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│ AgoraController                      │
│ .joinChannelAsBroadcaster()          │
│ - setChannelProfile()                │
│ - setClientRole(broadcaster)         │
│ - joinChannel("riding_live")         │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│ Agora SDK                            │
│ (Remote Servers)                     │
│ - Authenticate with appId            │
│ - Create channel "riding_live"       │
│ - Start broadcasting host's camera   │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│ Event: onJoinChannelSuccess          │
│ isJoined = true                      │
│ isJoining = false                    │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│ LiveStreamActiveBroadcastScreen      │
│ - Display host's video               │
│ - Show "LIVE" indicator              │
│ - Show controls (mic, camera, end)   │
└──────────────────────────────────────┘
```

### Audience Viewing Flow

```
┌──────────┐
│ Audience │
└────┬─────┘
     │
     ▼
┌──────────────────────────────────────┐
│ Mode Selection → "Watch Live"        │
│ LiveStreamModeScreen                 │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│ Audience Join Screen                 │
│ LiveStreamAudienceScreen              │
│ - Enter channel: "riding_live"       │
│ - Click "Join Stream"                │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│ LiveStreamAudienceController         │
│ .joinStream()                        │
│ - isJoining = true                   │
│ - Set channel name                   │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│ AgoraController                      │
│ .joinChannelAsAudience()             │
│ - setChannelProfile()                │
│ - setClientRole(audience)            │
│ - joinChannel("riding_live")         │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│ Agora SDK                            │
│ - Join existing channel "riding_live"│
│ - Receive host's video stream        │
│ - Receive audio from host            │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│ Event: onJoinChannelSuccess          │
│ Event: onUserJoined (host's uid)     │
│ remoteUids = [host_uid]              │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│ LiveStreamWatchingScreen             │
│ - Display host's video               │
│ - Show "LIVE" indicator              │
│ - Show viewer count                  │
│ - Show share & leave buttons         │
└──────────────────────────────────────┘
```

---

## PART 4: Controller Hierarchy

```
┌─────────────────────────────────────────────────────────────┐
│                   AgoraController                           │
│  (Manages Agora SDK, Video/Audio, Channel Connection)       │
├─────────────────────────────────────────────────────────────┤
│ Observable State:                                           │
│  • isInitialized: bool                                     │
│  • isJoined: bool                                          │
│  • isMicEnabled: bool                                      │
│  • isCameraEnabled: bool                                   │
│  • remoteUids: List<int>                                   │
├─────────────────────────────────────────────────────────────┤
│ Key Methods:                                                │
│  • initializeAgora()                                       │
│  • joinChannelAsBroadcaster(channelName, uid)            │
│  • joinChannelAsAudience(channelName, uid)               │
│  • leaveChannel()                                          │
│  • toggleMic()                                             │
│  • toggleCamera()                                          │
│  • getLocalVideoWidget()                                   │
│  • getRemoteVideoWidget(uid)                               │
└─────────────────────────────────────────────────────────────┘
         ▲                                    ▲
         │                                    │
         │ Uses                               │ Uses
         │                                    │
┌────────┴────────────────────┐  ┌──────────┴─────────────────┐
│ LiveStreamHostController    │  │ LiveStreamAudienceController│
│ (Host-specific logic)       │  │ (Audience-specific logic)   │
├─────────────────────────────┤  ├────────────────────────────┤
│ State:                      │  │ State:                     │
│  • isJoining: bool          │  │  • isJoining: bool         │
│  • channelController        │  │  • channelController       │
├─────────────────────────────┤  ├────────────────────────────┤
│ Methods:                    │  │ Methods:                   │
│  • startBroadcast()         │  │  • joinStream()            │
└─────────────────────────────┘  └────────────────────────────┘
         ▲                                    ▲
         │                                    │
         │ Uses                               │ Uses
         │                                    │
┌────────┴──────────────────────┐  ┌────────┴────────────────────┐
│ LiveStreamController          │  │ LiveStreamController         │
│ (Shared state)                │  │ (Shared state)              │
├───────────────────────────────┤  ├──────────────────────────────┤
│  • mode: LiveStreamMode       │  │  • mode: LiveStreamMode      │
│  • channelName: String        │  │  • channelName: String       │
│  • userId: int                │  │  • userId: int               │
└───────────────────────────────┘  └──────────────────────────────┘
```

---

## PART 5: State Management Summary

### Observable States (Reactive)

**AgoraController:**
```dart
Rx<bool> isInitialized = false.obs;    // SDK ready?
Rx<bool> isJoined = false.obs;         // In channel?
Rx<bool> isMicEnabled = true.obs;      // Mic on/off
Rx<bool> isCameraEnabled = true.obs;   // Camera on/off
RxList<int> remoteUids = <int>[].obs;  // Other users in channel
```

**LiveStreamHostController:**
```dart
Rx<bool> isJoining = false.obs;  // Joining in progress?
TextEditingController channelController;  // Channel name input
```

**LiveStreamAudienceController:**
```dart
Rx<bool> isJoining = false.obs;  // Joining in progress?
TextEditingController channelController;  // Channel name input
```

**LiveStreamController:**
```dart
Rx<LiveStreamMode?> mode = Rx<LiveStreamMode?>(null);  // Host or Audience?
RxString channelName = ''.obs;   // Which channel?
RxInt userId = 0.obs;            // User's ID
```

### UI Reactivity (Using Obx)

```dart
// Example: Show video only when joined
Obx(
  () => agoraController.isJoined.value
      ? agoraController.getLocalVideoWidget()
      : CircularProgressIndicator(),
),

// Example: Update button based on mic state
Obx(
  () => IconButton(
    icon: Icon(
      agoraController.isMicEnabled.value ? Icons.mic : Icons.mic_off
    ),
    onPressed: () => agoraController.toggleMic(),
  ),
),

// Example: Show viewer count
Obx(
  () => Text('${agoraController.remoteUids.length + 1} viewers'),
),
```

---

## PART 6: Complete Interaction Timeline

### Host Timeline

```
T0: Host launches app
    └─> HomeScreen visible

T1: Host taps "Live Stream" card
    └─> Navigate to LiveStreamModeScreen

T2: Host selects "Go Live"
    └─> Set mode = LiveStreamMode.host
    └─> Navigate to LiveStreamHostScreen

T3: LiveStreamHostScreen loads
    └─> LiveStreamHostController.onInit()
    └─> channelController.text = "riding_live"

T4: Host clicks "Go Live" button
    └─> startBroadcast() called
    └─> isJoining = true (loading starts)

T5: Save channel name
    └─> liveStreamController.setChannelName("riding_live")

T6: Join Agora channel
    └─> joinChannelAsBroadcaster("riding_live", 0)
    └─> setChannelProfile(live broadcasting)
    └─> setClientRole(broadcaster)
    └─> joinChannel()

T7: Agora event fires
    └─> onJoinChannelSuccess event
    └─> isJoined = true (video visible)

T8: LiveStreamActiveBroadcastScreen appears
    └─> Shows host's camera feed
    └─> Shows "LIVE" indicator
    └─> Shows control buttons

T9-T15: Host is broadcasting
    └─> Can toggle mic
    └─> Can toggle camera
    └─> Audience can join anytime

T16: Host clicks "End"
    └─> leaveChannel()
    └─> isJoined = false
    └─> remoteUids.clear()
    └─> Navigate back to mode screen

T17: Broadcast ends
    └─> Audience disconnected
    └─> Channel closed
```

### Audience Timeline (Joins during Host's T9-T15)

```
T9: Audience launches app / joins livestream feature
    └─> Same as host steps T0-T2

T10: Audience selects "Watch Live"
     └─> Set mode = LiveStreamMode.audience
     └─> Navigate to LiveStreamAudienceScreen

T11: LiveStreamAudienceScreen loads
     └─> LiveStreamAudienceController.onInit()
     └─> channelController.text = ""

T12: Audience enters channel name
     └─> Types "riding_live"

T13: Audience clicks "Join Stream"
     └─> joinStream() called
     └─> isJoining = true (loading starts)

T14: Save channel name
     └─> liveStreamController.setChannelName("riding_live")

T15: Join Agora channel
     └─> joinChannelAsAudience("riding_live", 0)
     └─> setChannelProfile(live broadcasting)
     └─> setClientRole(audience)
     └─> joinChannel()

T16: Agora events fire
     └─> onJoinChannelSuccess event (audience joins)
     └─> onUserJoined event (audience sees host)
     └─> remoteUids = [host_uid]
     └─> isJoined = true (video visible)

T17: LiveStreamWatchingScreen appears
     └─> Shows host's video
     └─> Shows "LIVE" indicator
     └─> Shows viewer count

T18-T24: Audience is watching
     └─> Can see host's camera
     └─> Can see audio/video changes
     └─> Can tap share button

T25: Audience clicks "Leave"
     └─> leaveChannel()
     └─> isJoined = false
     └─> Navigate back to mode screen

T26: Audience disconnected
     └─> Host still broadcasting to others
```

---

## PART 7: Key Concepts

### 1. **Channel Names as Connection Points**

Both host and audience use the **same** channel name to connect:

```
Host creates channel:          Audience joins channel:
"riding_live"                  "riding_live"
      │                              │
      └──────────┬────────────────────┘
                 │
         Agora's servers create
         a "room" where they meet
```

### 2. **Broadcaster vs Audience Roles**

```
BROADCASTER (Host)          AUDIENCE (Viewer)
├─ Can SEND video           ├─ Can ONLY RECEIVE
├─ Can SEND audio           ├─ Cannot send video
├─ Can RECEIVE from others  ├─ Cannot send audio
├─ Takes up bandwidth       └─ Minimal bandwidth
└─ Expensive to Agora       └─ Cheap to Agora (scaling)
```

This is why Agora uses this role-based system - it allows 1 broadcaster to stream to thousands of cheap viewers.

### 3. **Real-time Events**

```
onJoinChannelSuccess()
└─ Fired when YOU join
└─ Update UI (show video)

onUserJoined()
└─ Fired when someone ELSE joins
└─ Add to remoteUids list
└─ For host: "New viewer joined!"
└─ For audience: "Broadcaster joined!"

onUserOffline()
└─ Fired when someone leaves
└─ Remove from remoteUids
└─ For host: "Viewer left"
└─ For audience: "Broadcast ended"
```

### 4. **GetX Reactivity**

```dart
// Declare observable
Rx<bool> isJoined = false.obs;

// Update it
isJoined.value = true;

// In UI, watch it automatically
Obx(
  () => isJoined.value ? Text('Joined') : Text('Not joined'),
),

// When isJoined changes, UI automatically rebuilds!
// No setState() needed!
```

---

## Summary: The Complete Picture

1. **Initialization Phase:**
   - App starts → `AgoraController.onInit()` → Agora SDK initialized once

2. **Host Broadcasting:**
   - Host → ModeScreen → HostSetupScreen → AgoraController.joinChannelAsBroadcaster() → Camera video shown

3. **Audience Viewing:**
   - Audience → ModeScreen → AudienceSetupScreen → AgoraController.joinChannelAsAudience() → Host's video shown

4. **Real-time Communication:**
   - Host's camera → Agora Servers → Audience's screen
   - Viewer count updated via `remoteUids` list

5. **Cleanup:**
   - Either party leaves → `leaveChannel()` → State reset → Navigate away

The entire system is built on:
- **GetX Controllers** for state management
- **Agora SDK** for real-time video/audio
- **Reactive widgets (Obx)** for automatic UI updates
- **Event handlers** for real-time notifications
