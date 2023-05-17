import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horpao_printer/qr_code_scanner_widget.dart';
import 'package:network_info_plus/network_info_plus.dart';

void _enablePlatformOverrideForDesktop() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}

void main() {
  _enablePlatformOverrideForDesktop();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _connectionStatus = 'Unknown';
  final NetworkInfo _networkInfo = NetworkInfo();

  @override
  void initState() {
    super.initState();
    _initNetworkInfo();
  }

  Future<void> _initNetworkInfo() async {
    String? wifiName,
        wifiBSSID,
        wifiIPv4,
        wifiIPv6,
        wifiGatewayIP,
        wifiBroadcast,
        wifiSubmask;

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
          wifiName = await _networkInfo.getWifiName();
        } else {
          wifiName = await _networkInfo.getWifiName();
        }
      } else {
        wifiName = await _networkInfo.getWifiName();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi Name', error: e);
      wifiName = 'Failed to get Wifi Name';
    }

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
          wifiBSSID = await _networkInfo.getWifiBSSID();
        } else {
          wifiBSSID = await _networkInfo.getWifiBSSID();
        }
      } else {
        wifiBSSID = await _networkInfo.getWifiBSSID();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi BSSID', error: e);
      wifiBSSID = 'Failed to get Wifi BSSID';
    }

    try {
      wifiIPv4 = await _networkInfo.getWifiIP();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi IPv4', error: e);
      wifiIPv4 = 'Failed to get Wifi IPv4';
    }

    try {
      if (!Platform.isWindows) {
        wifiIPv6 = await _networkInfo.getWifiIPv6();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi IPv6', error: e);
      wifiIPv6 = 'Failed to get Wifi IPv6';
    }

    try {
      if (!Platform.isWindows) {
        wifiSubmask = await _networkInfo.getWifiSubmask();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi submask address', error: e);
      wifiSubmask = 'Failed to get Wifi submask address';
    }

    try {
      if (!Platform.isWindows) {
        wifiBroadcast = await _networkInfo.getWifiBroadcast();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi broadcast', error: e);
      wifiBroadcast = 'Failed to get Wifi broadcast';
    }

    try {
      if (!Platform.isWindows) {
        wifiGatewayIP = await _networkInfo.getWifiGatewayIP();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi gateway address', error: e);
      wifiGatewayIP = 'Failed to get Wifi gateway address';
    }

    setState(() {
      _connectionStatus = 'Wifi Name: $wifiName\n'
          'Wifi BSSID: $wifiBSSID\n'
          'Wifi IPv4: $wifiIPv4\n'
          'Wifi IPv6: $wifiIPv6\n'
          'Wifi Broadcast: $wifiBroadcast\n'
          'Wifi Gateway: $wifiGatewayIP\n'
          'Wifi Submask: $wifiSubmask\n';
    });
  }

  static const platform = MethodChannel('samples.flutter.dev/battery');

  // Get battery level.
  String _batteryLevel = 'Unknown battery level.';

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          leading: Container(width: 1000),
          title: const Text('HorPao Printer'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QRCodeScannerWidget(),
                  ),
                );
              },
              icon: const Icon(Icons.qr_code_scanner),
            )
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _getBatteryLevel,
                child: const Text('Get Battery Level'),
              ),
              Text(_batteryLevel),
              const SizedBox(height: 16),
              Text(_connectionStatus.toString()),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:wifi_scan/wifi_scan.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// /// Example app for wifi_scan plugin.
