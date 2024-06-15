import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pheasant_house/screen/mainscreen/mainscreen.dart';
import 'package:pheasant_house/screen/profileScreen/profilescreen.dart';
import 'package:pheasant_house/screen/viewerscreen/viewerscreen.dart';
import 'package:pheasant_house/screen/notification/notificationscreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late User? _user;
  late String _userEmail = '';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _houseNameController = TextEditingController();
  bool hasNotification = false;
  int _notificationCount = 0;
   int _daysUntilCleaning = -1; // Default value indicating no cleaning day set
  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _userEmail = _user?.email ?? '';
    checkForNotifications();
  }

  Future<void> checkForNotifications() async {
    final farmSnapshot = await FirebaseFirestore.instance
        .collection('User')
        .doc(_userEmail)
        .collection('farm')
        .get();

    bool notificationFound = false;
    int notificationCount = 0;
    int daysUntilCleaning = -1;

    for (final farmDoc in farmSnapshot.docs) {
      final farmName = farmDoc.id;
      final notifications = await _getNotificationStatus(_userEmail, farmName);
      if (notifications.isNotEmpty) {
        notificationFound = true;
        notificationCount += notifications.length;
    
        // Check the cleaning days
        final days = await _daysUntilCleaningDay(_userEmail, farmName);
        if (daysUntilCleaning == -1 || (days != -1 && days < daysUntilCleaning)) {
          daysUntilCleaning = days;
        }
      }
    }

    setState(() {
      hasNotification = notificationFound;
      _notificationCount = notificationCount;
       _daysUntilCleaning = daysUntilCleaning;
    });
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

    final cleaningDoc = await FirebaseFirestore.instance
        .collection('User')
        .doc(userEmail)
        .collection('farm')
        .doc(farmName)
        .collection('cleaning_day')
        .doc('cleaningday')
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

    final cleaningDay = cleaningDoc.exists
        ? (cleaningDoc['cleaning_day'] as Timestamp).toDate()
        : null;
    final intervalDays = cleaningDoc.exists
        ? (cleaningDoc['intervalDays'] as num).toInt()
        : null;

    if (currentTemp != null) {
      if (tempMax != null && currentTemp > tempMax) {
        status['temperature'] = 'อุณหภูมิ : สูงกว่าที่กำหนด';
      }
    }

    if (currentAmmonia != null) {
      if (ammoniaMax != null && currentAmmonia > ammoniaMax) {
        status['ammonia'] = 'ค่าแอมโมเนีย : สูงกว่าที่กำหนด';
      }
    }

    if (cleaningDay != null && intervalDays != null) {
      final currentDate = DateTime.now();
      final daysUntilCleaningDay = cleaningDay.difference(currentDate).inDays;

      if (daysUntilCleaningDay > 0 && daysUntilCleaningDay <= 3) {
        status['cleaning'] =
            'วันทำความสะอาด : ใกล้ถึงวันทำความสะอาดในอีก $daysUntilCleaningDay วัน';
      }
      if (daysUntilCleaningDay == 0) {
        status['cleaning'] = 'วันทำความสะอาด : วันทำความสะอาดวันนี้';
      }
      if (daysUntilCleaningDay < 0) {
        final daysAfterCleaningDay = currentDate.difference(cleaningDay).inDays;
        if (daysAfterCleaningDay > 1) {
          status['cleaning'] = 'วันทำความสะอาด : วันทำความสะอาดเมื่อวานนี้';
        } else {
          status['cleaning'] =
              'วันทำความสะอาด : เมื่อวานทำความสะอาดไปแล้ว $daysAfterCleaningDay วัน';
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
  Future<int> _daysUntilCleaningDay(String userEmail, String farmName) async {
    final cleaningDoc = await FirebaseFirestore.instance
        .collection('User')
        .doc(userEmail)
        .collection('farm')
        .doc(farmName)
        .collection('cleaning_day')
        .doc('cleaningday')
        .get();

    if (!cleaningDoc.exists) return -1;

    final cleaningDay = (cleaningDoc['cleaning_day'] as Timestamp).toDate();
    final currentDate = DateTime.now();
    final daysUntilCleaningDay = cleaningDay.difference(currentDate).inDays;

    return daysUntilCleaningDay;
  }

  @override
  Widget build(BuildContext context) {
    Color notificationIconColor=Colors.grey;
    
    if (_daysUntilCleaning == 0) {
      notificationIconColor = Colors.red;
    } 
    if (_daysUntilCleaning > 0 && _daysUntilCleaning <= 3) {
      notificationIconColor = Colors.orange;
    } 
    if(_daysUntilCleaning < 0)  {
      notificationIconColor = Colors.yellow;
    }
    
    return WillPopScope(
      onWillPop: () async {
        await checkForNotifications();
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Image.asset('asset/images/Logo2.png'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'To Pheasant House',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),    
                    Stack(
              children: [
                PopupMenuButton<String>(
                  onSelected: (String value) {
                    switch (value) {
                      case 'notification':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationScreen(
                                userEmail: _userEmail),
                          ),
                        ).then((_) {
                          setState(() {
                            hasNotification = false;
                            _notificationCount = 0;
                          });
                        });
                        break;
                      case 'information':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                        break;
                      case 'logout':
                        FirebaseAuth.instance.signOut();
                        Navigator.pop(context);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'notification',
                      child: Text('Notification'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'information',
                      child: Text('Profile'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Text('Logout'),
                    ),
                  ],
                  icon: Image.asset(
                    'asset/images/list.png',
                    width: 35,
                    height: 35,
                    color: Colors.black,
                  ),
                ),
                // ตำแหน่งของ icon แจ้งเตือนด้านขวาบน
                if (hasNotification)
                  Positioned(
                    top: 2,
                    right: 5,
                    child: Stack(
                      children: [
                        Icon(
                          Icons.notifications,
                          color: notificationIconColor,
                          size: 22,
                        ),
                        Positioned(
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 10,
                              minHeight: 10,
                            ),
                            child: Text(
                              '$_notificationCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
              ],
            ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Enter Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _houseNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter House Name',
                          prefixIcon: Icon(Icons.house),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: _searchHouse,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('User')
                      .doc(_userEmail)
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
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final Map<String, dynamic> data =
                            documents[index].data() as Map<String, dynamic>;
                        final String houseName = data['farm_name'] ?? '';
                        return CustomCard(
                          text: houseName,
                          onTap: () {
                            _checkEnvironment(houseName);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MainScreen(farmName: houseName),
                              ),
                            );
                          },
                          onDelete: () {
                            _confirmDeleteHouse(houseName);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addNewHouse,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _searchHouse() async {
    String email = _emailController.text.trim();
    String houseName = _houseNameController.text.trim();

    if (email.isNotEmpty && houseName.isNotEmpty) {
      var userDoc =
          await FirebaseFirestore.instance.collection('User').doc(email).get();
      if (userDoc.exists) {
        var houseDoc = await FirebaseFirestore.instance
            .collection('User')
            .doc(email)
            .collection('farm')
            .doc(houseName)
            .get();
        if (houseDoc.exists) {
          var environmentDoc = await houseDoc.reference
              .collection('environment')
              .doc('now')
              .get();
          if (environmentDoc.exists) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewerScreen(
                  userEmail: email,
                  houseName: houseName,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No environment data available for this house'),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No house found with the given name'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No user found with the given email'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both email and house name'),
        ),
      );
    }
  }

  void _addNewHouse() async {
    final TextEditingController _houseNameController = TextEditingController();
    final TextEditingController _mqttServerController = TextEditingController();
    final TextEditingController _mqttClientController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New House'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _houseNameController,
              decoration: const InputDecoration(
                hintText: 'Enter house name',
              ),
            ),
            TextField(
              controller: _mqttServerController,
              decoration: const InputDecoration(
                hintText: 'Enter MQTT server',
              ),
            ),
            TextField(
              controller: _mqttClientController,
              decoration: const InputDecoration(
                hintText: 'Enter MQTT client',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              String houseName = _houseNameController.text;
              String mqttServer = _mqttServerController.text;
              String mqttClient = _mqttClientController.text;

              if (houseName.isNotEmpty &&
                  mqttServer.isNotEmpty &&
                  mqttClient.isNotEmpty) {
                var houseCollection = FirebaseFirestore.instance
                    .collection('User')
                    .doc(_userEmail)
                    .collection('farm');

                var existingHouse = await houseCollection.doc(houseName).get();

                if (existingHouse.exists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('โรงเรือนชื่อ "$houseName" มีอยู่แล้ว'),
                    ),
                  );
                } else {
                  await houseCollection.doc(houseName).set({
                    'farm_name': houseName,
                    'mqtt_server': mqttServer,
                    'mqtt_client': mqttClient,
                  });
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteHouse(String houseName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete $houseName?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                _deleteHouse(houseName);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _checkEnvironment(String houseName) async {
    var farmRef = FirebaseFirestore.instance
        .collection('User')
        .doc(_userEmail)
        .collection('farm')
        .doc(houseName);

    var environmentCollection = farmRef.collection('environment');

    var environmentSnapshot = await environmentCollection.get();

    if (environmentSnapshot.docs.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(farmName: houseName),
        ),
      );
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No environment data available for $houseName'),
        ),
      );
    }
  }

  void _deleteHouse(String houseName) async {
    await FirebaseFirestore.instance
        .collection('User')
        .doc(_userEmail)
        .collection('farm')
        .doc(houseName)
        .delete();
  }
}

class CustomCard extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const CustomCard({
    Key? key,
    required this.text,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Card(
          elevation: 2,
          child: ListTile(
            title: Text(text),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ),
        ),
      ),
    );
  }
}
