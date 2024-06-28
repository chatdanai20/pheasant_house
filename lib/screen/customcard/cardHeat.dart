import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pheasant_house/constants.dart';
import 'package:pheasant_house/screen/functionMQTT.dart/mqtt.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardHeat extends StatefulWidget {
  final String farmName;
  final String userEmail;
  const CardHeat({Key? key, required this.farmName, required this.userEmail})
      : super(key: key);
  @override
  _CardHeatState createState() => _CardHeatState();
}

class ControlStatus {
  bool isOpen;
  bool isAuto;
  bool isAutoMode;

  ControlStatus({
    required this.isOpen,
    required this.isAuto,
    required this.isAutoMode,
  });
  void updateStatus(Map<String, dynamic> data) {
    if (data.containsKey('isOpen')) {
      isOpen = data['isOpen'];
    }
    if (data.containsKey('isAuto')) {
      isAuto = data['isAuto'];
    }
    if (data.containsKey('isAutoMode')) {
      isAutoMode = data['isAutoMode'];
    }
  }
}

class _CardHeatState extends State<CardHeat> {
  final MqttHandler mqttHandler = MqttHandler();
  bool isOpen = false;
  bool isAuto = false;
  bool isAutoMode = false;
  int selectedOpenHour = 0;
  int selectedOpenMinute = 0;
  int selectedCloseHour = 0;
  bool status = false;
  int selectedCloseMinute = 0;
  String openingTimeMessage = '';
  String closingTimeMessage = '';
  TextEditingController sensorOpenController = TextEditingController();
  TextEditingController sensorCloseController = TextEditingController();

  String openSensor = '';
  String offSensor = '';
  String offtime = '';
  String ontime = '';

  @override
  void initState() {
    super.initState();

    // Subscribe to the LDR stream to get real-time updates
    mqttHandler.ldrStream.listen((double ldrValue) {
      setState(() {
        // Handle updates here if needed
      });
    });
    // Fetch initial data from Firestore
    statusControl((data) {
      setState(() {
        if (data != null && data.containsKey('isOpen')) {
          isOpen = data['isOpen'];
        }
      });
    });
    statusAutoMode((data) {
      setState(() {
        if (data != null && data.containsKey('isAuto')) {
          isOpen = data['isAuto'];
        }
      });
    });
    sensorMaxMin((data) {
      setState(() {
        if (data != null &&
            data.containsKey('openSensor') &&
            data.containsKey('offSensor')) {
          openSensor = data['openSensor'];
          offSensor = data['offSensor'];
        }
      });
    });
    timeOnOff((data) {
      setState(() {
        if (data != null &&
            data.containsKey('ontime') &&
            data.containsKey('offtime')) {
          ontime = data['ontime'];
          offtime = data['offtime'];
        }
      });
    });
  }

  void switchToManualMode() {
    setState(() {
      isAutoMode = false;
    });

    // Check if MQTT client is connected before sending the command
    if (mqttHandler.client.connectionStatus?.state ==
        MqttConnectionState.connected) {
      mqttHandler.sendAutoModeCommand('esp32/auto_mode', 'manual');
    }
  }

  void switchToAutoMode() {
    setState(() {
      isAutoMode = true;
    });

    // Check if MQTT client is connected before sending the command
    if (mqttHandler.client.connectionStatus?.state ==
        MqttConnectionState.connected) {
      mqttHandler.sendAutoModeCommand('esp32/auto_mode', 'auto');
    }
  }

  void turnOnRelay1() {
    if (mqttHandler.client.connectionStatus?.state ==
        MqttConnectionState.connected) {
      mqttHandler.controlRelay('esp32/relay1', 'on');
    }
  }

  void turnOffRelay1() {
    if (mqttHandler.client.connectionStatus?.state ==
        MqttConnectionState.connected) {
      mqttHandler.controlRelay('esp32/relay1', 'off');
    }
  }

  Future<void> updateContorlOn() async {
    await FirebaseFirestore.instance
        .collection('User')
        .doc(widget.userEmail)
        .collection('farm')
        .doc(widget.farmName)
        .collection('control')
        .doc('light')
        .update({'status': true});
  }

  Future<void> updateContorlOff() async {
    await FirebaseFirestore.instance
        .collection('User')
        .doc(widget.userEmail)
        .collection('farm')
        .doc(widget.farmName)
        .collection('control')
        .doc('light')
        .update({'status': false});
  }

  Future<void> statusControl(Function(Map<String, dynamic>?) callback) async {
    DocumentReference<Map<String, dynamic>> status = FirebaseFirestore.instance
        .collection('User')
        .doc(widget.userEmail)
        .collection('farm')
        .doc(widget.farmName)
        .collection('control')
        .doc('light');

    DocumentSnapshot<Map<String, dynamic>> querySnapshot = await status.get();
    bool lightstatus = querySnapshot.data()?['status'] ?? false;
    setState(() {
      isOpen = lightstatus;
    });
  }

