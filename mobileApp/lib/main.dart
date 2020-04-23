import 'package:background_locator/background_locator.dart';
import 'package:covid_tracker/constant/keys.dart';
import 'package:covid_tracker/locator.dart';
import 'package:covid_tracker/screens/home/home_screen.dart';
import 'package:covid_tracker/services/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:covid_tracker/screens/intro_screens.dart';
import 'package:flutter_google_maps/flutter_google_maps.dart';




void main() async {
  GoogleMap.init('<GOOGLE_MAP_API>');
  WidgetsFlutterBinding.ensureInitialized();
  await BackgroundLocator.initialize();
  await setupLocator();
  runApp(MyApp());
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LocalStorageService _localStorageService = locator<LocalStorageService>();
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _localStorageService.settingsBox.watch(key: Keys.introWasShown).listen((event) {
      if(event.value) {
        _navigatorKey.currentState.pushAndRemoveUntil(HomeScreen.route(), (_) => false);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Covid Tracer',
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: OnBoardingPage(),//HomeScreen(),
      onGenerateRoute: (RouteSettings settings) {
        if (_localStorageService.settingsBox.get(Keys.introWasShown, defaultValue: false)) {
          return HomeScreen.route();
        } else {
          return OnBoardingPage.route();
        }
      },
    );
  }
}