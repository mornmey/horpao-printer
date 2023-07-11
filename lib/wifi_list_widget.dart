import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:horpao_printer/main.dart';
import 'package:horpao_printer/wifi_confirm_widget.dart';

class WifiListWidget extends StatefulWidget {
  const WifiListWidget({Key? key}) : super(key: key);

  @override
  State<WifiListWidget> createState() => _WifiListWidgetState();
}

class _WifiListWidgetState extends State<WifiListWidget> {
  @override
  Widget build(BuildContext context) {
    String ip = "";
    final ssid = nameOfWifi;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            size: 20,
            color: Colors.black,
          ),
        ),
        title: const Text("Wifi"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              onTap: () {
                var pos = iPv4OfWifi.lastIndexOf('.');
                String result = iPv4OfWifi.substring(0, pos);

                int removedLastThree = int.parse(iPv4OfWifi
                    .substring(iPv4OfWifi.length - 3, iPv4OfWifi.length)
                    .split(".")
                    .join());

                if (removedLastThree >= 160) {
                  ip = "$result.80";
                } else {
                  ip = "$result.200";
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WifiConfirmWidget(
                      ip: ip,
                      ssid: ssid,
                    ),
                  ),
                );
              },
              leading: const Icon(Icons.wifi),
              title: Text(ssid),
              trailing: GestureDetector(
                onTap: () {},
                child: const Icon(Icons.more_vert),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void kShowSnackBar(BuildContext context, String message) {
    if (kDebugMode) print(message);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }
}
