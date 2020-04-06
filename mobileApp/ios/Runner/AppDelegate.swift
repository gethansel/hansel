import UIKit
import Flutter
import background_locator

//func registerPlugins(registry: FlutterPluginRegistry) -> () {
//    GeneratedPluginRegistrant.register(with: registry)
//}

private func registerPlugins(registry: FlutterPluginRegistry) {
    if (!registry.hasPlugin("BackgroundLocatorPlugin")) {
       BackgroundLocatorPlugin.register(with: registry.registrar(forPlugin: "BackgroundLocatorPlugin"))
    }
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    GeneratedPluginRegistrant.register(with: self)
    //app.rekab/locator_plugin
    BackgroundLocatorPlugin.setPluginRegistrantCallback(registerPlugins)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
