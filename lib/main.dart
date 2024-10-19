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
