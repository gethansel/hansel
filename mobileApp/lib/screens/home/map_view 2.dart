import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_maps/flutter_google_maps.dart';

class MapView extends StatelessWidget {
  final Key mapkey;
  const MapView({this.mapkey});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: rootBundle.loadString('assets/styles/maps.json'),
      initialData: null,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return GoogleMap(
          key: mapkey,
          mapStyle: snapshot.data,
          mobilePreferences: MobileMapPreferences(
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              padding: EdgeInsets.only(bottom: 40)),
        );
      },
    );
  }
}