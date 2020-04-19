import 'package:background_locator/location_dto.dart';
import 'package:test/test.dart';
import 'package:covid_tracker/services/location_service.dart';

void main() {
  group('Location Service', () {
    test('LocationService is running', () {
      final locator = LocationService();
      locator.initPlatformState();
      expect(locator.isRunning, true);
    });

    // test('LocationServices saves Location', (){
    //   LocationService.saveLocation(LocationDto );
    // });
  });
}