import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pheasant_house/constants.dart';
import 'package:pheasant_house/screen/functionMQTT.dart/mqtt.dart';
import 'package:mqtt_client/mqtt_client.dart';

class CardAmmonia extends StatefulWidget {
  const CardAmmonia({super.key});

  @override
  State<CardAmmonia> createState() => _CardAmmoniaState();
}

class _CardAmmoniaState extends State<CardAmmonia> {
  final MqttHandler mqttHandler = MqttHandler();
  // late int temp;
  bool isOpen = false;
  bool isAuto = false;
  bool isAutoMode = false;
  int selectedOpenHour = 0;
  int selectedOpenMinute = 0;
  int selectedCloseHour = 0;
  int selectedCloseMinute = 0;
  String openingTimeMessage = '';
  String closingTimeMessage = '';
  TextEditingController sensorOpenController = TextEditingController();
  TextEditingController sensorCloseController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Subscribe to the LDR stream to get real-time updates
    mqttHandler.mqStream.listen((double mqValue) {
      setState(() {
        mqValue = mqValue;
      });
    });
  }

  void switchToManualMode() {
    setState(() {
      isAutoMode = false;
    });

    // Check if MQTT client is connected before sending the command
    if (mqttHandler.client.connectionStatus!.state ==
        MqttConnectionState.connected) {
      mqttHandler.sendAutoModeCommand('esp32/auto_mode', 'manual');
    }
  }

  void switchToAutoMode() {
    setState(() {
      isAutoMode = true;
    });

    // Check if MQTT client is connected before sending the command
    if (mqttHandler.client.connectionStatus!.state ==
        MqttConnectionState.connected) {
      mqttHandler.sendAutoModeCommand('esp32/auto_mode', 'auto');
    }
  }

  void turnOnRelay2() {
    if (mqttHandler.client.connectionStatus!.state ==
        MqttConnectionState.connected) {
      mqttHandler.controlRelay('esp32/relay2', 'on');
    }
  }

  void turnOffRelay2() {
    if (mqttHandler.client.connectionStatus!.state ==
        MqttConnectionState.connected) {
      mqttHandler.controlRelay('esp32/relay2', 'off');
    }
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
      height: MediaQuery.of(context).size.height / 1.5,
      decoration: const BoxDecoration(
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
          const SizedBox(
            height: 10,
          ),
          Image.asset('asset/images/fan.png'),
          sizedBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
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
              const Text(
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
                autofocus: false,
                value: isOpen,
                onChanged: (value) {
                  setState(
                    () {
                      isOpen = value;
                      if (isOpen) {
                        turnOnRelay2();
                      } else {
                        turnOffRelay2();
                      }
                    },
                  );
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
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
                  setState(
                    () {
                      isAuto = value;
                      if (isAuto) {
                        switchToAutoMode();
                      } else {
                        switchToManualMode();
                      }
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(const Color(0xFF00BFA5))),
            child: const Text(
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
                                count, (int index) => Text('$index')),
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
                                                  const Color(0xFF6FC0C5))),
                                      child: const Text(
                                        'กลับ',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  const Color(0xFF6FC0C5))),
                                      child: const Text(
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
                                        mqttHandler.sendSensorValue(
                                            'esp32/minppm',
                                            sensorOpenController.text);
                                        mqttHandler.sendSensorValue(
                                            'esp32/maxppm',
                                            sensorCloseController.text);
                                        mqttHandler.sendAutoModeCommand(
                                            'esp32/fanon',
                                            openingTimeMessage);
                                        mqttHandler.sendAutoModeCommand(
                                            'esp32/fanoff',
                                            closingTimeMessage);
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              buildInputText('ค่าเซนเซอร์เปิด ', 'อุณหภูมิ',
                                  sensorOpenController),
                              buildInputText('ค่าเซนเซอร์ปิด ', 'อุณหภูมิ',
                                  sensorCloseController),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                'เวลาเปิด',
                                style: TextStyle(
                                    color: Color(0xFF6FC0C5), fontSize: 16),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  buildPicker(
                                      24,
                                      selectedOpenHour,
                                      (int newVal) => setState(
                                          () => selectedOpenHour = newVal)),
                                  buildPicker(
                                      60,
                                      selectedOpenMinute,
                                      (int newVal) => setState(
                                          () => selectedOpenMinute = newVal)),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                'เวลาปิด',
                                style: TextStyle(
                                    color: Color(0xFF6FC0C5), fontSize: 16),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
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
                                  ),
                                ],
                              ),
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
          const SizedBox(
            height: 10,
          ),
          const Row(
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
                ' 40 °C',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Row(
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
                ' 25 °C',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Row(
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
                '',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text widget for displaying the label "เวลาเปิด"
              Text(
                'เวลาปิด ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Text widget for displaying the opening time
              Text(
                '',
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
          style: const TextStyle(color: Color(0xFF6FC0C5), fontSize: 16),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
        child: Container(
          width: 330.0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF6FC0C5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: nameHint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
            style: const TextStyle(
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
