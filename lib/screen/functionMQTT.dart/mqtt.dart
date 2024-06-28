// mqtt.dart
import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class MqttHandler {
  // Constants for MQTT topics and client ID
  final String mqttServer = 'test.mosquitto.org';
  final String clientId = 'clientId-bzwIkQ3vF5';
  final String tempTopic = 'esp32/temp';
  final String humidityTopic = 'esp32/hum';
  final String ldrTopic = 'esp32/ldr';
  final String mqTopic = 'esp32/mq';
  final String soilTopic = 'esp32/soil';
  final String autoModeTopic = 'esp32/auto_mode';
  late FirebaseFirestore firestore;

  // MQTT client and StreamControllers for different sensor data
  late MqttServerClient client;
  final StreamController<double> _temperatureStreamController =
      StreamController<double>.broadcast();
  final StreamController<double> _humidityStreamController =
      StreamController<double>.broadcast();
  final StreamController<double> _ldrStreamController =
      StreamController<double>.broadcast();
  final StreamController<double> _mqStreamController =
      StreamController<double>.broadcast();
  final StreamController<double> _soilStreamController =
      StreamController<double>.broadcast();

  // Getter methods for sensor data streams
  Stream<double> get temperatureStream => _temperatureStreamController.stream;
  Stream<double> get humidityStream => _humidityStreamController.stream;
  Stream<double> get ldrStream => _ldrStreamController.stream;
  Stream<double> get mqStream => _mqStreamController.stream;
  Stream<double> get soilStream => _soilStreamController.stream;

  // Constructor: Initializes the MQTT client and sets up MQTT connection
  MqttHandler() {
    client = MqttServerClient(mqttServer, clientId);
    firestore = FirebaseFirestore.instance;

    _setupMqtt();
  }

  // Set up MQTT connection and subscriptions
  void _setupMqtt() async {
    client.logging(on: false);
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onUnsubscribed = onUnsubscribed;
    client.onSubscribed = onSubscribed;
    client.pongCallback = pong;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean() // Non persistent session for testing
        .withWillTopic('willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMess;

    try {
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTT client connected');
    } else {
      print(
          'ERROR: MQTT client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
    }
  }

  // Callback on successful MQTT connection
  void onConnected() {
    print('Connected');
    // Subscribe to different sensor topics
    client.subscribe(tempTopic, MqttQos.atLeastOnce);
    client.subscribe(humidityTopic, MqttQos.atLeastOnce);
    client.subscribe(ldrTopic, MqttQos.atLeastOnce);
    client.subscribe(mqTopic, MqttQos.atLeastOnce);
    client.subscribe(soilTopic, MqttQos.atLeastOnce);

    // Listen for incoming messages and handle them
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
      final String payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);
      final String topic = c[0].topic;
      handleMessage(topic, payload);
    });
  }

  // Callback on MQTT disconnection
  void onDisconnected() {
    print('Disconnected');
    // Handle disconnection
  }

  // Callback on unsubscribing from a topic
  void onUnsubscribed(String? topic) {
    print('Unsubscribed topic: $topic');
  }

  // Callback on subscribing to a topic
  void onSubscribed(String topic) {
    print('Subscribed topic: $topic');
  }

  // Pong callback
  void pong() {
    print('Ping response client callback invoked');
  }

  // Handle incoming MQTT messages based on topic
  void handleMessage(String topic, String payload) {
    double value = double.tryParse(payload) ?? 0.0;

    // Update respective StreamControllers based on topic
    if (topic == tempTopic) {
      _temperatureStreamController.add(value);
    }
    if (topic == humidityTopic) {
      _humidityStreamController.add(value);
    }
    if (topic == ldrTopic) {
      _ldrStreamController.add(value);
    }
    if (topic == mqTopic) {
      _mqStreamController.add(value);
    }
    if (topic == soilTopic) {
      _soilStreamController.add(value);
    }
  }

  void sendSensorValue(String topic, String value) {
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(value);
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    } else {
      print("MQTT is not connected. Cannot send message.");
    }
  }

  // Control relay by sending MQTT command
  void controlRelay(String topic, String command) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(command);
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
    } else {
      print("MQTT is not connected. Cannot send message.");
    }
  }

  // Send MQTT command for automatic mode
  void sendAutoModeCommand(String topic, String command) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(command);
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
    } else {
      print("MQTT is not connected. Cannot send message.");
    }
  }

  // Connect and subscribe to MQTT topics
  void connectAndSubscribe() {
    // No need to include additional logic here
  }

  // Callback for handling received temperature data
  void onTemperatureReceived(double value) {
    // Handle the received temperature data, if needed
  }

  // Callback for handling received humidity data
  void onHumidityReceived(double value) {
    // Handle the received humidity data, if needed
  }

  // Callback for handling received LDR data
  void onldrReceived(double value) {
    // Handle the received LDR data, if needed
  }

  // Callback for handling received MQ data
  void onmqReceived(double value) {
    // Handle the received MQ data, if needed
  }

  // Callback for handling received soil data
  void onsoilReceived(double value) {
    // Handle the received soil data, if needed
  }

  // Dispose of resources when no longer needed
  void dispose() {
    _temperatureStreamController.close();
    _humidityStreamController.close();
    _ldrStreamController.close();
    _mqStreamController.close();
    _soilStreamController.close();
    client.disconnect();
  }

  // Send relay command with optional retention
  void sendRelayCommand(String topic, String command,
      {required bool retained}) {}

  // Method to fetch user document ID based on email
  Future<String?> getUserDocId(String email) async {
    String? userId;
    try {
      QuerySnapshot snapshot = await firestore
          .collection('User')
          .where('email', isEqualTo: email)
          .get();
      if (snapshot.docs.isNotEmpty) {
        userId = snapshot.docs.first.id;
      }
    } catch (e) {
      print("Error fetching user doc ID: $e");
    }
    return userId;
  }

  // Method to fetch farm document IDs based on user document ID
  Future<List<String>> getFarmDocIds(String userDocId) async {
    List<String> farmDocIds = [];
    try {
      QuerySnapshot snapshot = await firestore
          .collection('farm')
          .where('userId', isEqualTo: userDocId)
          .get();
      if (snapshot.docs.isNotEmpty) {
        farmDocIds.addAll(snapshot.docs.map((doc) => doc.id));
      }
    } catch (e) {
      print("Error fetching farm doc IDs: $e");
    }
    return farmDocIds;
  }

  // Send sensor value to all farms associated with the user
  void sendSensorValueToUserFarms(
      String email, String topic, String value) async {
    String? userId = await getUserDocId(email);
    if (userId != null) {
      List<String> farmDocIds = await getFarmDocIds(userId);
      farmDocIds.forEach((farmDocId) {
        // Assuming environment collection exists under each farm document
        String environmentDocId =
            DateTime.now().toString(); // Generate a unique ID
        sendSensorValueToFarm(farmDocId, environmentDocId, topic, value);
      });
    } else {
      print("User not found with email: $email");
    }
  }

  // Send sensor value to a specific farm's environment collection
  void sendSensorValueToFarm(
      String farmDocId, String environmentDocId, String topic, String value) {
    String environmentCollectionPath = 'farm/$farmDocId/environment';
    firestore.collection(environmentCollectionPath).doc(environmentDocId).set({
      'topic': topic,
      'value': value,
      'timestamp': DateTime.now(),
    }).then((_) {
      print('Sensor value sent to farm $farmDocId successfully');
    }).catchError((error) {
      print('Error sending sensor value to farm $farmDocId: $error');
    });
  }
}
