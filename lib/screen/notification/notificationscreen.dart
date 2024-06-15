import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationScreen extends StatefulWidget {
  final String userEmail;

  const NotificationScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool hasNotification = false;

  @override
  void initState() {
    super.initState();
    checkForNotifications();
  }

  Future<void> checkForNotifications() async {
    final farmSnapshot = await FirebaseFirestore.instance
        .collection('User')
        .doc(widget.userEmail)
        .collection('farm')
        .get();

    bool notificationFound = false;

    for (final farmDoc in farmSnapshot.docs) {
      final farmName = farmDoc.id;
      final notifications = await _getNotificationStatus(widget.userEmail, farmName);
      if (notifications.isNotEmpty) {
        notificationFound = true;
        break;
      }
    }

    setState(() {
      hasNotification = notificationFound;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontSize: 20),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        // actions: [
        //   if (hasNotification)
        //     Icon(
        //       Icons.notifications,
        //       color: Colors.red,
        //     )
        // ],
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
          final List<DocumentSnapshot> farmDocuments = farmSnapshot.data?.docs ?? [];
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
              style: TextStyle(fontSize: 18),
            ),
          );
        }
        if (snapshot.hasError) {
          return ListTile(
            title: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(fontSize: 18),
            ),
          );
        }
        final notificationStatus = snapshot.data ?? {};
        if (notificationStatus.isNotEmpty) {
          hasNotification = true;
        }
        return hasNotification
            ? Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Farm: $farmName',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      notificationStatus.values.join('\n'),
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              )
            : SizedBox(); // Return an empty SizedBox if no notification found for this farm
      },
    );
  },
);

        },
      ),
    );
  }

  Future<Map<String, String>> _getNotificationStatus(String userEmail, String farmName) async {
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

    final cleaningDoc = await FirebaseFirestore.instance
        .collection('User')
        .doc(userEmail)
        .collection('farm')
        .doc(farmName)
        .collection('cleaning_day')
        .doc('cleaningday')
        .get();

    final tempMax = tempDoc.exists ? (tempDoc['notification_max'] as num).toDouble() : null;
    final tempMin = tempDoc.exists ? (tempDoc['notification_min'] as num).toDouble() : null;
    final ammoniaMax = ammoniaDoc.exists ? (ammoniaDoc['notification_max'] as num).toDouble() : null;
    final ammoniaMin = ammoniaDoc.exists ? (ammoniaDoc['notification_min'] as num).toDouble() : null;

    final currentTemp = environmentDoc.exists ? (environmentDoc['temperature'] as num).toDouble() : null;
    final currentAmmonia = environmentDoc.exists ? (environmentDoc['ppm'] as num).toDouble() : null;

    final cleaningDay = cleaningDoc.exists ? (cleaningDoc['cleaning_day'] as Timestamp).toDate() : null;
    final intervalDays = cleaningDoc.exists ? (cleaningDoc['intervalDays'] as num).toInt() : null;

    if (currentTemp != null) {
      if (tempMax != null && currentTemp > tempMax) {
        status['temperature'] = 'อุณหภูมิ : สูงกว่าที่กำหนด';
      } //else if (tempMin != null && currentTemp < tempMin) {
        //status['temperature'] = 'อุณหภูมิ : ต่ำกว่าที่กำหนด'; } 
        //else {
        //status['temperature'] = 'อุณหภูมิ : อยู่ในเกณฑ์ปกติ';
      //}
    }

    if (currentAmmonia != null) {
      if (ammoniaMax != null && currentAmmonia > ammoniaMax) {
        status['ammonia'] = 'ค่าแอมโมเนีย : สูงกว่าที่กำหนด';
      }// else if (ammoniaMin != null && currentAmmonia < ammoniaMin) {
        //status['ammonia'] = 'ค่าแอมโมเนีย : ต่ำกว่าที่กำหนด';
      //} else {
        //status['ammonia'] = 'ค่าแอมโมเนีย : อยู่ในเกณฑ์ปกติ';
      //}
    }

   if (cleaningDay != null && intervalDays != null) {
  final currentDate = DateTime.now();
  final daysUntilCleaningDay = cleaningDay.difference(currentDate).inDays;

  if (daysUntilCleaningDay > 0 && daysUntilCleaningDay <= 3 ) {
    status['cleaning'] = 'วันทำความสะอาด : ใกล้ถึงวันทำความสะอาดในอีก $daysUntilCleaningDay วัน';
  }  if (daysUntilCleaningDay == 0) {
    status['cleaning'] = 'วันทำความสะอาด : วันทำความสะอาดวันนี้';
  } 
  if (daysUntilCleaningDay  < 0){
    final daysAfterCleaningDay = currentDate.difference(cleaningDay).inDays;
    if (daysAfterCleaningDay >1 ) {
      status['cleaning'] = 'วันทำความสะอาด : วันทำความสะอาดเมื่อวานนี้';
    } else {
      status['cleaning'] = 'วันทำความสะอาด : เมื่อวานทำความสะอาดไปแล้ว $daysAfterCleaningDay วัน';
    }
    
    if (currentDate.isAfter(cleaningDay)) {
      final newCleaningDay = cleaningDay.add(Duration(days: intervalDays));
      await FirebaseFirestore.instance
          .collection('User')
          .doc(userEmail)
          .collection('farm')
          .doc(farmName)
          .collection('cleaning_day')
          .doc('cleaningday')
          .update({'cleaning_day': newCleaningDay});
    }
  }
}

    return status;
  }
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return this.year == other.year && this.month == other.month && this.day == other.day;
  }
}
