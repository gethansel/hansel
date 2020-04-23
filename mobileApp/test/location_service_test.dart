import 'package:background_locator/location_dto.dart';
import 'package:test/test.dart';
import 'package:covid_tracker/services/location_service.dart';

void main() {
  group('Location Service', () {
    test('LocationService is running', () {
      final locator = LocationService();
      locator.startLocator();
      expect(locator.isRunning, true);
    });
  });
}