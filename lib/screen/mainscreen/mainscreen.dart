import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pheasant_house/screen/chartscreen/chartscreen.dart';
import 'package:pheasant_house/screen/menuscreen/menuscreen.dart';
import 'package:pheasant_house/screen/homescreen/homescreen.dart';
import 'package:pheasant_house/screen/profileScreen/profilescreen.dart'; // Import the profile screen
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class MainScreen extends StatefulWidget {
  final String farmName;

  const MainScreen({super.key, required this.farmName});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String displayText = 'เลือกข้อมูลที่ต้องการดู';
  final IconData _selectedIcon = Icons.wb_sunny;
  String _selectedTitle = 'ความเข้มแสง';
  String _selectedImage = 'asset/images/sun.png';
  Map<String, dynamic>? houseData;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('th', null).then((_) => fetchHouseData());
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: houseData == null
            ? Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 10, left: 10, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const HomeScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.arrow_back),
                                ),
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child:
                                        Image.asset('asset/images/Logo2.png'),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.75,
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
                                  horizontal: 40, vertical: 20),
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
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text(
                                      'วันนี้, ${getThaiFormattedDate(DateTime.now())}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                      'ข้อมูลปัจจุบัน',
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    child: Column(
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
                                        const SizedBox(height: 30),
                                        Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom:
                                                      10), // Increase the bottom padding as needed
                                              child: Text(
                                                displayText,
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
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
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: SizedBox(
                                height: 150,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    const SizedBox(width: 10),
                                    _infoCard(
                                        'ความเข้มแสง',
                                        Icons.wb_sunny,
                                        'ความเข้มแสง: ${houseData?['lux'] ?? 'N/A'} lux',
                                        'asset/images/sun.png'),
                                    const SizedBox(width: 10),
                                    _infoCard(
                                        'ความชื้นดิน',
                                        Icons.opacity,
                                        'ความชื้นดิน: ${houseData?['soilmoisture'] ?? 'N/A'} %',
                                        'asset/images/soil.png'),
                                    const SizedBox(width: 10),
                                    _infoCard(
                                        'ความชื้นอากาศ',
                                        Icons.thermostat,
                                        'ความชื้นอากาศ: ${houseData?['humidity'] ?? 'N/A'} %',
                                        'asset/images/humidity.png'),
                                    const SizedBox(width: 10),
                                    _infoCard(
                                        'แอมโมเนีย',
                                        Icons.opacity,
                                        'แอมโมเนีย: ${houseData?['ppm'] ?? 'N/A'} ppm',
                                        'asset/images/ammonia.png'),
                                    const SizedBox(width: 10),
                                    _infoCard(
                                        'อุณหภูมิ',
                                        Icons.thermostat,
                                        'อุณหภูมิ: ${houseData?['temperature'] ?? 'N/A'} °C',
                                        'asset/images/temperature.png'),
                                    const SizedBox(width: 10),
                                    _infoCardGraph('ข้อมูลย้อนหลัง',
                                        Icons.history, context),
                                    const SizedBox(width: 10),
                                    _infoCardWithNavigation(
                                        'เมนูเพิ่มเติม', Icons.menu, context),
                                    const SizedBox(width: 10),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: PopupMenuButton<String>(
                      onSelected: (String value) {
                        switch (value) {
                          case 'notification':
                            print('Notification tapped');
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
                          case 'home':
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'home',
                          child: Text('Home'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'notification',
                          child: Text('Notification'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'information',
                          child: Text('Information'),
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
          MaterialPageRoute(builder: (context) => const MenuScreen()),
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
          MaterialPageRoute(builder: (context) => const ChartScreen()),
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