  Future<void> autoModeOn() async {
    await FirebaseFirestore.instance
        .collection('User')
        .doc(widget.userEmail)
        .collection('farm')
        .doc(widget.farmName)
        .collection('control')
        .doc('Automode')
        .update({'status': true});
  }

  Future<void> autoModeOff() async {
    await FirebaseFirestore.instance
        .collection('User')
        .doc(widget.userEmail)
        .collection('farm')
        .doc(widget.farmName)
        .collection('control')
        .doc('Automode')
        .update({'status': false});
  }

  Future<void> statusAutoMode(Function(Map<String, dynamic>?) callback) async {
    DocumentReference<Map<String, dynamic>> status = FirebaseFirestore.instance
        .collection('User')
        .doc(widget.userEmail)
        .collection('farm')
        .doc(widget.farmName)
        .collection('control')
        .doc('Automode');

    DocumentSnapshot<Map<String, dynamic>> querySnapshot = await status.get();
    bool autoModeStatus = querySnapshot.data()?['status'] ?? false;
    setState(() {
      isAuto = autoModeStatus;
    });
  }

  Future<void> sensorMax(String sensorOpenToSend) async {
    await FirebaseFirestore.instance
        .collection('User')
        .doc(widget.userEmail)
        .collection('farm')
        .doc(widget.farmName)
        .collection('sensor')
        .doc('light_intensity')
        .update({'sensor_max': '${sensorOpenToSend}'});
  }

  Future<void> sensorMin(String sensorCloseToSend) async {
    await FirebaseFirestore.instance
        .collection('User')
        .doc(widget.userEmail)
        .collection('farm')
        .doc(widget.farmName)
        .collection('sensor')
        .doc('light_intensity')
        .update({'sensor_min': '${sensorCloseToSend}'});
  }

  Future<void> sensorMaxMin(Function(Map<String, dynamic>?) callback) async {
    DocumentReference<Map<String, dynamic>> status = FirebaseFirestore.instance
        .collection('User')
        .doc(widget.userEmail)
        .collection('farm')
        .doc(widget.farmName)
        .collection('sensor')
        .doc('light_intensity');

    DocumentSnapshot<Map<String, dynamic>> querySnapshot = await status.get();
    String open_Sensor = querySnapshot.data()?['sensor_max'] ?? null;
    String off_Sensor = querySnapshot.data()?['sensor_min'] ?? null;
    setState(() {
      openSensor = open_Sensor;
      offSensor = off_Sensor;
    });
  }

  Future<void> timeOn(String openingTimeToSend) async {
    await FirebaseFirestore.instance
        .collection('User')
        .doc(widget.userEmail)
        .collection('farm')
        .doc(widget.farmName)
        .collection('time')
        .doc('light')
        .update({'time_on': '${openingTimeToSend}'});
  }

  Future<void> timeOff(String closingTimeToSend) async {
    await FirebaseFirestore.instance
        .collection('User')
        .doc(widget.userEmail)
        .collection('farm')
        .doc(widget.farmName)
        .collection('time')
        .doc('light')
        .update({'time_off': '${closingTimeToSend}'});
  }

  Future<void> timeOnOff(Function(Map<String, dynamic>?) callback) async {
    
    DocumentReference<Map<String, dynamic>> status = FirebaseFirestore.instance
        .collection('User')
        .doc(widget.userEmail)
        .collection('farm')
        .doc(widget.farmName)
        .collection('time')
        .doc('light');

    DocumentSnapshot<Map<String, dynamic>> querySnapshot = await status.get();
    String time_on = querySnapshot.data()?['time_on'] ?? null;
    String time_off = querySnapshot.data()?['time_off'] ?? null;
    setState(() {
      ontime = time_on;
      offtime = time_off;
    });
  }

