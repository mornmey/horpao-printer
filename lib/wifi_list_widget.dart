import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:horpao_printer/wifi_confirm_widget.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';

class WifiListWidget extends StatefulWidget {
  const WifiListWidget({Key? key}) : super(key: key);

  @override
  State<WifiListWidget> createState() => _WifiListWidgetState();
}

class _WifiListWidgetState extends State<WifiListWidget> {
  List<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[];
  bool shouldCheckCan = true;
  late String wifiName, wifiIPv4, wifiGatewayIP, wifiSubMask;
  final NetworkInfo _networkInfo = NetworkInfo();

  Future<bool> _canGetScannedResults(BuildContext context) async {
    if (shouldCheckCan) {
      // check if can-getScannedResults
      final can = await WiFiScan.instance.canGetScannedResults();
      // if can-not, then show error
      if (can != CanGetScannedResults.yes) {
        if (mounted) kShowSnackBar(context, "Cannot get scanned results: $can");
        accessPoints = <WiFiAccessPoint>[];
        return false;
      }
    }
    return true;
  }

  Future<void> _getScannedResults(BuildContext context) async {
    if (await _canGetScannedResults(context)) {
      // get scanned results
      final results = await WiFiScan.instance.getScannedResults();

      setState(() => accessPoints = results);
    }
  }

  Future<void> _initNetworkInfo() async {
    String? infoWifiName, infoWifiIPv4, infoWifiSubMask, infoWifiGatewayIP;

    try {
      if (!kIsWeb && Platform.isIOS) {
        // ignore: deprecated_member_use
        var status = await _networkInfo.getLocationServiceAuthorization();
        if (status == LocationAuthorizationStatus.notDetermined) {
          // ignore: deprecated_member_use
          status = await _networkInfo.requestLocationServiceAuthorization();
        }
        if (status == LocationAuthorizationStatus.authorizedAlways ||
            status == LocationAuthorizationStatus.authorizedWhenInUse) {
          infoWifiName = await _networkInfo.getWifiName();
        } else {
          infoWifiName = await _networkInfo.getWifiName();
        }
      } else {
        infoWifiName = await _networkInfo.getWifiName();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi Name', error: e);
      infoWifiName = 'Failed to get Wifi Name';
    }

    try {
      infoWifiIPv4 = await _networkInfo.getWifiIP();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi IPv4', error: e);
      infoWifiIPv4 = 'Failed to get Wifi IPv4';
    }
    try {
      if (!Platform.isWindows) {
        infoWifiSubMask = await _networkInfo.getWifiSubmask();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi submask address', error: e);
      infoWifiSubMask = 'Failed to get Wifi submask address';
    }
    try {
      if (!Platform.isWindows) {
        infoWifiGatewayIP = await _networkInfo.getWifiGatewayIP();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi gateway address', error: e);
      infoWifiGatewayIP = 'Failed to get Wifi gateway address';
    }
    setState(() {
      wifiName = infoWifiName ?? "";
      wifiIPv4 = infoWifiIPv4!;
      wifiGatewayIP = infoWifiGatewayIP!;
      wifiSubMask = infoWifiSubMask!;
    });
  }

  @override
  void initState() {
    _getScannedResults(context);
    _initNetworkInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String ip = "";
    final seen = <String>{};
    final filterWifi = accessPoints.where((e) => seen.add(e.ssid)).toList();
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
        actions: [
          IconButton(
            onPressed: () async => _getScannedResults(context),
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: filterWifi.isEmpty
          ? const Center(child: Text("NO SCANNED RESULTS"))
          : SingleChildScrollView(
              child: Column(
                children: filterWifi.map((e) {
                  final title = e.ssid;
                  late IconData signalIcon;
                  late Color signalColor;
                  if (e.level >= -65) {
                    signalIcon = Icons.signal_cellular_alt;
                    signalColor = Colors.green;
                  } else if (e.level >= -80) {
                    signalIcon = Icons.signal_cellular_alt_2_bar;
                    signalColor = Colors.yellow;
                  } else {
                    signalIcon = Icons.signal_cellular_alt_1_bar;
                    signalColor = Colors.red;
                  }

                  final ssid = wifiName.substring(1, wifiName.length - 1);
                  return Visibility(
                    visible: e.ssid.isNotEmpty && e.ssid == ssid,
                    replacement: Container(),
                    child: ListTile(
                      onTap: () {
                        var pos = wifiIPv4.lastIndexOf('.');
                        String result = wifiIPv4.substring(0, pos);

                        int removedLastThree = int.parse(wifiIPv4
                            .substring(wifiIPv4.length - 3, wifiIPv4.length)
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
                            ),
                          ),
                        );
                      },
                      leading: Icon(signalIcon, color: signalColor),
                      title: Text(title),
                      trailing: GestureDetector(
                        onTap: () {},
                        child: const Icon(Icons.more_vert),
                      ),
                    ),
                  );
                }).toList(),
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
