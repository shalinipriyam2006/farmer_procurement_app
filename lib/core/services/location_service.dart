import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:farmer_procurement_app/core/models/procurement_center.dart';

enum LocationStatus { granted, denied, deniedForever, serviceDisabled, error }

class UserLocationResult {
  final double latitude;
  final double longitude;
  final LocationStatus status;
  final bool isFallback;
  final String? errorMessage;

  const UserLocationResult({
    required this.latitude,
    required this.longitude,
    required this.status,
    this.isFallback = false,
    this.errorMessage,
  });
}

class LocationService {
  // Default regional coordinates (Thanjavur Delta Region)
  static const double defaultLat = 10.7867;
  static const double defaultLon = 79.1378;

  /// Acquire real device GPS location handling permissions gracefully
  static Future<UserLocationResult> getCurrentDeviceLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const UserLocationResult(
          latitude: defaultLat,
          longitude: defaultLon,
          status: LocationStatus.serviceDisabled,
          isFallback: true,
          errorMessage: 'Location services are disabled on your device. Please turn on GPS.',
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const UserLocationResult(
            latitude: defaultLat,
            longitude: defaultLon,
            status: LocationStatus.denied,
            isFallback: true,
            errorMessage: 'Location permission was denied.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const UserLocationResult(
          latitude: defaultLat,
          longitude: defaultLon,
          status: LocationStatus.deniedForever,
          isFallback: true,
          errorMessage: 'Location permission is permanently denied in device settings.',
        );
      }

      // Obtain current position with high accuracy
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return UserLocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        status: LocationStatus.granted,
        isFallback: false,
      );
    } catch (e) {
      debugPrint('[LocationService] Location acquisition error: $e');
      return UserLocationResult(
        latitude: defaultLat,
        longitude: defaultLon,
        status: LocationStatus.error,
        isFallback: true,
        errorMessage: 'Unable to get GPS location: $e',
      );
    }
  }

  // Calculate distance in kilometers using Haversine formula
  static double calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    try {
      final meters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
      return meters / 1000.0;
    } catch (_) {
      const p = 0.017453292519943295;
      final a = 0.5 -
          cos((lat2 - lat1) * p) / 2 +
          cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
      return 12742 * asin(sqrt(a));
    }
  }

  static List<ProcurementCenter> sortCentresByNearest(
    List<ProcurementCenter> centres, {
    required double userLat,
    required double userLon,
  }) {
    final list = List<ProcurementCenter>.from(centres);
    list.sort((a, b) {
      final distA = calculateDistanceKm(userLat, userLon, a.latitude, a.longitude);
      final distB = calculateDistanceKm(userLat, userLon, b.latitude, b.longitude);
      return distA.compareTo(distB);
    });
    return list;
  }
}