  @override
  void dispose() {
    // Dispose of the MqttHandler when the widget is disposed
    mqttHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.2,
      height: MediaQuery.of(context).size.height / 1.3,
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(80),
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 10),
          Image.asset(
              'asset/images/lamp.png'), // Adjust the asset path based on your project structure
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'สถานะ : ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                isOpen ? 'เปิด' : 'ปิด',
                style: TextStyle(
                  color: isOpen ? Colors.green : Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'เปิด/ปิด : ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Switch(
                activeColor: Colors.green,
                activeTrackColor: Colors.green[200],
                inactiveTrackColor: Colors.red[200],
                inactiveThumbColor: Colors.white,
                value: isOpen,
                onChanged: (value) {
                  setState(() {
                    isOpen = value;
                    if (isOpen) {
                      turnOnRelay1();
                      updateContorlOn();
                    } else {
                      turnOffRelay1();
                      updateContorlOff();
                    }
                  });
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'อัตโนมัติ : ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Switch(
                activeColor: Colors.green,
                activeTrackColor: Colors.green[200],
                inactiveTrackColor: Colors.red[200],
                inactiveThumbColor: Colors.white,
                value: isAuto,
                onChanged: (value) {
                  setState(() {
                    isAuto = value;
                    if (isAuto) {
                      switchToAutoMode();
                      autoModeOn();
                    } else {
                      switchToManualMode();
                      autoModeOff();
                    }
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 10),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Color(0xFF00BFA5)),
            ),
            child: Text(
              'ตั้งค่าการทำงานอัตโนมัติ',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      Widget buildPicker(int count, int selectedItem,
                          ValueChanged<int> onChanged) {
                        return Expanded(
                          child: CupertinoPicker(
                            itemExtent: 32,
                            scrollController: FixedExtentScrollController(
                                initialItem: selectedItem),
                            onSelectedItemChanged: onChanged,
                            children: List<Widget>.generate(
                              count,
                              (int index) => Text('$index'),
                            ),
                          ),
                        );
                      }

                      return SizedBox(
                        height: 500,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 6),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Color(0xFF6FC0C5)),
                                      ),
                                      child: Text(
                                        'กลับ',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Color(0xFF6FC0C5)),
                                      ),
                                      child: Text(
                                        'บันทึก',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          openingTimeMessage =
                                              '${selectedOpenHour}:${selectedOpenMinute}';
                                          closingTimeMessage =
                                              '${selectedCloseHour}:${selectedCloseMinute}';
                                        });

                                        String openingTimeToSend =
                                            selectedOpenHour != 0 ||
                                                    selectedOpenMinute != 0
                                                ? '${selectedOpenHour}:${selectedOpenMinute}'
                                                : 'null';
                                        timeOn(openingTimeToSend);

                                        String closingTimeToSend =
                                            selectedCloseHour != 0 ||
                                                    selectedCloseMinute != 0
                                                ? '${selectedCloseHour}:${selectedCloseMinute}'
                                                : 'null';
                                        timeOff(closingTimeToSend);

                                        String sensorOpenToSend =
                                            sensorOpenController.text.isNotEmpty
                                                ? sensorOpenController.text
                                                : 'null';
                                        sensorMax(sensorOpenToSend);

                                        String sensorCloseToSend =
                                            sensorCloseController
                                                    .text.isNotEmpty
                                                ? sensorCloseController.text
                                                : 'null';
                                        sensorMin(sensorCloseToSend);

                                        mqttHandler.sendSensorValue(
                                            'esp32/minldr', sensorOpenToSend);
                                        mqttHandler.sendSensorValue(
                                            'esp32/maxldr', sensorCloseToSend);
                                        mqttHandler.sendAutoModeCommand(
                                            'esp32/lighton', openingTimeToSend);
                                        mqttHandler.sendAutoModeCommand(
                                            'esp32/lightoff',
                                            closingTimeToSend);

                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              // String openSensor = '';
                              // String offSensor = '';
                              // String offtime = '';
                              // String ontime = '';
                              buildInputText('ค่าเซนเซอร์เปิด', 'lux',
                                  sensorOpenController),
                              buildInputText('ค่าเซนเซอร์ปิด', 'lux',
                                  sensorCloseController),
                              SizedBox(height: 10),
                              Text(
                                'เวลาเปิด',
                                style: TextStyle(
                                    color: Color(0xFF6FC0C5), fontSize: 16),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  buildPicker(
                                    24,
                                    selectedOpenHour,
                                    (int newVal) => setState(
                                        () => selectedOpenHour = newVal),
                                  ),
                                  buildPicker(
                                    60,
                                    selectedOpenMinute,
                                    (int newVal) => setState(
                                        () => selectedOpenMinute = newVal),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Text(
                                'เวลาปิด',
                                style: TextStyle(
                                    color: Color(0xFF6FC0C5), fontSize: 16),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  buildPicker(
                                    24,
                                    selectedCloseHour,
                                    (int newVal) => setState(
                                        () => selectedCloseHour = newVal),
                                  ),
                                  buildPicker(
                                    60,
                                    selectedCloseMinute,
                                    (int newVal) => setState(
                                        () => selectedCloseMinute = newVal),
                                  )
                                ],
                              ),
                              SizedBox(height: 20),
                              // Displaying sensor values for testing
                              Text('Sensor Open: ${sensorOpenController.text}'),
                              Text(
                                  'Sensor Close: ${sensorCloseController.text}'),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                ' ค่าเซนเซอร์เปิด :',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' ${openSensor} lux',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                ' ค่าเซนเซอร์ปิด :',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' ${offSensor} °C',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'เวลาเปิด ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' $ontime',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'เวลาปิด ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                  '$offtime',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget buildInputText(
  String name,
  String nameHint,
  TextEditingController controller,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 30),
        child: Text(
          name,
          style: TextStyle(color: Color(0xFF6FC0C5), fontSize: 16),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
        child: Container(
          width: 330.0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Color(0xFF6FC0C5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: nameHint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            cursorColor: Colors.white,
          ),
        ),
      ),
    ],
  );
}
