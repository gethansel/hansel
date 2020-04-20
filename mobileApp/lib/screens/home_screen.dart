import 'package:covid_tracker/locator.dart';
import 'package:covid_tracker/model/exposure_event.dart';
import 'package:covid_tracker/model/location_event.dart';
import 'package:covid_tracker/services/local_storage_service.dart';
import 'package:covid_tracker/services/location_service.dart';
import 'package:covid_tracker/services/user_service.dart';
import 'package:covid_tracker/utils/fade_transition.dart';
import 'package:covid_tracker/utils/geocoordinates.dart';
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
import 'package:location/location.dart' hide PermissionStatus;

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
  final UserService _userService = locator<UserService>();
  final LocalStorageService _localStorageService = locator<LocalStorageService>();

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
      Duration(milliseconds: 300),
      () {
          _addExposureMarkers(_exposureService.exposures);
          _checkLocationPermission(initialRequest: true);
        }
    );
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

    _firebaseMessaging.getToken().then((String token) async {
      assert(token != null);
      try {
        await _userService.updateUserToken(token);
        _checkExposureEvents();
      } catch (e) {
        print('update token error: $e');
      }
    });
    _checkExposureEvents();
    _exposureService.exposuresStream.listen((e) {
      _addExposureMarkers(_exposureService.exposures);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed &&
        _currentAppstate != AppLifecycleState.resumed) {
      _checkLocationPermission();
      _checkExposureEvents();
    }
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.resumed) {
      _currentAppstate = state;
    }
  }

  _checkExposureEvents() async {
    if (_userService.userId != null) {
      _exposureService.getContactLocations();
    }
  }

  _checkLocationPermission({bool initialRequest = false}) async {
    _permission = await LocationPermissions()
        .checkPermissionStatus(level: LocationPermissionLevel.locationAlways);
    if (_permission == PermissionStatus.unknown) {
      _permission = await _locationPermissions.requestPermissions(
        permissionLevel: LocationPermissionLevel.locationAlways,
      );
      if (_permission == PermissionStatus.granted) {
        if (initialRequest) {
          _showCurrentLocation();
        }
        _locationService.startLocator();
      } else {
        _locationService.stopLocator();
        _alertLocationAccessNeeded();
      }
    } else if (_permission == PermissionStatus.granted) {
      _locationService.startLocator();
      if (initialRequest) {
        _showCurrentLocation();
      }
    } else {
      _locationService.stopLocator();
      _alertLocationAccessNeeded();
    }
    setState(() {});
  }

  _showCurrentLocation() async {
    LocationData locationData = await Location().getLocation();
    GoogleMap.of(_key).moveCamera(
      getBoundsOfDistance(locationData.latitude, locationData.longitude, 500)
    );
  }

  void _addExposureMarkers(List<ExposureEvent> exposures) async {
    GoogleMap.of(_key).clearMarkers();
    exposures.forEach((exposure) {
      LocationEvent locationDetails = _localStorageService.locationsBox.get(exposure.recordId);
      double lat = locationDetails.latitude;
      double lng = locationDetails.longitude;
      bool dimissed = exposure.dismissed;
      // AARON NOTES
      // color the marker according to the spec.
      GoogleMap.of(_key).addMarker(
        GeoCoord(lat, lng),
        icon: dimissed ? 'assets/exposureMarkerDismissed' : 'assets/exposureMarker',
        onTap: () {
          _showExposureAlert(exposure);
        },
      );
    });
  }

  _showExposureAlert(ExposureEvent exposureEvent) {
    LocationEvent location = _localStorageService.locationsBox.get(exposureEvent.recordId);
    GoogleMap.of(_key).moveCamera(getBoundsOfDistance(location.latitude, location.longitude, 150));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Date: ${exposureEvent.formattedStartDate}'),
              Text('Time: ${exposureEvent.formattedStartTime}'),
              Text('Duration: ${exposureEvent.timeSpent.inMinutes} min'),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      exposureEvent.dismissed = true;
                      exposureEvent.save();
                      Navigator.of(context).pop();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.black12)
                    ),
                    textColor: Colors.black,
                    color: Colors.white,
                    elevation: 0,
                    child: Text('Dismiss'),
                  ),
                  RaisedButton(
                    onPressed: () {},
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.black12)
                    ),
                    textColor: Colors.black,
                    color: Colors.white,
                    elevation: 0,
                    child: Text('Get Tested'),
                  ),
                ],
              )
            ],
          ),
        );
      }
    );
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
        centerTitle: true,
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
              child: ValueListenableBuilder<Box>(
                valueListenable: _exposureService.exposureValueListenable,
                builder: (context, box, child) {
                  List<ExposureEvent> exposures = _exposureService.exposures;
                  if (exposures.any((e) => !e.dismissed)) {
                    return ListTile(
                      isThreeLine: true,
                      leading: Icon(Icons.person,
                          size: 50, color: Colors.red),
                      title: Text('Positive COVID-19 Exposure'),
                      subtitle: Text('Self isolate + Get Tested\nTap to review & get tested'),
                      onTap: () {
                        _showExposureAlert(exposures.firstWhere((e) => !e.dismissed));
                      },
                    );
                  }
                  return ListTile(
                    leading: Icon(Icons.home,
                        size: 50, color: Color.fromARGB(255, 56, 142, 60)),
                    title: Text('Local Guidance'),
                    subtitle: Text('Stay at home. Social Distance.'),
                    onTap: (){},
                  );
                }
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