// class MyApp extends StatefulWidget {
//   /// Default constructor for [MyApp] widget.
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   List<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[];
//   StreamSubscription<List<WiFiAccessPoint>>? subscription;
//   bool shouldCheckCan = true;
//
//   bool get isStreaming => subscription != null;
//
//   Future<void> _startScan(BuildContext context) async {
//     // check if "can" startScan
//     if (shouldCheckCan) {
//       // check if can-startScan
//       final can = await WiFiScan.instance.canStartScan();
//       // if can-not, then show error
//       if (can != CanStartScan.yes) {
//         if (mounted) kShowSnackBar(context, "Cannot start scan: $can");
//         return;
//       }
//     }
//
//     // call startScan API
//     final result = await WiFiScan.instance.startScan();
//     if (mounted) kShowSnackBar(context, "startScan: $result");
//     // reset access points.
//     setState(() => accessPoints = <WiFiAccessPoint>[]);
//   }
//
//   Future<bool> _canGetScannedResults(BuildContext context) async {
//     if (shouldCheckCan) {
//       // check if can-getScannedResults
//       final can = await WiFiScan.instance.canGetScannedResults();
//       // if can-not, then show error
//       if (can != CanGetScannedResults.yes) {
//         if (mounted) kShowSnackBar(context, "Cannot get scanned results: $can");
//         accessPoints = <WiFiAccessPoint>[];
//         return false;
//       }
//     }
//     return true;
//   }
//
//   Future<void> _getScannedResults(BuildContext context) async {
//     if (await _canGetScannedResults(context)) {
//       // get scanned results
//       final results = await WiFiScan.instance.getScannedResults();
//       setState(() => accessPoints = results);
//     }
//   }
//
//   Future<void> _startListeningToScanResults(BuildContext context) async {
//     if (await _canGetScannedResults(context)) {
//       subscription = WiFiScan.instance.onScannedResultsAvailable
//           .listen((result) => setState(() => accessPoints = result));
//     }
//   }
//
//   void _stopListeningToScanResults() {
//     subscription?.cancel();
//     setState(() => subscription = null);
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     // stop subscription for scanned results
//     _stopListeningToScanResults();
//   }
//
//   // build toggle with label
//   Widget _buildToggle({
//     String? label,
//     bool value = false,
//     ValueChanged<bool>? onChanged,
//     Color? activeColor,
//   }) =>
//       Row(
//         children: [
//           if (label != null) Text(label),
//           Switch(value: value, onChanged: onChanged, activeColor: activeColor),
//         ],
//       );
//
//   @override
//   Widget build(BuildContext context) {
//     final seen = <String>{};
//     final filterWifi = accessPoints.where((e) => seen.add(e.ssid)).toList();
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//           // useMaterial3: true,
//           ),
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Plugin example app'),
//           actions: [
//             _buildToggle(
//                 label: "Check can?",
//                 value: shouldCheckCan,
//                 onChanged: (v) => setState(() => shouldCheckCan = v),
//                 activeColor: Colors.purple)
//           ],
//         ),
//         body: Builder(
//           builder: (context) => Padding(
//             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
//             child: Column(
//               mainAxisSize: MainAxisSize.max,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.perm_scan_wifi),
//                       label: const Text('SCAN'),
//                       onPressed: () async => _startScan(context),
//                     ),
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.refresh),
//                       label: const Text('GET'),
//                       onPressed: () async => _getScannedResults(context),
//                     ),
//                     _buildToggle(
//                       label: "STREAM",
//                       value: isStreaming,
//                       onChanged: (shouldStream) async => shouldStream
//                           ? await _startListeningToScanResults(context)
//                           : _stopListeningToScanResults(),
//                     ),
//                   ],
//                 ),
//                 const Divider(),
//                 Flexible(
//                   child: Center(
//                     child: filterWifi.isEmpty
//                         ? const Text("NO SCANNED RESULTS")
//                         : ListView.builder(
//                             itemCount: filterWifi.length,
//                             itemBuilder: (context, i) =>
//                                 _AccessPointTile(accessPoint: filterWifi[i])),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// /// Show tile for AccessPoint.
// ///
// /// Can see details when tapped.
// class _AccessPointTile extends StatelessWidget {
//   final WiFiAccessPoint accessPoint;
//
//   const _AccessPointTile({Key? key, required this.accessPoint})
//       : super(key: key);
//
//   // build row that can display info, based on label: value pair.
//   Widget _buildInfo(String label, dynamic value) => Container(
//         decoration: const BoxDecoration(
//           border: Border(bottom: BorderSide(color: Colors.grey)),
//         ),
//         child: Row(
//           children: [
//             Text(
//               "$label: ",
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             Expanded(child: Text(value.toString()))
//           ],
//         ),
//       );
//
//   @override
//   Widget build(BuildContext context) {
//     final title = accessPoint.ssid;
//     late IconData signalIcon;
//     late Color signalColor;
//     if (accessPoint.level >= -65) {
//       signalIcon = Icons.signal_cellular_alt;
//       signalColor = Colors.green;
//     } else if (accessPoint.level >= -80) {
//       signalIcon = Icons.signal_cellular_alt_2_bar;
//       signalColor = Colors.yellow;
//     } else {
//       signalIcon = Icons.signal_cellular_alt_1_bar;
//       signalColor = Colors.red;
//     }
//     return Visibility(
//       visible: accessPoint.ssid.isNotEmpty,
//       replacement: Container(),
//       child: ListTile(
//         visualDensity: VisualDensity.compact,
//         leading: Icon(signalIcon, color: signalColor),
//         title: Text(title),
//         // subtitle: Text(accessPoint.capabilities),
//         onTap: () => showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: Text(title),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildInfo("BSSDI", accessPoint.bssid),
//                 _buildInfo("Capability", accessPoint.capabilities),
//                 _buildInfo("frequency", "${accessPoint.frequency}MHz"),
//                 _buildInfo("level", accessPoint.level),
//                 _buildInfo("standard", accessPoint.standard),
//                 _buildInfo(
//                     "centerFrequency0", "${accessPoint.centerFrequency0}MHz"),
//                 _buildInfo(
//                     "centerFrequency1", "${accessPoint.centerFrequency1}MHz"),
//                 _buildInfo("channelWidth", accessPoint.channelWidth),
//                 _buildInfo("isPasspoint", accessPoint.isPasspoint),
//                 _buildInfo(
//                     "operatorFriendlyName", accessPoint.operatorFriendlyName),
//                 _buildInfo("venueName", accessPoint.venueName),
//                 _buildInfo(
//                     "is80211mcResponder", accessPoint.is80211mcResponder),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// /// Show snackbar.
// void kShowSnackBar(BuildContext context, String message) {
//   if (kDebugMode) print(message);
//   ScaffoldMessenger.of(context)
//     ..hideCurrentSnackBar()
//     ..showSnackBar(SnackBar(content: Text(message)));
// }

