import 'package:permission_handler/permission_handler.dart';

Future<bool> checkCameraPermission() async {
  var status = await Permission.camera.status;

  if (!status.isGranted) {
    status = await Permission.camera.request();
  }

  if (!status.isGranted) {
    openAppSettings();
    return false;
  } else {
    return true;
  }
}
