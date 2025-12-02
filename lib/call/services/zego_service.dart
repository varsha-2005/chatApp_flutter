import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class ZegoService {
  static const int appID = 2105502131;
  static const String appSign =
      "6b85e8e62c96b3a8f478c6e8ef45a0f11897bcd1e0a809810411ed109af61135";

  static Future<void> initZego({
    required String userID,
    required String userName,
  }) async {
    await ZegoUIKitPrebuiltCallInvitationService().init(
      appID: appID,
      appSign: appSign,
      userID: userID,
      userName: userName,

      // ⭐ NEW SDK: NO usePlugin(), only this
      plugins: [ZegoUIKitSignalingPlugin()],
    );

    print("Zego Initialized for: $userID");
  }

  static Future<void> logout() async {
    await ZegoUIKitPrebuiltCallInvitationService().uninit();
  }
}
