import 'package:covid_tracker/locator.dart';
import 'package:covid_tracker/model/exposure_event.dart';
import 'package:covid_tracker/services/exposure_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

typedef OnExposureTap = void Function(ExposureEvent exposure);
typedef OnTap = void Function();

final ExposureService _exposureService = locator<ExposureService>();

class TopBanner extends StatelessWidget {
  final OnExposureTap onExposureTap;
  final OnTap onTap;

  const TopBanner({
    @required this.onExposureTap,
    @required  this.onTap,
    Key key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child:ValueListenableBuilder<Box>(
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
              onTap: () => onExposureTap(exposures.firstWhere((e) => !e.dismissed)),
            );
          }
          return ListTile(
            leading: Icon(Icons.home,
                size: 50, color: Color.fromARGB(255, 56, 142, 60)),
            title: Text('Local Guidance'),
            subtitle: Text('Stay at home. Social Distance.'),
            onTap: () => onTap(),
          );
        }
      )
    );
  }
}