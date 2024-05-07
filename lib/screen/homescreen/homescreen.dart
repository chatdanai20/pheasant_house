import 'package:flutter/material.dart';
import 'package:pheasant_house/screen/menuscreen/menuscreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> dataList = [
    'โรงเรือนที่ 1',
    'โรงเรือนที่ 2',
    'โรงเรือนที่ 3',
    'โรงเรือนที่ 4',
    'โรงเรือนที่ 5',
    'โรงเรือนที่ 6',
    'โรงเรือนที่ 7',
  ];

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
                  Row(
                    children: [
                      PopupMenuButton<String>(
                        onSelected: (String value) {
                          switch (value) {
                            case 'notification':
                              print('Notification tapped');
                              break;
                            case 'information':
                              print('Information tapped');
                              break;
                            case 'logout':
                              print('Logout tapped');
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
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFABBEB3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const SizedBox(
                      width: 70,
                      height: 50,
                      child: Row(
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Colors.black, size: 30),
                          Text(
                            'เพิ่ม',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 1.3,
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: ListView.builder(
                  itemCount: dataList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return CustomCard(
                      text: dataList[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MenuScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const CustomCard({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: const Color(0xff000000).withOpacity(0.5),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
