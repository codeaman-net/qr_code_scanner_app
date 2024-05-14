import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "QR Code Scanner",
      theme: ThemeData(primarySwatch: Colors.indigo),
      debugShowCheckedModeBanner: false,
      home: const QRCodeWidget(),
    );
  }
}

class QRCodeWidget extends StatefulWidget {
  const QRCodeWidget({super.key});

  @override
  _QRCodeWidgetState createState() => _QRCodeWidgetState();
}

class _QRCodeWidgetState extends State<QRCodeWidget> {
  final GlobalKey qrKey = GlobalKey(debugLabel: "QR");
  QRViewController? controller;
  String result = "";

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData.code!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Code Scanner"),
      ),
      body: Column(
        children: [
          Expanded(
              flex: 5,
              child: QRView(key: qrKey, onQRViewCreated: _onQRViewCreated)),
          Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  "Scan Result: $result",
                  style: const TextStyle(fontSize: 18.0),
                ),
              )),
          Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        if (result.isNotEmpty) {
                          Clipboard.setData(ClipboardData(text: result));
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Copied to Clipboard")));
                        }
                      },
                      child: const Text("Copy")),
                  ElevatedButton(
                      onPressed: () async {
                        if (result.isNotEmpty) {
                          final Uri url = Uri.parse(result);
                          await launchUrl(url);
                        }
                      },
                      child: const Text("Open in Browser"))
                ],
              ))
        ],
      ),
    );
  }
}
