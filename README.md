# Apple Wallet Integration in Flutter

This repository demonstrates how to integrate **Apple Wallet passes** (such as event tickets, boarding passes, and coupons) into a Flutter app using platform channels to communicate between Flutter and native iOS code. Since Flutter doesn’t provide native support for Apple Wallet, we implement platform-specific functionality for iOS via the **PassKit** framework.

## Features

- Add `.pkpass` files to Apple Wallet from within the Flutter app.
- Communicate with native iOS code using Flutter's platform channels.
- Handle pass addition logic in Swift with Apple's **PassKit** framework.

## Prerequisites

1. **Apple Developer Account**: You need an active Apple Developer account to create a Pass Type ID and download the Wallet certificate.
2. **PassKit Certificate**: You need a valid **PassKit** certificate for signing passes. Passes are `.pkpass` files in JSON format.
3. **Flutter environment**: Ensure Flutter is installed on your system.
4. **Xcode**: Required for building and running the iOS app.

## Getting Started

### 1. Prepare the `.pkpass` File

You need to create a `.pkpass` file that contains the pass information (boarding pass, coupon, event ticket, etc.). Follow Apple's documentation on how to create and sign `.pkpass` files:

- Create a **Pass Type ID** in your [Apple Developer Account](https://developer.apple.com/account/).
- Generate a pass using [PassKit](https://developer.apple.com/documentation/walletpasses).
- Store the `.pkpass` file on a server or local storage for testing.

### 2. Add Dependencies

Edit your iOS `Podfile` in the `ios/` folder of your Flutter project to include the **PassKit** framework:
``` 
target 'Runner' 
  do use_frameworks! 
  pod 'PassKit' 
end
```
Then, run `pod install` in the `ios` directory:
```
cd ios 
pod install
```

### 3. Native Code Implementation (iOS)
Open the `ios/Runner.xcworkspace` in Xcode and modify the `AppDelegate.swift` file (or create a new Swift file) to handle pass addition.
```
import Flutter
import UIKit
import PassKit

@UIApplicationMain
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
```
### 4. Setup Platform Channel in Flutter

Flutter uses **platform channels** to communicate with native code. Set up the platform channel in your Dart code to invoke the native iOS functionality.
```
import 'package:flutter/services.dart';

class AppleWalletService {
  static const platform = MethodChannel('com.example.app/appleWallet');

  static Future<void> addPassToWallet(String passUrl) async {
    try {
      await platform.invokeMethod('addPassToWallet', {"passUrl": passUrl});
    } on PlatformException catch (e) {
      print("Failed to add pass to Wallet: '${e.message}'.");
    }
  }
}
```
### 6. Call the Service from Flutter

Invoke the method from Flutter to add a pass to the Apple Wallet:
```
import 'package:flutter/cupertino.dart';  
import 'package:flutter/material.dart';  
  
import 'AppleWalletService.dart';  
  
void main() {  
  runApp(const MyApp());  
}  
  
class MyApp extends StatelessWidget {  
  const MyApp({super.key});  
  
  @override  
  Widget build(BuildContext context) {  
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();  
    return CupertinoApp(  
      key: scaffoldKey,  
      localizationsDelegates: const [  
        DefaultMaterialLocalizations.delegate,  
        DefaultCupertinoLocalizations.delegate,  
        DefaultWidgetsLocalizations.delegate,  
      ],  
      home: Builder(builder: (context) => Scaffold(  
        appBar: AppBar(  
          title: const Text('Apple Wallet Integration'),  
        ),  
        body: Center(  
          child: ElevatedButton(  
            onPressed: () async {  
              showAlertDialog(context);  
              await AppleWalletService.addPassToWallet('https://firebasestorage.googleapis.com/v0/b/flutterapp-7e5eb.appspot.com/o/Example.pkpass?alt=media');  
              if (context.mounted) Navigator.of(context).pop();  
            },  
            child: const Text('Add Pass to Apple Wallet'),  
          ),  
        ),  
      ),  
    ));  
  }  
  
  showAlertDialog(BuildContext context) {  
    showDialog(  
      context: context,  
      builder: (BuildContext context) {  
        return const AlertDialog(  
          backgroundColor: Colors.white,  
          shape: RoundedRectangleBorder(  
              borderRadius: BorderRadius.all(Radius.circular(32.0))),  
          contentPadding: EdgeInsets.symmetric(vertical: 50),  
          content: Column(  
            mainAxisSize: MainAxisSize.min,  
            children: [  
              CircularProgressIndicator(),  
              SizedBox(height: 20),  
              Text('Loading pass, please wait...'),  
            ],  
          ),  
        );  
      },  
    );  
  }  
}
```
### 7. Run the App

Build and run the app on a real iOS device. The iOS simulator does not support Apple Wallet.
```
flutter run
```



## Notes

-   The `.pkpass` file must be hosted on a valid HTTPS server or available locally.
-   The `.pkpass` file must be hosted on a valid HTTPS server or available locally.
-   Testing should be done on a real device, as Apple Wallet features are not available on the simulator.
-   Ensure your app has the necessary entitlements and permissions to use Apple Wallet.
