import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewerScreen extends StatelessWidget {
  final String userEmail;
  final String houseName;

  const ViewerScreen({Key? key, required this.userEmail, required this.houseName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Viewer'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('User')
            .doc(userEmail)
            .collection('farm')
            .doc(houseName).collection('environment').doc('now')
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
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text('No data found'),
            );
          }

          final Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'House Name: ${data['farm_name']}',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'อุณหภูมิ: ${data['temperature']} °C',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  'ความชื้นในอากาศ: ${data['humidity']} %',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  'ความเข้มเเสง: ${data['lux']} lux',
                  style: TextStyle(fontSize: 18),
                ),SizedBox(height: 10),
                Text(
                  'ความชื้นในดิน: ${data['soilmoisture']} %',
                  style: TextStyle(fontSize: 18),                 
                ),SizedBox(height: 10),
                Text(
                  'แอมโมเนีย: ${data['ppm']} ppm',
                  style: TextStyle(fontSize: 18),                 
                ),SizedBox(height: 10),
                // Add more fields as necessary
              ],
            ),
          );
        },
      ),
    );
  }
}
