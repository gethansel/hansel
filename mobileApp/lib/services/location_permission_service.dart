import 'dart:async';
import 'package:location_permissions/location_permissions.dart';

class LocationPermissionService {
  final StreamController<bool> _streamController = StreamController();
  final LocationPermissions _locationPermissions = LocationPermissions();

  Stream<bool> get onPermissionChanged => _streamController.stream;

  void closeStream() {
    _streamController.close();
  }

  Future<bool> checkPermission() async {
     PermissionStatus permission = await _locationPermissions
        .checkPermissionStatus(level: LocationPermissionLevel.locationAlways);
    if (permission == PermissionStatus.unknown) {
      permission = await _locationPermissions.requestPermissions(
        permissionLevel: LocationPermissionLevel.locationAlways,
      );
      if (permission == PermissionStatus.granted) {
        _streamController.sink.add(true);
        return true;
      } else {
        _streamController.sink.add(false);
        return false;
      }
    } else if (permission == PermissionStatus.granted) {
      _streamController.sink.add(true);
      return true;
    } else {
      _streamController.sink.add(false);
      return false;
    }
  }
}