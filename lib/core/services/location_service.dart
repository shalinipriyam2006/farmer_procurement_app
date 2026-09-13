import 'dart:math';
import 'package:farmer_procurement_app/core/models/procurement_center.dart';

class LocationService {
  // Calculate distance in kilometers using Haversine formula
  static double calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  static List<ProcurementCenter> sortCentresByNearest(
    List<ProcurementCenter> centres, {
    double userLat = 10.7867, // Thanjavur default
    double userLon = 79.1378,
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
