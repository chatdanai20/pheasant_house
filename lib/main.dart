import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pheasant_house/constants.dart';
import 'package:pheasant_house/screen/welcome/welcome.dart';
import 'package:pheasant_house/screen/functionMQTT.dart/mqtt.dart';

void main() {
  // Initialize date formatting once
  initializeDateFormatting().then((_) {
    // Start the Flutter application
    runApp(const MyApp());
    // Initialize and listen to MQTT
    MqttHandler mqttHandler = MqttHandler();
    mqttHandler.temperatureStream.listen((double tempValue) {
      print('Temperature received: $tempValue');
      // Further processing based on temperature value can be done here
    });

    // Ensure to dispose the mqttHandler when done to release resources
    // mqttHandler.dispose();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.promptTextTheme(),
        scaffoldBackgroundColor: kDefaultColor,
      ),
      home: const Welcomescreen(),
    );
  }
}
