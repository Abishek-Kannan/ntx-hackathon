

import 'package:permission_handler/permission_handler.dart';

import 'Printer.dart';

class PermissionHandler{

  static List<Permission> _permissions = [
    Permission.storage,
    Permission.bluetooth,
    Permission.location,
  ];

  static Future<bool> seekPermissions() async {
    printer("Seeking Permissions");
    Map<Permission, PermissionStatus> permissions =   await _permissions.request();
    bool allEnabled = true;
    List<Permission> permissionList = permissions.keys.toList();
    for (int i = 0; i < permissionList.length; i++) {
      allEnabled &= await permissionList[i].isGranted;
    }
    print("All Permission Enabled ${allEnabled}");

    return Future.value(allEnabled);
  }
}