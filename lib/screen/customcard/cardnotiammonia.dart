import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:numberpicker/numberpicker.dart';

import '../../constants.dart';

class CardNotificationAmmonia extends StatefulWidget {
  final String farmName;

  const CardNotificationAmmonia({Key? key, required this.farmName})
      : super(key: key);
  @override
  State<CardNotificationAmmonia> createState() =>
      _CardNotificationAmmoniaState();
}

class _CardNotificationAmmoniaState extends State<CardNotificationAmmonia> {
 
  final TextEditingController _notification_max = TextEditingController();
  final TextEditingController _notification_min = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  

  @override
  void dispose() {
    
    _notification_max.dispose();
    _notification_min.dispose();
    super.dispose();
  }

  Future<void> _saveNotification() async {
  
    int notification_max = int.parse(_notification_max.text);
    int notification_min = int.parse(_notification_min.text);

    User? user = _auth.currentUser;
    if (user != null) {
      String email = user.email!;
      String farmName =
          widget.farmName; // ใช้ widget.farmName ที่ส่งเข้ามาใน constructor

      await _firestore
          .collection('User')
          .doc(email)
          .collection('farm')
          .doc(farmName)
          .collection('notification')
          .doc('ammonia')
          .set({
        'notification_max': notification_max,
        'notification_min': notification_min,
      });
    }
  }

  Future<Map<String, dynamic>?> _getNotification() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String email = user.email!;
      String farmName = widget.farmName;
      

      DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection('User')
          .doc(email)
          .collection('farm')
          .doc(farmName)
          .collection('notification')
          .doc('ammonia')
          .get();

      if (doc.exists) {
        return doc.data();
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore
          .collection('User')
          .doc(FirebaseAuth.instance.currentUser?.email)
          .collection('farm')
          .doc(widget.farmName)
          .collection('notification')
          .doc('ammonia')
          .snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('เกิดข้อผิดพลาด');
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text('ไม่มีข้อมูล');
        }
        
        int notification_max = snapshot.data!['notification_max'];
        int notification_min = snapshot.data!['notification_min'];
       
        

        return Container(
          width: MediaQuery.of(context).size.width / 1.3,
          height: MediaQuery.of(context).size.height / 1.7,
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(80),
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: Column(
            children: [
              sizedBox,
              Image.asset(
                'asset/images/NH3.png', width: 180, // กำหนดความกว้างของรูป
                height: 200, // กำหนดความสูงของรูป),
                // const SizedBox(
                //  height: 50,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 30, bottom: 5),
                    child: Text('ค่าแอมโมเนียสูงสุด',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Container(
                width: MediaQuery.of(context).size.width / 1.6,
                height: MediaQuery.of(context).size.height / 20,
                decoration: const BoxDecoration(
                  color: Color(0xFF6FC0C5),
                  borderRadius: BorderRadius.all(
                    Radius.circular(14),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        // เพิ่ม Expanded รอบ Text
                        child: Text(
                          '${notification_max}',
                          textAlign:
                              TextAlign.center, // ปรับให้ข้อความอยู่ตรงกลาง
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'ppm',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              sizedBox,
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 30, bottom: 5),
                    child: Text(
                      'ค่าแอมโมเนียต่ำสุด',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Container(
                width: MediaQuery.of(context).size.width / 1.6,
                height: MediaQuery.of(context).size.height / 20,
                decoration: const BoxDecoration(
                  color: Color(0xFF6FC0C5),
                  borderRadius: BorderRadius.all(
                    Radius.circular(14),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        // เพิ่ม Expanded รอบ Text
                        child: Text(
                          '${notification_min} ',
                          textAlign:
                              TextAlign.center, // ปรับให้ข้อความอยู่ตรงกลาง
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'ppm',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "ตั้งค่าแจ้งเตือนแอมโมเนีย",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: "ตั้งค่าแอมโมเนียสูงสุด",
                                    ),
                                    keyboardType: TextInputType.number,
                                    controller: _notification_max,
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: "ตั้งค่าแอมโมเนียต่ำสุด",
                                    ),
                                    keyboardType: TextInputType.number,
                                    controller: _notification_min,
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          _saveNotification();
                                          Navigator.of(context).pop();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF6FC0C5),
                                        ),
                                        child: const Text(
                                          "ตกลง",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF6FC0C5),
                                        ),
                                        child: const Text(
                                          "ยกเลิก",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ตั้งค่าเเจ้งเตือนแอมโมเนีย',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kTextBlackColor.withOpacity(0.5),
                      ),
                    ),
                    Icon(
                      Icons.settings_outlined,
                      color: kTextBlackColor.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildNumberPicker(
      int value, int minValue, int maxValue, ValueChanged<int> onChanged) {
    return NumberPicker(
      value: value,
      minValue: minValue,
      maxValue: maxValue,
      onChanged: (value) {
        assert(value >= minValue && value <= maxValue);
        onChanged(value);
      },
    );
  }
}
