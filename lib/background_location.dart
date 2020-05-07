import 'dart:async';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// BackgroundLocation plugin to get background
/// lcoation updates in iOS and Android
class BackgroundLocation {
  // The channel to be used for communication.
  // This channel is also refrenced inside both iOS and Abdroid classes
  static const MethodChannel _channel =
      const MethodChannel('almoullim.com/background_location');

  /// Stop receiving location updates
  static stopLocationService() {
    _channel.invokeMapMethod("stop_location_service");
  }

  /// Start receiving location updated
  static startLocationService() {
    _channel.invokeMapMethod("start_location_service");
  }

  /// Get the current location once.
  Future<_Location> getCurrentLocation() async {
    Completer<_Location> completer = Completer();

    _Location _location = _Location();
    await getLocationUpdates((location) {
      _location.latitude = location.latitude;
      _location.longitude = location.longitude;
      _location.accuracy = location.accuracy;
      _location.altitude = location.altitude;
      _location.bearing = location.bearing;
      _location.speed = location.speed;
      completer.complete(_location);
    });

    return completer.future;
  }

  /// Ask the user for location permissions
  static getPermissions({Function onGranted, Function onDenied}) async {
    if (await Permission.locationAlways.request().isGranted) {
      onGranted();
    } else {
      onDenied();
    }
  }

  /// Check what the current permissions status is
  static Future<PermissionStatus> checkPermissions() async {
    var status = await Permission.locationAlways.status;
    return status;
  }

  /// Register a function to recive location updates as long as the location
  /// service has started
  static getLocationUpdates(Function(_Location) location) {
    // add a handler on the channel to recive updates from the native classes
    _channel.setMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == "location") {
        Map locationData = Map.from(methodCall.arguments);
        // Call the user passed function
        location(
          _Location(
            latitude: locationData["latitude"],
            longitude: locationData["longitude"],
            altitude: locationData["altitude"],
            accuracy: locationData["accuracy"],
            bearing: locationData["bearing"],
            speed: locationData["speed"],
          ),
        );
      }
    });
  }
}

/// An object containing infromation
/// about the user current location
class _Location {
  _Location(
      {this.longitude,
      this.latitude,
      this.altitude,
      this.accuracy,
      this.bearing,
      this.speed});

  double latitude;
  double longitude;
  double altitude;
  double bearing;
  double accuracy;
  double speed;
}
