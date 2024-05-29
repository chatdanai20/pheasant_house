import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pheasant_house/screen/menuscreen/menuscreen.dart';

class MainScreen extends StatefulWidget {
  final Map<String, dynamic> houseData;

  const MainScreen({super.key, required this.houseData});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String displayText = 'เลือกข้อมูลที่ต้องการดู';
  IconData _selectedIcon = Icons.wb_sunny;
  String _selectedTitle = 'ความเข้มแสง';
  String _selectedImage = 'asset/images/sun.png';

  void updateDisplayText(String title, String value, String image) {
    setState(() {
      _selectedTitle = title;
      displayText = value;
      _selectedImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back),
                      ),
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Image.asset('asset/images/Logo2.png'),
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
            InkWell(
              child: Container(
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
                            widget.houseData['farm_name'] ?? 'โรงเรือนที่ 1',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              'วันนี้, ${DateTime.now().toLocal().toString().split(' ')[0]}',
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
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                        borderRadius: BorderRadius.circular(20),
                                        image: DecorationImage(
                                          image: AssetImage(_selectedImage),
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
                                      widget.houseData['status'] ?? 'ปกติ',
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
                                'ความเข้มแสง: ${widget.houseData['light_intensity']}',
                                'asset/images/sun.png'),
                            const SizedBox(width: 10),
                            _infoCard(
                                'ความชื้นดิน',
                                Icons.opacity,
                                'ความชื้นดิน: ${widget.houseData['soil_humidity']}',
                                'asset/images/humidity.png'),
                            const SizedBox(width: 10),
                            _infoCard(
                                'ความชื้นอากาศ',
                                Icons.thermostat,
                                'ความชื้นอากาศ: ${widget.houseData['air_humidity']}',
                                'asset/images/humidity.png'),
                            const SizedBox(width: 10),
                            _infoCard(
                                'แอมโมเนีย',
                                Icons.opacity,
                                'แอมโมเนีย: ${widget.houseData['ammonia']}',
                                'asset/images/ammonia.png'),
                            const SizedBox(width: 10),
                            _infoCard(
                                'อุณหภูมิ',
                                Icons.thermostat,
                                'อุณหภูมิ: ${widget.houseData['temperature']} °C',
                                'asset/images/temperature.png'),
                            const SizedBox(width: 10),
                            _infoCardGraph('ความดันอากาศ', Icons.speed),
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

  Widget _infoCardGraph(String title, IconData icon) {
    return Container(
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
    );
  }
}
