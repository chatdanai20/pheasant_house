import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'mqtt.dart'; // Import your MqttHandler class

class SensorDataScreen extends StatefulWidget {
  @override
  _SensorDataScreenState createState() => _SensorDataScreenState();
}

class _SensorDataScreenState extends State<SensorDataScreen> {
  MqttHandler mqttHandler = MqttHandler(); // Initialize your MqttHandler instance

  @override
  void initState() {
    super.initState();
    // Connect and subscribe to MQTT topics when screen initializes
    mqttHandler.connectAndSubscribe();
  }

  @override
  void dispose() {
    super.dispose();
    mqttHandler.dispose(); // Dispose MQTT connections when screen is disposed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensor Data'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<double>(
              stream: mqttHandler.temperatureStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  double temperature = snapshot.data!;
                  return Text('Temperature: $temperature');
                } else {
                  return Text('Waiting for temperature data...');
                }
              },
            ),
            StreamBuilder<double>(
              stream: mqttHandler.humidityStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  double humidity = snapshot.data!;
                  return Text('Humidity: $humidity');
                } else {
                  return Text('Waiting for humidity data...');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
