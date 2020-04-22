import UIKit
import Flutter
import background_locator
import GoogleMaps
import encryptions
import path_provider

private func registerPlugins(registry: FlutterPluginRegistry) {
    if (!registry.hasPlugin("BackgroundLocatorPlugin")) {
       BackgroundLocatorPlugin.register(with: registry.registrar(forPlugin: "BackgroundLocatorPlugin"))
    }
    if (!registry.hasPlugin("EncryptionsPlugin")) {
        EncryptionsPlugin.register(with: registry.registrar(forPlugin: "EncryptionsPlugin"))
    }
    if (!registry.hasPlugin("FLTPathProviderPlugin")) {
        FLTPathProviderPlugin.register(with: registry.registrar(forPlugin: "FLTPathProviderPlugin"))
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
    //app.rekab/locator_plugin
    GeneratedPluginRegistrant.register(with: self)
    GMSServices.provideAPIKey("<GOOGLE_MAP_API>")
    BackgroundLocatorPlugin.setPluginRegistrantCallback(registerPlugins)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
