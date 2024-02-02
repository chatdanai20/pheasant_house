import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class TimePickerWidget extends StatefulWidget {
  const TimePickerWidget({super.key});

  @override
  _TimePickerWidgetState createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  int _currentHourValue = 00;
  int _currentMinuteValue = 00;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        NumberPicker(
          value: _currentHourValue,
          minValue: 00,
          maxValue: 23,
          onChanged: (newValue) => setState(() => _currentHourValue = newValue),
        ),
        const Text(':', style: TextStyle(fontSize: 20)),
        NumberPicker(
          value: _currentMinuteValue,
          minValue: 00,
          maxValue: 59,
          onChanged: (newValue) =>
              setState(() => _currentMinuteValue = newValue),
        ),
      ],
    );
  }
}
