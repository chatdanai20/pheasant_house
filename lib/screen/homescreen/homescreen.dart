import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pheasant_house/screen/mainscreen/mainscreen.dart';
import 'package:pheasant_house/screen/profileScreen/profilescreen.dart';
import 'package:pheasant_house/screen/functionMQTT.dart/creatdata.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late User? _user;
  late String _userEmail = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _userEmail = _user?.email ?? ''; // กำหนดค่า _userId ให้เป็น email ของผู้ใช้
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
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'To Pheasant House',
                            style: TextStyle(
                                color: Colors.black,
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
            // เพิ่มช่องค้นหาที่นี่
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'ค้นหาโรงเรือน',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
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
                    return Center(
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

                  // Print data from Firestore for debugging
                  for (var document in documents) {
                    print(document.data());
                  }
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final Map<String, dynamic> data =
                          documents[index].data() as Map<String, dynamic>;
                      final String houseName = data['farm_name'] ?? '';

                      return CustomCard(
                        text: houseName,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainScreen(houseData: data), // ส่งข้อมูล houseData ไปยัง MainScreen
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
        onPressed: () {
          _addNewHouse();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _addNewHouse() async {
    final TextEditingController _houseNameController = TextEditingController();
    final TextEditingController _mqttServerController = TextEditingController();
    final TextEditingController _mqttClientController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New House'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _houseNameController,
              decoration: InputDecoration(
                hintText: 'Enter house name',
              ),
            ),
            TextField(
              controller: _mqttServerController,
              decoration: InputDecoration(
                hintText: 'Enter MQTT server',
              ),
            ),
            TextField(
              controller: _mqttClientController,
              decoration: InputDecoration(
                hintText: 'Enter MQTT client',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String houseName = _houseNameController.text;
              String mqttServer = _mqttServerController.text;
              String mqttClient = _mqttClientController.text;

              if (houseName.isNotEmpty &&
                  mqttServer.isNotEmpty &&
                  mqttClient.isNotEmpty) {
                // ตรวจสอบว่ามีโรงเรือนชื่อเดียวกันหรือไม่
                var houseCollection = FirebaseFirestore.instance
                    .collection('User')
                    .doc(_userEmail)
                    .collection('farm');

                var existingHouse = await houseCollection.doc(houseName).get();

                if (existingHouse.exists) {
                  // แสดงข้อความว่าโรงเรือนชื่อซ้ำ
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('โรงเรือนชื่อ "$houseName" มีอยู่แล้ว'),
                    ),
                  );
                } else {
                  // เพิ่มโรงเรือนใหม่
                  creatNewPheasantHouse(houseName).then((value) async {
                    await houseCollection.doc(houseName).set({
                      'farm_name': houseName,
                      'mqtt_server': mqttServer,
                      'mqtt_client': mqttClient,
                      // เพิ่มข้อมูลเริ่มต้นที่ต้องการที่นี่
                      'temperature': 25,
                      'humidity': 50,
                      'status': 'active',
                    });
                  });
                  Navigator.pop(context);
                }
              }
            },
            child: Text('Add'),
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
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete $houseName?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
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
              icon: Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ),
        ),
      ),
    );
  }
}
