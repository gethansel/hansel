import 'package:covid_tracker/services/api_client.dart';
import 'package:covid_tracker/services/local_storage_service.dart';
import 'package:covid_tracker/services/user_service.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

Future setupLocator() async {
  locator.registerLazySingleton(() => ApiClient());
  locator.registerLazySingleton(() => UserService());
  return await initializeServices();
}

Future<void> initializeServices() async {
  final localStorageServiceInstance = await LocalStorageService.getInstance();
  locator.registerSingleton<LocalStorageService>(localStorageServiceInstance);
}
