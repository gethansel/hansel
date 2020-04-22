import 'package:covid_tracker/locator.dart';
import 'package:covid_tracker/services/api_client.dart';
import 'package:covid_tracker/services/local_storage_service.dart';
import 'package:device_info/device_info.dart';

const USER_ID_KEY = 'id';
const FCM_TOKEN = 'fcmToken';

class UserService {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  final LocalStorageService _localStorageService = locator<LocalStorageService>();
  final ApiClient _apiClient = locator<ApiClient>();
  String get userId => _localStorageService.settingsBox.get(USER_ID_KEY, defaultValue: null);

  Future updateUserToken(String token) async {
    return _createUser(token, existingUserId:userId);
  }

  Future _createUser(String fcmToken, { String existingUserId }) async {
    if (fcmToken == _localStorageService.settingsBox.get(FCM_TOKEN, defaultValue: '') &&
    existingUserId != null) {
      //FCM_TOKEN not changed
      return;
    }
    String urlEncodedToken = Uri.encodeQueryComponent(fcmToken);
    Map params = {
      'device_registration_token' : urlEncodedToken,
    };
    if (existingUserId != null){
      params['user_id'] = existingUserId;
    }

    try {
      var data = await _apiClient.post('createUser', {'content': 'empty'}, queryParameters: Map<String, dynamic>.from(params));
      print(data);
      return Future.wait([
        _localStorageService.settingsBox.put(USER_ID_KEY, '$data'),
        _localStorageService.settingsBox.put(FCM_TOKEN, fcmToken),
      ]);
    } catch (e) {
      print(e);
    }
  }

  Future<String> getUUID() async {
    IosDeviceInfo info = await _deviceInfoPlugin.iosInfo;
    String uuid = info.identifierForVendor;
    print('uudid $uuid');
    return uuid;
  }

}