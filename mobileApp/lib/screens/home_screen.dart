import 'package:covid_tracker/locator.dart';
import 'package:covid_tracker/services/local_storage_service.dart';
import 'package:covid_tracker/services/location_service.dart';
import 'package:covid_tracker/services/user_service.dart';
import 'package:covid_tracker/utils/fade_transition.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:covid_tracker/screens/reportCovidScreen.dart';
import 'package:covid_tracker/screens/intro_screens.dart';
import 'package:flutter_google_maps/flutter_google_maps.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:covid_tracker/services/exposure_service.dart';

GlobalKey<GoogleMapStateBase> _key = GlobalKey<GoogleMapStateBase>();

class HomeScreen extends StatefulWidget {
  static Route<dynamic> route() {
    return FadeRoute(page: HomeScreen());
  }

  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final LocationPermissions _locationPermissions = LocationPermissions();
  final LocationService _locationService = LocationService();
  final ExposureService _exposureService = ExposureService();
  final LocalStorageService _localStorageService = locator<LocalStorageService>();
  final UserService _userService = locator<UserService>();

  String _mapsStyle;
  PermissionStatus _permission = PermissionStatus.unknown;
  AppLifecycleState _currentAppstate = AppLifecycleState.resumed;

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    rootBundle.loadString('assets/styles/maps.json').then((string) {
      _mapsStyle = string;
      setState(() {});
    });

    WidgetsBinding.instance.addObserver(this);
    Future.delayed(
        Duration(milliseconds: 300), () => _checkLocationPermission());
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      // onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });

    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      _userService.updateUserToken(token);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed &&
        _currentAppstate != AppLifecycleState.resumed) {
      _checkLocationPermission();
    }
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.resumed) {
      _currentAppstate = state;
    }
  }

  _checkLocationPermission() async {
    _permission = await LocationPermissions()
        .checkPermissionStatus(level: LocationPermissionLevel.locationAlways);
    if (_permission == PermissionStatus.unknown) {
      _permission = await _locationPermissions.requestPermissions(
        permissionLevel: LocationPermissionLevel.locationAlways,
      );
      if (_permission == PermissionStatus.granted) {
        _locationService.startLocator();
      } else {
        _locationService.stopLocator();
        _alertLocationAccessNeeded();
      }
    } else if (_permission == PermissionStatus.granted) {
      _locationService.startLocator();
    } else {
      _locationService.stopLocator();
      _alertLocationAccessNeeded();
    }
    setState(() {});
  }

  void _addExposureMarkers() async {
    // AARON NOTES
    // Read markers from database
    // I's want this to be called on startup, have bound it to the ListTile for easy debug.
    // Opening a second box causes everything to break
    // Box box = await Hive.openBox('locationBox');
    var exposures =  _localStorageService.exposuresBox.keys;
    exposures.forEach((exposure) async{
      var exposureDetails = await _localStorageService.exposuresBox.get(exposure);
      print(exposureDetails);
      int recordId = exposureDetails.recordId;
      print(recordId.toString());
      // var locationDetails = await box.get(recordId);
      // print(locationDetails);
      // double lat = locationDetails.latitude;
      // double lng = locationDetails.longitude;
      // DateTime start = locationDetails.start;
      // DateTime end = locationDetails.end;
      bool dimissed = exposureDetails.dismissed;
      // AARON NOTES
      // color the marker according to the spec.
      // GoogleMap.of(_key).addMarker(
      //   // GeoCoord(lat, lng),
      //   GeoCoord(lat, lng),
      //   info: recordId.toString()
      // );

    });
  }

  Future<void> _alertLocationAccessNeeded() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Please Enable Always Access'),
          content: Text(
              'We need access to your location so we can warn you of possible exposure. Your location will never leave your device.\n\nPlease Tap Settings (below), then Location, and then Always'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Not Now'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text('Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                LocationPermissions().openAppSettings();
                //Should then recheck access after returning to the app
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hansel',
          style: GoogleFonts.milonga(
              textStyle: TextStyle(fontSize: 40, color: Colors.green[700])),
        ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.grey),
            onPressed: () => Navigator.push(context, OnBoardingPage.route()),
          ),
        ],
        leading: Container(),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          if (_permission != PermissionStatus.granted) ...[
            SizedBox(height: 30),
            Text(
                'We need access to your location so we can warn you of possible exposure. Your location will never leave your device.'),
            RaisedButton(
              onPressed: () => LocationPermissions().openAppSettings(),
              child: Text('Open settings', style: TextStyle(fontSize: 24)),
            ),
            SizedBox(height: 20),
          ],
          GoogleMap(
            key: _key,
            mapStyle: _mapsStyle,
            mobilePreferences: MobileMapPreferences(
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                padding: EdgeInsets.only(bottom: 40)),
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Card(
              elevation: 5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.home,
                        size: 50, color: Color.fromARGB(255, 56, 142, 60)),
                    title: Text('Local Guidance'),
                    subtitle: Text('Stay at home. Social Distance.'),
                    onTap: (){_addExposureMarkers();},
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 15,
            right: 15,
            child: Opacity(
              opacity: .9,
              child: Row(children: [
                Expanded(
                  child: RaisedButton(
                      onPressed: () {
                        // AARON NOTES
                        // I've bound this to Report Case for easy debugging.
                        // This should be called in the background on startup.
                        _exposureService.getContactLocations();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReportCovidDiagnosis()),
                        );
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(color: Colors.red)),
                      textColor: Colors.white,
                      color: Colors.red,
                      padding: EdgeInsets.all(5),
                      elevation: 5,
                      child: Column(
                        children: <Widget>[
                          Icon(Icons.report_problem, color: Colors.white),
                          Text('Report Case',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                        ],
                      )),
                ),
                Padding(padding: EdgeInsets.all(10)),
                Expanded(
                  child: StreamBuilder(
                      initialData: false,
                      stream: _locationService.stateStream,
                      builder: (context, snapshot) {
                        bool isTracing = snapshot.data;
                        Color textColor =
                            isTracing ? Colors.grey : Colors.white;
                        return RaisedButton(
                            onPressed: () {
                              if (isTracing) {
                                _locationService.stopLocator();
                              } else {
                                _checkLocationPermission();
                              }
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(color: textColor)),
                            textColor: textColor,
                            color: isTracing ? Colors.white : Colors.green,
                            padding: const EdgeInsets.all(5),
                            elevation: 5,
                            child: Column(
                              children: <Widget>[
                                Icon(isTracing
                                    ? Icons.gps_off
                                    : Icons.gps_fixed),
                                Text(
                                    isTracing
                                        ? 'Stop Tracing'
                                        : 'Start Tracing',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16)),
                              ],
                            ));
                      }),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
