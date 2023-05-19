import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:horpao_printer/app_de_bouncer_widget.dart';
import 'package:horpao_printer/app_progress_hud_widget.dart';
import 'package:horpao_printer/main.dart';
import 'package:wifi_iot/wifi_iot.dart';

class WifiConfirmWidget extends StatefulWidget {
  final String? ip;
  final String? ssid;

  const WifiConfirmWidget({Key? key, this.ip, this.ssid}) : super(key: key);

  @override
  State<WifiConfirmWidget> createState() => _WifiConfirmWidgetState();
}

class _WifiConfirmWidgetState extends State<WifiConfirmWidget> {
  TextEditingController ipController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;
  bool checkConnect = false;
  final _deBouncer = DeBouncer(seconds: 1);

  @override
  void initState() {
    setState(() {
      ipController.text = widget.ip ?? "";
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppProgressHUD(
      inAsyncCall: checkConnect,
      child: Scaffold(
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
          title: const Text("Wifi Confirm"),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: ipController,
                      decoration: const InputDecoration(
                        label: Text("IP"),
                        prefixIcon: Icon(
                          Icons.print,
                          size: 20,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        label: const Text("Password"),
                        prefixIcon: const Icon(
                          Icons.lock,
                          size: 20,
                        ),
                        suffixIcon: GestureDetector(
                          child: Icon(
                            _obscureText
                                ? FontAwesomeIcons.eye
                                : FontAwesomeIcons.eyeSlash,
                            size: 15,
                            color: Colors.blue,
                          ),
                          onTap: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(16),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final bool checkConnectWifi = await WiFiForIoTPlugin.connect(
                    widget.ssid ?? "",
                    password: passwordController.text,
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
                          builder: (context) => const MyHomePage(),
                        ),
                      );
                    });
                  } else {
                    print("fail connect");
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("Summit".toUpperCase()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
