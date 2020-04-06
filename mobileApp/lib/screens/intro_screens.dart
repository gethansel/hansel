import 'package:covid_tracker/constant/keys.dart';
import 'package:covid_tracker/locator.dart';
import 'package:covid_tracker/services/local_storage_service.dart';
import 'package:covid_tracker/utils/fade_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnBoardingPage extends StatefulWidget {
  static Route<dynamic> route() {
    return FadeRoute(page: OnBoardingPage());
  }
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();
  final LocalStorageService _localStorageService = locator<LocalStorageService>();

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(14.0, 0.0, 14.0, 14.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      pages: [
        PageViewModel(
          title: "Thank You!",
          body:
              "By simply using Hansel, you are helping to slow the spread of Covid-19",
          image: const Center(
              child: Icon(Icons.local_hospital, size: 200, color: Colors.red)),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Privacy First",
          body:
              "Your location data never leaves your phone. \n\nWe use a privacy preserving algorithm to contact trace without centrally storing your location.",
          image: const Center(
              child: Icon(Icons.cloud_off, size: 200, color: Colors.blueGrey)),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Permissions",
          body: "We will be asking for your permission to access your location. We need this to enable contact tracing. \n\nPlease accept the following prompt." +
              "\n\nDon't worry if you accidentally deny, we'll remind you 😀",
          image: const Center(child: Icon(Icons.location_on, size: 200)),
          decoration: pageDecoration,
        ),
      ],
      onDone: () async {
        await _localStorageService.settingsBox.put(Keys.introWasShown, true);
      },
      // onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      skipFlex: 0,
      nextFlex: 0,
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Start Tracing',
          style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
