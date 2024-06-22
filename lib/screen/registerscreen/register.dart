import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pheasant_house/screen/functionMQTT.dart/register_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pheasant_house/screen/welcome/welcome.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  bool _isPasswordVisible = false;

  String groupValue = 'yes';

  UserProfile? registerUser() {
    if (_formkey.currentState!.validate()) {
      UserProfile newUser = UserProfile(
        username: usernameController.text,
        password: passwordController.text,
        name: nameController.text,
        lastname: lastnameController.text,
        gender: genderController.text,
        email: emailController.text,
        phone: phoneController.text,
        address: addressController.text,
        role: groupValue,
      );

      // Add your registration logic here
      // Print user details to the console
      print('User Registered:');
      print('Username: ${newUser.username}');
      print('Password: ${newUser.password}');
      print('Name: ${newUser.name}');
      print('Lastname: ${newUser.lastname}');
      print('Gender: ${newUser.gender}');
      print('Email: ${newUser.email}');
      print('Phone: ${newUser.phone}');
      print('Address: ${newUser.address}');
      print('Role: ${newUser.role}');

      // Optionally, show a snackbar to indicate success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('User Registered: ${newUser.username}, ${newUser.email}'),
        ),
      );

      // Return newUser
      return newUser;
    } else {
      // Return null if form validation fails
      return null;
    }
    // Return null as default if the function completes without returning a value
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: firebase,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(
                title: Text("Error"),
              ),
              body: Center(
                child: Text("${snapshot.error}"),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                centerTitle: true,
                title: const Text('ลงทะเบียน',
                    style: TextStyle(color: Colors.white)),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Center(
                    child: Form(
                      key: _formkey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          buildInputText(
                              'ชื่อ', 'กรุณากรอกชื่อ', nameController),
                          buildInputText('นามสกุล', 'กรุณากรอกนามสกุล',
                              lastnameController),
                          buildInputText(
                              'เพศ', 'กรุณากรอกเพศ', genderController),
                          buildInputText(
                              'Email', 'กรุณากรอกอีเมล', emailController),
                          buildInputText('Password', 'กรุณาตั้งรหัสผ่าน',
                              passwordController,
                              isPassword: true),
                          buildInputText(
                              'ที่อยู่', 'กรุณากรอกที่อยู่', addressController),
                          buildInputText(
                              'เบอร์โทร', 'กรุณาเบอร์โทร', phoneController),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  children: [
                                    Radio(
                                        value: 'เจ้าของฟาร์ม',
                                        groupValue: groupValue,
                                        onChanged: (value) {
                                          setState(() {
                                            groupValue = value!;
                                          });
                                        }),
                                    Text(
                                      'เจ้าของฟาร์ม',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Radio(
                                        value: 'ลูกจ้าง',
                                        groupValue: groupValue,
                                        onChanged: (value) {
                                          setState(() {
                                            groupValue = value!;
                                          });
                                        }),
                                    Text(
                                      'ลูกจ้าง',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ElevatedButton(
                              onPressed: () async {
                                registerUser();
                                UserProfile? newUser = registerUser();
                                if (_formkey.currentState!.validate()) {
                                  try {
                                    await FirebaseAuth.instance
                                        .createUserWithEmailAndPassword(
                                            email: newUser!.email,
                                            password: newUser.password)
                                        .then((value) async {
                                      try {
                                        await FirebaseFirestore.instance
                                            .collection('User')
                                            .doc(newUser.email)
                                            .set({
                                          'name': newUser.name,
                                          'lastname': newUser.lastname,
                                          'gender': newUser.gender,
                                          'email': newUser.email,
                                          'phone': newUser.phone,
                                          'address': newUser.address,
                                          'role': newUser.role,
                                        });
                                      } on FirebaseAuthException catch (e) {
                                        Fluttertoast.showToast(
                                          msg: e.message!,
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.BOTTOM,
                                        );
                                      }

                                      _formkey.currentState!.reset();
                                      Navigator.pushReplacement(context,
                                          MaterialPageRoute(builder: (context) {
                                        return Welcomescreen();
                                      }));
                                    });
                                  } on FirebaseAuthException catch (e) {
                                    Fluttertoast.showToast(
                                      msg: e.message!,
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFFFFF),
                                elevation: 5,
                              ),
                              child: const Text(
                                'ลงทะเบียน',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
  }

    Widget buildInputText(
      String name, String nameHint, TextEditingController controller,
      {bool isPassword = false}) {
    // กำหนดค่าตั้งต้น
    TextInputType keyboardType = TextInputType.text;

    String? Function(String?)? validator;
    // ตรวจสอบค่าของ name
    if (name == 'Email') {
      keyboardType = TextInputType.emailAddress;
      validator = (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      };
    } else if (name == 'Password') {
      validator = (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters long';
        }
        if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%\^&\*])')
            .hasMatch(value)) {
          return 'Password must include at least one uppercase letter, one lowercase letter, one number, and one special character';
        }
        return null;
      };
    } else if (name == 'Phone') {
      validator = (value) {
        if (!RegExp(r'^(?=.*\d)').hasMatch(value!)) {
          return 'Phone must include a number';
        }
        if (value.length < 10) {
          return 'Phone must be at least 10 characters';
        }
        return null;
      };
    } else {
      validator = (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $name';
        }
        return null;
      };
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Text(
            name,
            style:
                TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
          child: Container(
            width: 330.0,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9).withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: isPassword ? !_isPasswordVisible : false,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: nameHint,
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                suffixIcon: isPassword
                    ? IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      )
                    : null,
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              cursorColor: Colors.white,
              validator: validator,
            ),
          ),
        ),
      ],
    );
  }
}

/*class RegisteredUserInfoScreen extends StatelessWidget {
  final User user;

  const RegisteredUserInfoScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registered User Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Username: ${user.username}'),
            Text('Password: ${user.password}'),
            Text('Name: ${user.name}'),
            Text('Lastname: ${user.lastname}'),
            Text('Gender: ${user.gender}'),
            Text('Email: ${user.email}'),
            Text('Phone: ${user.phone}'),
            Text('Address: ${user.address}'),
            Text('Role: ${user.role}'),
          ],
        ),
      ),
    );
  }
}*/