import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pheasant_house/screen/mainscreen/mainscreen.dart';
import 'package:pheasant_house/screen/profileScreen/profilescreen.dart';
import 'package:pheasant_house/screen/viewerscreen/viewerscreen.dart';

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

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _userEmail = _user?.email ?? '';
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
                      const SizedBox(width: 10),
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
                              builder: (context) => MainScreen(farmName:  houseName), 
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
    );
  }

  void _searchHouse() {
    String email = _emailController.text.trim();
    String houseName = _houseNameController.text.trim();
    if (email.isNotEmpty && houseName.isNotEmpty) {
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
                    'temperature': 25,
                    'humidity': 50,
                    'status': 'active',
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
    // มี collection "environment" ภายในโรงเรือนที่เลือก
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(farmName: houseName),
      ),
    );
  } else {
     Navigator.pop(context);
    // ไม่มี collection "environment" ภายในโรงเรือนที่เลือก
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
