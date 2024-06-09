import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

User? useremail = FirebaseAuth.instance.currentUser;
FirebaseFirestore firestore = FirebaseFirestore.instance;
String? email = useremail?.email;

// อ้างอิงถึง collection User
CollectionReference users = firestore.collection('User');

// อ้างอิงถึง Document ภายในของ collection user โดยใช้ชื่อ farm_1
DocumentReference users_doc = users.doc(email);

Future<void> creatNewPheasantHouse(String pheasant_house_name) async {
  CollectionReference farm = users_doc.collection('farm');
  DocumentReference farm_id = farm.doc(pheasant_house_name);
  double count = 0;

  await farm_id.set({
   
    'farm_name': pheasant_house_name,
  });

  CollectionReference subcollection_1 = farm_id.collection('cleaning_day');
  DocumentReference cleaning_id = subcollection_1.doc('cleaningday_id');
  await cleaning_id.set({
    'cleaning_day': DateTime.now(),
    'cleaning_id': "1",
  });

  CollectionReference subcollection_2 = farm_id.collection('control');
  await subcollection_2.doc('light').set({
    'control_id': "01",
    'control_name': "light",
    'status': true,
  });
  await subcollection_2.doc('sprinkler_roof').set({
    'control_id': "02",
    'control_name': "sprinkler_roof",
    'status': true,
  });
  await subcollection_2.doc('sprinkler_trees').set({
    'control_id': "03",
    'control_name': "sprinkler_trees",
    'status': true,
  });
  await subcollection_2.doc('fan').set({
    'control_id': "04",
    'control_name': "fan",
    'status': true,
  });

  CollectionReference subcollection_3 = farm_id.collection('notification');
  await subcollection_3.doc('temperature').set({
    'notification_id': "01",
    'notification_max': 32,
    'notification_min': 22,
    'notification_name': "temperature",
  });
  await subcollection_3.doc('ammonia').set({
    'notification_id': "02",
    'notification_max': 20,
    'notification_min': 10,
    'notification_name': "ammonia",
  });

  CollectionReference subcollection_4 = farm_id.collection('sensor');
  await subcollection_4.doc('temperature').set({
    'sensor_id': "01",
    'sensor_max': 32,
    'sensor_min': 20,
    'sensor_name': "temperature",
  });
  await subcollection_4.doc('soil_moisture').set({
    'sensor_id': "02",
    'sensor_max': 70,
    'sensor_min': 30,
    'sensor_name': "soil_moisture",
  });
  await subcollection_4.doc('light_intensity').set({
    'sensor_id': "03",
    'sensor_max': 500,
    'sensor_min': 100,
    'sensor_name': "light_intensity",
  });
  await subcollection_4.doc('ammonia').set({
    'sensor_id': "04",
    'sensor_max': 20,
    'sensor_min': 10,
    'sensor_name': "ammonia",
  });

  CollectionReference subcollection_5 = farm_id.collection('time');
  await subcollection_5.doc('fan').set({
    'time_id': "1",
    'time_name': "fan",
    'time_on': DateTime.now(),
    'time_off': DateTime.now(),
  });
  await subcollection_5.doc('light').set({
    'time_id': "2",
    'time_name': "light",
    'time_on': DateTime.now(),
    'time_off': DateTime.now(),
  });
  await subcollection_5.doc('sprinkler_roof').set({
    'time_id': "3",
    'time_name': "sprinkler_roof",
    'time_on': DateTime.now(), 
    'time_off': DateTime.now(),
  });
  await subcollection_5.doc('sprinkler_trees').set({
    'time_id': "4",
    'time_name': "sprinkler_trees",
    'time_on': DateTime.now(),
    'time_off': DateTime.now(),
  });
}
