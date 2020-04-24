import 'dart:math';
import 'package:flutter_google_maps/flutter_google_maps.dart';

const double earthRadius = 6378137;
const double MINLAT = -90;
const double MAXLAT = 90;
const double MINLON = -180;
const double MAXLON = 180;

double toRad(double value) => (value * pi) / 180;
double toDeg(double value) => (value * 180) / pi;

GeoCoordBounds getBoundsOfDistance(double lat, double lng, double distance, { bool center = true }) {
  double radLat = toRad(lat);
  double radLon = toRad(lng);
  double radDist = distance / earthRadius;
  double minLat = radLat - radDist;
  double maxLat = radLat + radDist;

  final maxLatRad = toRad(MAXLAT);
  final minLatRad = toRad(MINLAT);
  final maxLonRad = toRad(MAXLON);
  final minLonRad = toRad(MINLON);

  var minLon;
  var maxLon;

  if (minLat > minLatRad && maxLat < maxLatRad) {
      final deltaLon = asin(sin(radDist) / cos(radLat));
      minLon = radLon - deltaLon;

      if (minLon < minLonRad) {
          minLon += pi * 2;
      }

      maxLon = radLon + deltaLon;

      if (maxLon > maxLonRad) {
          maxLon -= pi * 2;
      }
  } else {
      // A pole is within the distance.
      minLat = max(minLat, minLatRad);
      maxLat = min(maxLat, maxLatRad);
      minLon = minLonRad;
      maxLon = maxLonRad;
  }
  if (center) {
    return GeoCoordBounds(
      northeast: GeoCoord(toDeg(maxLat), toDeg(maxLon)),
      southwest: GeoCoord(toDeg(minLat), toDeg(minLon)),
    );
  }
  return GeoCoordBounds(
    northeast: GeoCoord(toDeg(maxLat + radDist * 3), toDeg(maxLon)),
    southwest: GeoCoord(toDeg(minLat), toDeg(minLon)),
  );
}