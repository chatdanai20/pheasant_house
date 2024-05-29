import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pheasant_house/screen/registerscreen/register.dart';
import 'firesbaseMQTT.dart';

class UserProfile {
  String username='';
  String name ='';
  String lastname='' ;
  String phone =''; 
  String address='' ;
  String gender='' ;
  String email='' ;
  String password ='';
  String role='';
  UserProfile    ( { required this.username,
       required this.name,
       required this.lastname,
       required this.phone,
       required this.address,
       required this.gender,
       required this.email,
       required this.password,
       required this.role
       });


  Map<String,dynamic> userMap(){
    return{
      'username': username,
      'name': name,
      'lastname' : lastname,
      'tel':phone,
      'address':address,
      'gender':gender,
      'email':email,
      'password':password,
    };
  }
  Map<String,dynamic> userRoleMap(){
   return{ 'role' :role};
  }
   
}
  
class Profile {
  String email = '';
  String password = '';

  Profile ({
    required this.email,
    required this.password,
  });

}



Future<void> register(
 final String name,
 final String lastname,
 final String tel,
 final String mail,
 final String address,
 final String gender,
 final String username,
 final String password,
 final String userid,
) async {
  DocumentReference users_doc = users.doc(userid);
  await users_doc.set({
    'name': name,
    'lastname': lastname,
    'tel': tel,
    'mail': mail,
    'address': address,
    'gender': gender,
    'Username': username,
    'Password': password,
    'UserID': userid,
  });
}
