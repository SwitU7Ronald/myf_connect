import 'package:permission_handler/permission_handler.dart';

/// Abstract class representing a global service for device permissions.
abstract class PermissionService {
  /// Checks the current status of a given permission.
  Future<PermissionStatus> checkPermission(Permission permission);

  /// Requests a given permission from the user.
  Future<PermissionStatus> requestPermission(Permission permission);

  /// Requests multiple permissions at once.
  Future<Map<Permission, PermissionStatus>> requestPermissions(
    List<Permission> permissions,
  );

  /// Opens the device settings for the app.
  Future<bool> openSettings();
}

class PermissionServiceImpl implements PermissionService {
  @override
  Future<PermissionStatus> checkPermission(Permission permission) async {
    return await permission.status;
  }

  @override
  Future<PermissionStatus> requestPermission(Permission permission) async {
    return await permission.request();
  }

  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
    List<Permission> permissions,
  ) async {
    return await permissions.request();
  }

  @override
  Future<bool> openSettings() async {
    return await openAppSettings();
  }
}
