import Flutter
import UIKit
import PassKit

@main
@objc class AppDelegate: FlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let appleWalletChannel = FlutterMethodChannel(name: "com.example.app/appleWallet", binaryMessenger: controller.binaryMessenger)

        appleWalletChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "addPassToWallet" {
                if let args = call.arguments as? [String: Any],
                   let passUrlString = args["passUrl"] as? String,
                   let passUrl = URL(string: passUrlString) {
                    self.addPassToWallet(url: passUrl)
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Pass URL missing", details: nil))
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        })

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func addPassToWallet(url: URL) {
        if let passData = try? Data(contentsOf: url) {
            do {
                let pass = try PKPass(data: passData)
                let passLibrary = PKPassLibrary()

                if !passLibrary.containsPass(pass) {
                    let addPassVC = PKAddPassesViewController(pass: pass)
                    window?.rootViewController?.present(addPassVC!, animated: true, completion: nil)
                }
            } catch {
                print("Error adding pass to wallet")
            }
        }
    }
}

