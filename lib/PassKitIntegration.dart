import 'package:flutter/services.dart';

class PassKitIntegration {
  static const MethodChannel _channel = MethodChannel('passkit_integration');

  static Future<void> addToWallet(String passData) async {
    try {
      await _channel.invokeMethod('addToWallet', {'passData': passData});
    } on PlatformException catch (e) {
      print("Failed to add to wallet: '${e.message}'.");
    }
  }
}
