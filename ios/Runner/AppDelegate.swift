import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    var mapsApiKey = "NOT_FOUND"
    if let envPath = Bundle.main.path(forResource: "flutter_assets/.env", ofType: nil),
       let envString = try? String(contentsOfFile: envPath, encoding: .utf8) {
        let envLines = envString.components(separatedBy: .newlines)
        for line in envLines {
            let parts = line.components(separatedBy: "=")
            if parts.count == 2, parts[0] == "MAPS_API_KEY" {
                mapsApiKey = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
                break
            }
        }
    }
    GMSServices.provideAPIKey(mapsApiKey)
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
