import 'package:covid_tracker/locator.dart';
import 'package:covid_tracker/services/location_service.dart';
import 'package:covid_tracker/services/user_service.dart';
import 'package:covid_tracker/utils/fade_transition.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:covid_tracker/screens/reportCovidScreen.dart';
import 'package:covid_tracker/screens/intro_screens.dart';

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
  final UserService _userService = locator<UserService>();

  PermissionStatus _permission = PermissionStatus.unknown;
  AppLifecycleState _currentAppstate = AppLifecycleState.resumed;

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

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
  void didChangeAppLifecycleState(AppLifecycleState state) {
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
        // _startLocator();
        PermissionStatus status =
            await _locationPermissions.checkPermissionStatus(
                level: LocationPermissionLevel.locationAlways);
        print('Start locator $_permission $status');
        _locationService.startLocator();
      } else {
        _alertLocationAccessNeeded();
      }
    } else if (_permission == PermissionStatus.granted) {
      _locationService.startLocator();
    } else {
      _alertLocationAccessNeeded();
    }
    setState(() {});
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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/map_placeholder.png"),
            fit: BoxFit.cover,
          ),
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.fromLTRB(15, 10, 15, 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
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
            Align(
              alignment: Alignment.topCenter,
              child: Card(
                elevation: 5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const ListTile(
                      leading: Icon(Icons.home, size: 50, color: Color.fromARGB(255, 56, 142, 60)),
                      title: Text('Local Guidance'),
                      subtitle: Text('Stay at home. Social Distance.'),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Opacity(
                opacity: .9,
                child: Row(children: [
                  Expanded(
                    child: RaisedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ReportCovidDiagnosis()),
                          );
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0),
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
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
                          ],
                        )),
                  ),
                  Padding(padding: EdgeInsets.all(10)),
                  Expanded(
                    // This should switch between strat tracing and stop tracing. If we don't have permissions or the
                    // user has chosen to stop tracing, this should be green and say Start Tracing. Tapping would
                    // start the listener service and raise the permissions alert workflow if needed. If we are tracing,
                    // This should say stop tracing and tapping would stop the locaiton listener service.
                    child: RaisedButton(
                        onPressed: () {},
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0),
                            side: BorderSide(color: Colors.grey)),
                        textColor: Colors.grey,
                        color: Colors.white,
                        padding: EdgeInsets.all(5),
                        elevation: 5,
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.gps_off),
                            Text('Stop Tracing',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16)),
                          ],
                        )),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
