import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class LocationService {
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition();
  }

  Future<Map<String, String>?> getAddressFromLatLng(Position position) async {
    try {
      if (kIsWeb) {
        // geocoding package doesn't support Web. Use Nominatim API (OpenStreetMap)
        final dio = Dio();
        final response = await dio.get(
          'https://nominatim.openstreetmap.org/reverse',
          queryParameters: {
            'format': 'jsonv2',
            'lat': position.latitude,
            'lon': position.longitude,
          },
          options: Options(
            headers: {
              'User-Agent': 'MeetraMeetApp/1.0', // Required by Nominatim policy
            },
          ),
        );

        if (response.statusCode == 200) {
          final data = response.data;
          final address = data['address'] as Map<String, dynamic>;
          return {
            'city': address['city'] ?? address['town'] ?? address['village'] ?? address['suburb'] ?? '',
            'state': address['state'] ?? '',
            'country': address['country'] ?? '',
          };
        }
        return null;
      } else {
        // Mobile support via geocoding package
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isEmpty) return null;
        Placemark place = placemarks[0];
        return {
          'city': place.locality ?? '',
          'state': place.administrativeArea ?? '',
          'country': place.country ?? '',
        };
      }
    } catch (e) {
      print('Geocoding error: $e');
      return null;
    }
  }
}
