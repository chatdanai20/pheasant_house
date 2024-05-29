import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pheasant_house/screen/homescreen/homescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pheasant_house/screen/functionMQTT.dart/register_login.dart';
import 'package:pheasant_house/screen/forgotpassword/forgotpassword.dart';

class LoginScreen extends StatefulWidget {
  //const LoginScreen({super.key});
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LOginScreenState createState() => _LOginScreenState();
}

class _LOginScreenState extends State<LoginScreen> {
  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isPasswordVisible = false;

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
            {
              return Scaffold(
                body: SafeArea(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Form(
                        key: _formkey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 20),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Row(
                                        children: [
                                          Icon(Icons.arrow_back_ios,
                                              color: Colors.white, size: 30),
                                          Text('Back',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20)),
                                        ],
                                      ),
                                    ),
                                  ]),
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 30),
                              width: 330,
                              height: 250,
                              child: Image.asset('asset/images/Logo2.png'),
                            ),
                            buildText('Welcome To Automatics'),
                            buildText(' Pheasant House'),
                            buildTextFormField(
                                'Email', Icons.account_circle, emailController),
                            buildTextFormField(
                                'Password', Icons.lock, passwordController,
                                isPassword: true),
                            const SizedBox(
                              height: 10,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ForgotPasswordScreen()),
                                );
                              },
                              child: const Text(
                                'ลืมรหัสผ่าน?',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              height: 50,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_formkey.currentState!.validate()) {
                                    try {
                                      Profile newProfile = Profile(
                                        password: passwordController.text,
                                        email: emailController.text,
                                      );
                                      await FirebaseAuth.instance
                                          .signInWithEmailAndPassword(
                                              email: newProfile.email,
                                              password: newProfile.password)
                                          .then((value) {
                                        _formkey.currentState!.reset();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const HomeScreen(),
                                          ),
                                        );
                                      });
                                    } on FirebaseAuthException catch (e) {
                                      Fluttertoast.showToast(
                                        msg: e.message!,
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                      );
                                      print(e.toString());
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFFFFF),
                                    elevation: 5),
                                child: const Text(
                                  'เข้าสู่ระบบ',
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
          }
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
  }

  Widget buildText(String text) {
    return Text(text,
        style: const TextStyle(fontSize: 30, color: Colors.white));
  }

  Widget buildTextFormField(String hintText, IconData iconData, controller,
      {bool isPassword = false}) {
    TextInputType keyboardType = TextInputType.text;
    String? Function(String?)? validator;
    if (hintText == 'Email') {
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
    } else if (hintText == 'Password') {
      validator = (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters long';
        }
        if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%\^&\*])')
            .hasMatch(value)) {
          return 'Password must include at least one uppercase letter, one lowercase letter,one number,and one special character';
        }
        return null;
      };
    } else if (hintText == 'Phone') {
      validator = (value) {
        if (!RegExp(r'^(?=.*\d)').hasMatch(value!)) {
          return 'Phone must include at number';
        }
        if (value.length < 10) {
          return 'Phone must be at 10 characters';
        }
        return null;
      };
    } else {
      validator = (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $hintText';
        }

        return null;
      };
    }
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: isPassword ? !_isPasswordVisible : false,
            style: const TextStyle(color: Color.fromARGB(255, 4, 4, 4)),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                  color:
                      const Color.fromARGB(255, 13, 13, 13).withOpacity(0.5)),
              filled: true,
              fillColor: const Color(0xFFD9D9D9).withOpacity(0.5),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
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
              isDense: true,
              alignLabelWithHint: true,
            ),
            textAlignVertical: TextAlignVertical.center,
            validator: validator,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(75),
            child: Container(
              color: Colors.white,
              height: 75,
              width: 75,
              child: Center(
                child: Icon(
                  iconData,
                  color: Colors.black,
                  size: 40,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
