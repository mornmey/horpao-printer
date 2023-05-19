import 'dart:io';
import 'package:flutter/material.dart';
import 'package:horpao_printer/app_progress_hud_widget.dart';
import 'package:horpao_printer/wifi_list_widget.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:wifi_iot/wifi_iot.dart';

import 'app_de_bouncer_widget.dart';

class QRCodeScannerWidget extends StatefulWidget {
  const QRCodeScannerWidget({Key? key}) : super(key: key);

  @override
  State<QRCodeScannerWidget> createState() => _QRCodeScannerWidgetState();
}

class _QRCodeScannerWidgetState extends State<QRCodeScannerWidget> {
  bool _hide = true;
  bool checkConnect = false;
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final _deBouncer = DeBouncer(seconds: 1);

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppProgressHUD(
      inAsyncCall: checkConnect,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.topLeft,
                children: [
                  QRView(
                    key: qrKey,
                    onQRViewCreated: _onQRViewCreated,
                    overlay: QrScannerOverlayShape(
                      borderColor: Colors.blue,
                      borderRadius: 10,
                      borderLength: 25,
                      borderWidth: 10,
                    ),
                    onPermissionSet: (ctrl, p) {
                      _onPermissionSet(context, ctrl, p);
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.only(bottom: 30),
                    alignment: Alignment.bottomCenter,
                    child: IconButton(
                      onPressed: () async {
                        await controller?.toggleFlash();
                        setState(() {
                          _hide = !_hide;
                        });
                      },
                      color: Colors.white,
                      icon: Icon(
                        _hide
                            ? Icons.flashlight_on_rounded
                            : Icons.flashlight_off_rounded,
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 30, horizontal: 5),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      /// Result = WIFI:T:WPA;S:WIFI Printer;P:012345678;;
      result = scanData;

      /// Remove double Semicolon => WIFI:T:WPA;S:WIFI Printer;P:012345678
      String removeSem = result!.code!.substring(0, result!.code!.length - 2);

      /// Count number last of Colon => Number of length 27
      var posRemoveSmc = removeSem.lastIndexOf(':');

      /// Result of Password => 012345678
      String password = removeSem.substring(posRemoveSmc).split(":").join();

      /// Remove last of Colon => WIFI:T:WPA;S:WIFI Printer;P
      String removeLastCol = removeSem.substring(0, posRemoveSmc);

      /// Remove last two cha => WIFI:T:WPA;S:WIFI Printer
      String removeTwoCha =
          removeLastCol.substring(0, removeLastCol.length - 2);

      /// Count number last of Colon again => Number of length 12
      var posRemoveTwoCha = removeTwoCha.lastIndexOf(':');

      /// Result of nameOfWifi => WIFI Printer
      String wifiName =
          removeTwoCha.substring(posRemoveTwoCha).split(":").join();

      if (result != null) {
        final bool checkConnectWifi = await WiFiForIoTPlugin.connect(
          wifiName,
          password: password,
          joinOnce: true,
          security: NetworkSecurity.WPA,
        );
        setState(() {
          checkConnect = checkConnectWifi;
        });
        if (checkConnectWifi == true) {
          _deBouncer.run(() {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const WifiListWidget(),
              ),
            );
          });
        } else {
          print("fail connect");
        }
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
