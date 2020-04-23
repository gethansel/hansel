import 'package:covid_tracker/services/api_client.dart';
import 'package:covid_tracker/services/exposure_service.dart';
import 'package:covid_tracker/services/local_storage_service.dart';
import 'package:covid_tracker/services/location_permission_service.dart';
import 'package:covid_tracker/services/user_service.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

Future setupLocator() async {
  locator.registerLazySingleton(() => ApiClient());
  locator.registerLazySingleton(() => UserService());
  locator.registerLazySingleton(() => ExposureService());
  locator.registerLazySingleton(() => LocationPermissionService());
  return await initializeServices();
}

Future<void> initializeServices() async {
  final localStorageServiceInstance = await LocalStorageService.getInstance();
  locator.registerSingleton<LocalStorageService>(localStorageServiceInstance);
}
