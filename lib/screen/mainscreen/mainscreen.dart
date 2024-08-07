import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pheasant_house/screen/chartscreen/chartscreen.dart';
import 'package:pheasant_house/screen/functionMQTT.dart/mqtt.dart';
import 'package:pheasant_house/screen/menuscreen/menuscreen.dart';
import 'package:pheasant_house/screen/homescreen/homescreen.dart';
import 'package:pheasant_house/screen/profileScreen/profilescreen.dart'; // Import the profile screen
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pheasant_house/screen/notification/notificationscreen.dart';

class MainScreen extends StatefulWidget {
  final String farmName;
  final String userEmail;
  const MainScreen({super.key, required this.farmName,required this.userEmail});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final MqttHandler mqttHandler = MqttHandler();
  late User? _user;
  late String _userEmail = '';
  String displayText = 'เลือกข้อมูลที่ต้องการดู';
  final IconData _selectedIcon = Icons.wb_sunny;
  String _selectedTitle = 'ความเข้มแสง';
  String _selectedImage = 'asset/images/sun.png';
  Map<String, dynamic>? houseData;
  bool hasNotification = false; // Add a variable to track notification status
  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _userEmail = _user?.email ?? '';
    initializeDateFormatting('th', null).then((_) {
      fetchHouseData();
    });

    // Subscribe to the LDR stream to get real-time updates
    mqttHandler.ldrStream.listen((double ldrValue) {
      setState(() {
        ldrValue = ldrValue;
      });
    });
  }

  Future<void> fetchHouseData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String email = user.email!;
      DocumentSnapshot<Map<String, dynamic>> farmData = await FirebaseFirestore
          .instance
          .collection('User')
          .doc(email)
          .collection('farm')
          .doc(widget.farmName)
          .collection('environment')
          .doc('now')
          .get();

      if (farmData.exists) {
        setState(() {
          houseData = farmData.data();
          int notificationCount = 0;
        });
      }
    }
  }

  void updateDisplayText(String title, String value, String image) {
    setState(() {
      _selectedTitle = title;
      displayText = value;
      _selectedImage = image;
    });
  }

  String getThaiFormattedDate(DateTime date) {
    return DateFormat.yMMMMEEEEd('th').format(date);
  }

  @override
  void dispose() {
    // Dispose of the MqttHandler when the widget is disposed
    mqttHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            if (houseData == null)
              Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.arrow_back),
                            ),
                            SizedBox(
                              width: 70,
                              height: 70,
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
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'To Pheasant House',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            if (hasNotification)
                              Stack(
                                children: [
                                  Icon(
                                    Icons.notifications,
                                    color: Colors.red,
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
                                        minWidth: 12,
                                        minHeight: 12,
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
                            PopupMenuButton<String>(
                              onSelected: (String value) {
                                switch (value) {
                                  case 'notification':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            NotificationScreen(
                                          userEmail: _userEmail,
                                        ),
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
                                        builder: (context) =>
                                            const ProfileScreen(),
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
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 20,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.farmName,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'วันนี้, ${getThaiFormattedDate(DateTime.now())}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  'ข้อมูลปัจจุบัน',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 35),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: SizedBox(
                                            width: 130,
                                            height: 130,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                      _selectedImage),
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 10,
                                              ),
                                              child: Text(
                                                displayText,
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Text(
                                              'ข้อมูลล่าสุดเมื่อ ${houseData?['time'] ?? 'N/A'}',
                                              style: const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 150,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                const SizedBox(width: 10),
                                _infoCard(
                                  'ความเข้มแสง',
                                  Icons.wb_sunny,
                                  'ความเข้มแสง: ${houseData?['lux'] ?? 'N/A'} lux',
                                  'asset/images/sun.png',
                                ),
                                const SizedBox(width: 10),
                                _infoCard(
                                  'ความชื้นดิน',
                                  Icons.opacity,
                                  'ความชื้นดิน: ${houseData?['soilmoisture'] ?? 'N/A'} %',
                                  'asset/images/soil.png',
                                ),
                                const SizedBox(width: 10),
                                _infoCard(
                                  'ความชื้นอากาศ',
                                  Icons.thermostat,
                                  'ความชื้นอากาศ: ${houseData?['humidity'] ?? 'N/A'} %',
                                  'asset/images/humidity.png',
                                ),
                                const SizedBox(width: 10),
                                _infoCard(
                                  'แอมโมเนีย',
                                  Icons.opacity,
                                  'แอมโมเนีย: ${houseData?['ppm'] ?? 'N/A'} ppm',
                                  'asset/images/ammonia.png',
                                ),
                                const SizedBox(width: 10),
                                _infoCard(
                                  'อุณหภูมิ',
                                  Icons.thermostat,
                                  'อุณหภูมิ: ${houseData?['temperature'] ?? 'N/A'} °C',
                                  'asset/images/temperature.png',
                                ),
                                const SizedBox(width: 10),
                                _infoCardGraph(
                                    'ข้อมูลย้อนหลัง', Icons.history, context),
                                const SizedBox(width: 10),
                                _infoCardWithNavigation(
                                    'เมนูเพิ่มเติม', Icons.menu, context),
                                const SizedBox(width: 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, IconData icon, String value, String image) {
    return GestureDetector(
      onTap: () => updateDisplayText(title, value, image),
      child: Container(
        width: 110,
        height: 150,
        decoration: BoxDecoration(
          color: const Color(0xFFB0BBBA),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(icon, size: 48),
            Text(
              title,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCardWithNavigation(
      String title, IconData icon, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuScreen(
                farmName:
                    widget.farmName,userEmail:widget.userEmail), // ส่งชื่อโรงเรือนผ่านพารามิเตอร์ farmName
          ),
        );
      },
      child: Container(
        width: 110,
        height: 150,
        decoration: BoxDecoration(
          color: const Color(0xFFB0BBBA),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(icon, size: 48),
            Text(
              title,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCardGraph(String title, IconData icon, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChartScreen(
              farmName: widget.farmName,
              email: _userEmail,
            ),
          ),
        );
      },
      child: Container(
        width: 110,
        height: 150,
        decoration: BoxDecoration(
          color: const Color(0xFFB0BBBA),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(icon, size: 48),
            Text(
              title,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
