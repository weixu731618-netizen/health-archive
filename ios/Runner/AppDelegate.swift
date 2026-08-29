import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  /// B2：与 Dart 侧 PushService 通信的通道（获取 / 上报 APNs device token）。
  private var pushChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    if let messenger = engineBridge.pluginRegistry
      .registrar(forPlugin: "HealthArchivePushChannel")?.messenger() {
      let channel = FlutterMethodChannel(
        name: "health_archive/push", binaryMessenger: messenger)
      channel.setMethodCallHandler { call, result in
        switch call.method {
        case "registerForRemoteNotifications":
          DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
          }
          result(nil)
        case "getApnsEnvironment":
          #if DEBUG
          result("sandbox")
          #else
          result("production")
          #endif
        default:
          result(FlutterMethodNotImplemented)
        }
      }
      self.pushChannel = channel
    }
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    let token = deviceToken.map { String(format: "%02x", $0) }.joined()
    pushChannel?.invokeMethod("onApnsToken", arguments: token)
    super.application(
      application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    pushChannel?.invokeMethod("onApnsError", arguments: error.localizedDescription)
    super.application(
      application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
}
