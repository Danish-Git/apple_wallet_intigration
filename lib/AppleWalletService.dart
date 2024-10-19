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