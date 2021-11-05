import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../../../design/design.dart';

class ScannerWidget extends StatefulWidget {
  const ScannerWidget({Key? key}) : super(key: key);

  @override
  _ScannerWidgetState createState() => _ScannerWidgetState();
}

class _ScannerWidgetState extends State<ScannerWidget> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

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
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          children: [
            QRView(
              key: qrKey,
              onQRViewCreated: (QRViewController controller) async {
                this.controller = controller;

                controller.scannedDataStream.first.then((value) async {
                  await HapticFeedback.vibrate();

                  Navigator.of(context).pop<String>(value.code);
                }).onError((error, stackTrace) => null);
              },
              overlay: QrScannerOverlayShape(
                borderColor: Colors.white,
                borderWidth: 6,
                borderRadius: 10,
                borderLength: 30,
                cutOutSize: MediaQuery.of(context).size.width / 1.5,
              ),
              onPermissionSet: (QRViewController controller, bool permitted) {
                if (!permitted) {
                  Navigator.of(context).pop(null);
                }
              },
            ),
            Align(
              alignment: Alignment.topLeft,
              child: SafeArea(
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  iconSize: 36,
                ),
              ),
            ),
          ],
        ),
      );
}
