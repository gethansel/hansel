import 'package:covid_tracker/locator.dart';
import 'package:covid_tracker/model/exposure_event.dart';
import 'package:covid_tracker/model/location_event.dart';
import 'package:covid_tracker/screens/home/map_view.dart';
import 'package:covid_tracker/screens/home/top_banner.dart';
import 'package:covid_tracker/services/local_storage_service.dart';
import 'package:covid_tracker/services/location_permission_service.dart';
import 'package:covid_tracker/services/location_service.dart';
import 'package:covid_tracker/services/user_service.dart';
import 'package:covid_tracker/utils/fade_transition.dart';
import 'package:covid_tracker/utils/geocoordinates.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:covid_tracker/screens/reportCovidScreen.dart';
import 'package:covid_tracker/screens/intro_screens.dart';
import 'package:flutter_google_maps/flutter_google_maps.dart';
import 'package:covid_tracker/services/exposure_service.dart';
import 'package:location/location.dart' hide PermissionStatus;
import 'package:url_launcher/url_launcher.dart';

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
  final LocationService _locationService = LocationService();
  final ExposureService _exposureService = locator<ExposureService>();
  final UserService _userService = locator<UserService>();
  final LocalStorageService _localStorageService = locator<LocalStorageService>();
  final LocationPermissionService _locationPermissionService = locator<LocationPermissionService>();

  AppLifecycleState _currentAppstate = AppLifecycleState.resumed;

  void dispose() {
    _locationPermissionService.closeStream();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    Future.delayed(
      Duration(milliseconds: 300),
      () async {
          bool allowed = await _locationPermissionService.checkPermission();
          if (allowed) {
            _showCurrentLocation();
          }
          _addExposureMarkers(_exposureService.exposures);
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

    _locationPermissionService.onPermissionChanged.listen((data) {
      if (data) {
         _locationService.startLocator();
      } else {
        _locationService.stopLocator();
        _alertLocationAccessNeeded();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed &&
        _currentAppstate != AppLifecycleState.resumed) {
      _locationPermissionService.checkPermission();
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
    GoogleMap.of(_key).moveCamera(getBoundsOfDistance(location.latitude, location.longitude, 150, center: false));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Possible Exposure', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              SizedBox(height: 10),
              Text(
                'You might have been exposed to someone who has COVID-19.\nYou can view the details of your interaction below.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Date:'),
                        Text(exposureEvent.formattedStartDate),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Time:'),
                        Text(exposureEvent.formattedStartTime),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Duration:'),
                        Text('${exposureEvent.timeSpent.inMinutes} min'),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      exposureEvent.dismissed = true;
                      _localStorageService.exposuresBox.put(exposureEvent.recordId.toString(), exposureEvent);
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
                    onPressed: () {
                      Navigator.of(context).pop();
                      _launchURL();
                    },
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

  _launchURL() async {
    const url = 'https://gethansel.org';
    if (await canLaunch(url)) {
      await launch(url);
    }
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
          MapView(mapkey: _key),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: TopBanner(
              onExposureTap: (e) => _showExposureAlert(e),
              onTap: () {},
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
                                _locationPermissionService.checkPermission();
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