// import 'package:flutter/material.dart';
//
// import 'package:wifi_connector/wifi_connector.dart';
//
// void main() => runApp(const MyApp());
//
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   final _ssidController = TextEditingController(text: '');
//   final _passwordController = TextEditingController(text: '');
//   var _isSucceed = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Wifi connector example app'),
//         ),
//         body: ListView(
//           children: [
//             _buildTextInput(
//               'ssid',
//               _ssidController,
//             ),
//             _buildTextInput(
//               'password',
//               _passwordController,
//             ),
//             Padding(
//               padding: const EdgeInsets.only(top: 24.0),
//               child: ElevatedButton(
//                 onPressed: _onConnectPressed,
//                 child: const Text(
//                   'connect',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ),
//             Text(
//               'Is wifi connected?: $_isSucceed',
//               textAlign: TextAlign.center,
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextInput(String title, TextEditingController controller) {
//     return Row(
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 24.0),
//           child: SizedBox(width: 80.0, child: Text(title)),
//         ),
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 32.0),
//             child: TextField(
//               controller: controller,
//               onChanged: (value) => setState(
//                 () {},
//               ),
//             ),
//           ),
//         )
//       ],
//     );
//   }
//
//   Future<void> _onConnectPressed() async {
//     final ssid = _ssidController.text;
//     final password = _passwordController.text;
//     setState(() => _isSucceed = false);
//     final isSucceed =
//         await WifiConnector.connectToWifi(ssid: ssid, password: password);
//     setState(() => _isSucceed = isSucceed);
//   }
// }
