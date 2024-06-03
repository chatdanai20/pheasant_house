import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationScreen extends StatefulWidget {
  final String userEmail;

  const NotificationScreen({Key? key, required this.userEmail})
      : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontSize: 20), // เพิ่มขนาดตัวอักษรใน AppBar
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SettingsScreen(userEmail: widget.userEmail),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('User')
            .doc(widget.userEmail)
            .collection('farm')
            .snapshots(),
        builder: (context, farmSnapshot) {
          if (farmSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (farmSnapshot.hasError) {
            return Center(
              child: Text('Error: ${farmSnapshot.error}'),
            );
          }
          final List<DocumentSnapshot> farmDocuments =
              farmSnapshot.data?.docs ?? [];
          if (farmDocuments.isEmpty) {
            return const Center(
              child: Text('No farms found.'),
            );
          }
          return ListView.builder(
            itemCount: farmDocuments.length,
            itemBuilder: (context, farmIndex) {
              final farmName = farmDocuments[farmIndex].id;
              return FutureBuilder<Map<String, String>>(
                future: _getNotificationStatus(widget.userEmail, farmName),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text(
                        'Loading...',
                        style: TextStyle(fontSize: 18), // เพิ่มขนาดตัวอักษรใน ListTile
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return ListTile(
                      title: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(fontSize: 18), // เพิ่มขนาดตัวอักษรใน ListTile
                      ),
                    );
                  }
                  final notificationStatus = snapshot.data ?? {};
                  return ListTile(
                    title: Text(
                      'Farm: $farmName',
                      style: TextStyle(fontSize: 18), // เพิ่มขนาดตัวอักษรใน ListTile
                    ),
                    subtitle: Text(
                      notificationStatus.values.join('\n'),
                      style: TextStyle(fontSize: 16), // เพิ่มขนาดตัวอักษรใน subtitle
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<Map<String, String>> _getNotificationStatus(
      String userEmail, String farmName) async {
    final Map<String, String> status = {};

    final tempDoc = await FirebaseFirestore.instance
        .collection('User')
        .doc(userEmail)
        .collection('farm')
        .doc(farmName)
        .collection('notification')
        .doc('temperature')
        .get();

    final ammoniaDoc = await FirebaseFirestore.instance
        .collection('User')
        .doc(userEmail)
        .collection('farm')
        .doc(farmName)
        .collection('notification')
        .doc('ammonia')
        .get();

    final environmentDoc = await FirebaseFirestore.instance
        .collection('User')
        .doc(userEmail)
        .collection('farm')
        .doc(farmName)
        .collection('environment')
        .doc('now')
        .get();

    final tempMax =
        tempDoc.exists ? (tempDoc['notification_max'] as num).toDouble() : null;
    final tempMin =
        tempDoc.exists ? (tempDoc['notification_min'] as num).toDouble() : null;
    final ammoniaMax = ammoniaDoc.exists
        ? (ammoniaDoc['notification_max'] as num).toDouble()
        : null;
    final ammoniaMin = ammoniaDoc.exists
        ? (ammoniaDoc['notification_min'] as num).toDouble()
        : null;

    final currentTemp = environmentDoc.exists
        ? (environmentDoc['temperature'] as num).toDouble()
        : null;
    final currentAmmonia = environmentDoc.exists
        ? (environmentDoc['ppm'] as num).toDouble()
        : null;

    if (currentTemp != null) {
      if (tempMax != null && currentTemp > tempMax) {
        status['temperature'] = 'อุณหภูมิของโรงเรือน $farmName สูงกว่าที่กำหนด';
      } else if (tempMin != null && currentTemp < tempMin) {
        status['temperature'] = 'อุณหภูมิของโรงเรือน $farmName ต่ำกว่าที่กำหนด';
      } else {
        status['temperature'] = 'อุณหภูมิของโรงเรือน $farmName อยู่ในเกณฑ์ปกติ';
      }
    }

    if (currentAmmonia != null) {
      if (ammoniaMax != null && currentAmmonia > ammoniaMax) {
        status['ammonia'] = 'ค่าแอมโมเนียของโรงเรือน $farmName สูงกว่าที่กำหนด';
      } else if (ammoniaMin != null && currentAmmonia < ammoniaMin) {
        status['ammonia'] = 'ค่าแอมโมเนียของโรงเรือน $farmName ต่ำกว่าที่กำหนด';
      } else {
        status['ammonia'] = 'ค่าแอมโมเนียของโรงเรือน $farmName อยู่ในเกณฑ์ปกติ';
      }
    }

    return status;
  }
}

class SettingsScreen extends StatefulWidget {
  final String userEmail;

  const SettingsScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? selectedFarm;
  TextEditingController tempMaxController = TextEditingController();
  TextEditingController tempMinController = TextEditingController();
  TextEditingController ammoniaMaxController = TextEditingController();
  TextEditingController ammoniaMinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 20), // เพิ่มขนาดตัวอักษรใน AppBar
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('User')
                .doc(widget.userEmail)
                .collection('farm')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }
              final List<DocumentSnapshot> documents =
                  snapshot.data?.docs ?? [];
              return DropdownButton<String>(
                hint: const Text(
                  'Select Farm',
                  style: TextStyle(fontSize: 18), // เพิ่มขนาดตัวอักษรใน Dropdown
                ),
                value: selectedFarm,
                onChanged: (String? newValue) async {
                  setState(() {
                    selectedFarm = newValue;
                  });
                  if (newValue != null) {
                    await loadNotifications(newValue);
                  }
                },
                items: documents.map((DocumentSnapshot document) {
                  final String farmName = document['farm_name'] as String;
                  return DropdownMenuItem<String>(
                    value: farmName,
                    child: Text(
                      farmName,
                      style: TextStyle(fontSize: 18), // เพิ่มขนาดตัวอักษรใน Dropdown
                    ),
                  );
                }).toList(),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: tempMaxController,
                  decoration: const InputDecoration(
                    labelText: 'Temperature Max',
                    labelStyle: TextStyle(fontSize: 18), // เพิ่มขนาดตัวอักษรใน label
                  ),
                ),
                TextField(
                  controller: tempMinController,
                  decoration: const InputDecoration(
                    labelText: 'Temperature Min',
                    labelStyle: TextStyle(fontSize: 18), // เพิ่มขนาดตัวอักษรใน label
                  ),
                ),
                TextField(
                  controller: ammoniaMaxController,
                  decoration: const InputDecoration(
                    labelText: 'Ammonia Max',
                    labelStyle: TextStyle(fontSize: 18), // เพิ่มขนาดตัวอักษรใน label
                  ),
                ),
                TextField(
                  controller: ammoniaMinController,
                  decoration: const InputDecoration(
                    labelText: 'Ammonia Min',
                    labelStyle: TextStyle(fontSize: 18), // เพิ่มขนาดตัวอักษรใน label
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedFarm != null) {
                      saveNotifications();
                    }
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 18), // เพิ่มขนาดตัวอักษรในปุ่ม
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loadNotifications(String farmName) async {
    final tempDoc = await FirebaseFirestore.instance
        .collection('User')
        .doc(widget.userEmail)
        .collection('farm')
        .doc(farmName)
        .collection('notification')
        .doc('temperature')
        .get();

    final ammoniaDoc = await FirebaseFirestore.instance
        .collection('User')
        .doc(widget.userEmail)
        .collection('farm')
        .doc(farmName)
        .collection('notification')
        .doc('ammonia')
        .get();

    setState(() {
      tempMaxController.text = tempDoc['notification_max'].toString();
      tempMinController.text = tempDoc['notification_min'].toString();
      ammoniaMaxController.text = ammoniaDoc['notification_max'].toString();
      ammoniaMinController.text = ammoniaDoc['notification_min'].toString();
    });
  }

  Future<void> saveNotifications() async {
    final farmName = selectedFarm!;
    await FirebaseFirestore.instance
        .collection('User')
        .doc(widget.userEmail)
        .collection('farm')
        .doc(farmName)
        .collection('notification')
        .doc('temperature')
        .update({
      'notification_max': double.parse(tempMaxController.text),
      'notification_min': double.parse(tempMinController.text),
    });

    await FirebaseFirestore.instance
        .collection('User')
        .doc(widget.userEmail)
        .collection('farm')
        .doc(farmName)
        .collection('notification')
        .doc('ammonia')
        .update({
      'notification_max': double.parse(ammoniaMaxController.text),
      'notification_min': double.parse(ammoniaMinController.text),
    });
  }
}
