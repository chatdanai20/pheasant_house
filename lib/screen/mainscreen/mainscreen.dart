import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pheasant_house/screen/menuscreen/menuscreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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
                          icon: const Icon(Icons.arrow_back)),
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
            const SizedBox(
              height: 30,
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MenuScreen()),
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.65,
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
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'โรงเรือนที่ 1',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: Text(
                              'วันนี้, 25 กุมภาพันธ์',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: Text(
                              'ความเป็นแสง',
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
                          Image.asset(
                            'asset/images/sun.png',
                            width: 150,
                            height: 150,
                          ),
                          const Column(
                            children: [
                              Text(
                                '29 °C',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'ปกติ',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: SizedBox(
                        height:
                            170, // Ensure this is sufficient to contain the height of the cards plus any padding
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            const SizedBox(
                                width: 10), // Adds space at the beginning
                            _infoCard('ความเข้มแสง', Icons.wb_sunny),
                            const SizedBox(width: 10), // Space between cards
                            _infoCard('ความชื้นดิน', Icons.opacity),
                            const SizedBox(width: 10), // Space between cards
                            _infoCard('ความชื้นอากาศ', Icons.thermostat),
                            const SizedBox(width: 10), // Space between cards
                            _infoCard('แอมโมเนีย', Icons.opacity),
                            const SizedBox(width: 10), // Space between cards
                            _infoCard('อุณหภูมิ', Icons.thermostat),
                            const SizedBox(width: 10), // Adds space at the end
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
}

Widget _infoCard(String title, IconData icon) {
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
