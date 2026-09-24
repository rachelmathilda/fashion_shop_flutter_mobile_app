import 'package:geolocator/geolocator.dart';

class StoreLocation {
  static const double lat = -6.2088;
  static const double lng = 106.8456;
}

num calculateDeliveryFee(double destLat, double destLng) {
  final distanceMeters = Geolocator.distanceBetween(
    StoreLocation.lat,
    StoreLocation.lng,
    destLat,
    destLng,
  );
  final km = distanceMeters / 1000;
  final fee = 5 + (km * 0.5);
  return fee.clamp(5, 50).roundToDouble();
}
