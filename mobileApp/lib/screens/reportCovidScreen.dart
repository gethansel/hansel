import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportCovidDiagnosis extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.grey),
                title: Text(
          'Hansel',
          style: GoogleFonts.milonga(
              textStyle: TextStyle(fontSize: 40, color: Colors.green[700])),
        ),
        backgroundColor: Colors.white,

      ),
      body: ReportCovidForm(),
    );
  }
}

// Create a Form widget.
class ReportCovidForm extends StatefulWidget {
  @override
  ReportCovidFormState createState() {
    return ReportCovidFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class ReportCovidFormState extends State<ReportCovidForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  final _textEditingControllerSymptoms = TextEditingController();
  final _textEditingControllerDiagnosis = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _textEditingControllerSymptoms.dispose();
    _textEditingControllerDiagnosis.dispose();
    super.dispose();
  }

  DateTime _diagnosisDate;
  DateTime _symptomStartDate;

  void _onPressedSymptomsStartDate() {
    showDatePicker(
            context: context,
            initialDate:
                _symptomStartDate == null ? DateTime.now() : _symptomStartDate,
            firstDate: DateTime(2020),
            lastDate: DateTime.now())
        .then((date) {
      setState(() {
        _symptomStartDate = date;
        _symptomStartDate == null
            ? _textEditingControllerSymptoms.text = ''
            : _textEditingControllerSymptoms.text =
                DateFormat.yMMMd().format(_symptomStartDate);
      });
    });
  }

  void _onPressedDiagnosisDate() {
    showDatePicker(
            context: context,
            initialDate:
                _diagnosisDate == null ? DateTime.now() : _diagnosisDate,
            firstDate: DateTime(2020),
            lastDate: DateTime.now())
        .then((date) {
      setState(() {
        _diagnosisDate = date;
        _diagnosisDate == null
            ? _textEditingControllerDiagnosis.text = ''
            : _textEditingControllerDiagnosis.text =
                DateFormat.yMMMd().format(_diagnosisDate);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              InkWell(
                onTap: () {
                  _onPressedDiagnosisDate();
                },
                child: IgnorePointer(
                  child: TextFormField(
                    controller: _textEditingControllerDiagnosis,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.local_hospital),
                      hintText: 'What day did you take the positive test?',
                      labelText: 'Diagnosis Date (Date Tested)',
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  _onPressedSymptomsStartDate();
                },
                child: IgnorePointer(
                  child: TextFormField(
                    controller: _textEditingControllerSymptoms,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.sentiment_dissatisfied),
                      hintText: '',
                      labelText: 'Symptoms Onset (Optional)',
                    ),
                  ),
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.email),
                  hintText: 'e.g. jill@gmail.com',
                  labelText: 'Email (Optional)',
                ),
                onSaved: (String value) {
                  // This optional block of code can be used to run
                  // code when the user saves the form.
                },
                validator: (String value) {
                  return value.contains('@') ? 'Do not use the @ char.' : null;
                },
              ),
              TextFormField(
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  icon: Icon(Icons.phone_iphone),
                  hintText: '(123) 456 - 7890',
                  labelText: 'Phone Number (Optional)',
                ),
                onSaved: (String value) {
                  // This optional block of code can be used to run
                  // code when the user saves the form.
                },
                validator: (String value) {
                  return value.contains('@') ? 'Do not use the @ char.' : null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: 
                SizedBox(width: double.infinity,
                          height: 50.0,
                                  child: RaisedButton.icon(
                    icon: Icon(Icons.local_pharmacy),
                    onPressed: () {Navigator.pop(context);},
                    label: Text('Submit'),
                    color: Colors.redAccent,
                    

                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
