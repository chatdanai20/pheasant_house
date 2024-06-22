import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:intl/intl.dart'; // เพิ่มเพื่อใช้สำหรับการแสดงวันที่
import '../../constants.dart';

class CardClean extends StatefulWidget {
  final String farmName;

  const CardClean({Key? key, required this.farmName}) : super(key: key);
  @override
  State<CardClean> createState() => _CardCleanState();
}

class _CardCleanState extends State<CardClean> {
  final TextEditingController _intervalController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _selectedDay = DateTime.now().day;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year + 543;

  @override
  void dispose() {
    _intervalController.dispose();
    super.dispose();
  }

  Future<void> _saveCleaningDay() async {
    int day = _selectedDay;
    int month = _selectedMonth;
    int year = _selectedYear - 543; // Convert to AD

    DateTime selectedDate = DateTime(year, month, day);

    if (selectedDate.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('โปรดเลือกวันที่ในอนาคต'),
      ));
      return;
    }

    int intervalDays = int.parse(_intervalController.text);

    User? user = _auth.currentUser;
    if (user != null) {
      String email = user.email!;
      String farmName =
          widget.farmName; // ใช้ widget.farmName ที่ส่งเข้ามาใน constructor
      String cleaningDayId =
          'cleaningday'; // สมมุติว่าใช้ id 1 สำหรับ cleaning_day

      await _firestore
          .collection('User')
          .doc(email)
          .collection('farm')
          .doc(farmName)
          .collection('cleaning_day')
          .doc(cleaningDayId)
          .set({
        'cleaning_day': selectedDate,
        'intervalDays': intervalDays,
      });
    }
  }

  Future<Map<String, dynamic>?> _getCleaningDayData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String email = user.email!;
      String farmName = widget.farmName;
      String cleaningDayId = 'cleaningday';

      DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection('User')
          .doc(email)
          .collection('farm')
          .doc(farmName)
          .collection('cleaning_day')
          .doc(cleaningDayId)
          .get();

      if (doc.exists) {
        Map<String, dynamic>? data = doc.data();
        if (data != null && data.containsKey('intervalDays')) {
          return data;
        } else {
          // Handle case where intervalDays is not present or null
          return {'cleaning_day': doc['cleaning_day']};
        }
      }
    }
    return null;
  }
  Future<void> _updateCleaningDate() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String email = user.email!;
      String farmName = widget.farmName;
      String cleaningDayId = 'cleaningday';

      // Get current data from Firestore
      DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection('User')
          .doc(email)
          .collection('farm')
          .doc(farmName)
          .collection('cleaning_day')
          .doc(cleaningDayId)
          .get();

      if (doc.exists) {
        // Calculate new cleaning day
        // DateTime currentCleaningDay = doc['cleaning_day'].toDate();
        int intervalDays = doc['intervalDays'];
        DateTime newCleaningDay = DateTime.now().add(Duration(days: intervalDays));
        // DateTime newCleaningDay =
        //     currentCleaningDay.add(Duration(days: intervalDays));

        // Update Firestore with new data
        await _firestore
            .collection('User')
            .doc(email)
            .collection('farm')
            .doc(farmName)
            .collection('cleaning_day')
            .doc(cleaningDayId)
            .set({
          'cleaning_day': newCleaningDay,
          'intervalDays': intervalDays,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore
          .collection('User')
          .doc(FirebaseAuth.instance.currentUser?.email)
          .collection('farm')
          .doc(widget.farmName)
          .collection('cleaning_day')
          .doc('cleaningday')
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

        DateTime cleaningDay = snapshot.data!['cleaning_day'].toDate();
        int intervalDays = snapshot.data!['intervalDays'];

        String formattedDate = DateFormat.yMMMMd('th_TH').format(cleaningDay);

        return Container(
          width: MediaQuery.of(context).size.width / 1.3,
          height: MediaQuery.of(context).size.height / 1.4,
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
              Image.asset('asset/images/carbon_clean.png'),
              const SizedBox(
                height: 50,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 30, bottom: 5),
                    child: Text('วันทำความสะอาด',
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
                          formattedDate,
                          textAlign:
                              TextAlign.center, // ปรับให้ข้อความอยู่ตรงกลาง
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.black,
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
                      'ช่วงวัน',
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
                          '$intervalDays ',
                          textAlign:
                              TextAlign.center, // ปรับให้ข้อความอยู่ตรงกลาง
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'วัน',
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
                                    "ตั้งค่าทำความสะอาด",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Column(
                                        children: [
                                          const Text('วัน'),
                                          buildNumberPicker(
                                            _selectedDay,
                                            1,
                                            31,
                                            (value) {
                                              setState(() {
                                                _selectedDay = value;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const Text('เดือน'),
                                          buildNumberPicker(
                                            _selectedMonth,
                                            1,
                                            12,
                                            (value) {
                                              setState(() {
                                                _selectedMonth = value;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const Text('ปี (พ.ศ.)'),
                                          buildNumberPicker(
                                            _selectedYear,
                                            DateTime.now().year + 543,
                                            DateTime.now().year + 543 + 100,
                                            (value) {
                                              setState(() {
                                                _selectedYear = value;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: "ช่วงวัน (interval)",
                                    ),
                                    keyboardType: TextInputType.number,
                                    controller: _intervalController,
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          _saveCleaningDay();
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
                      'ตั้งค่าทำความสะอาด',
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
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _updateCleaningDate();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6FC0C5),
                    ),
                    child: const Text(
                      "ทำความสะอาดแล้ว",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
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
