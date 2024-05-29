import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pheasant_house/screen/welcome/welcome.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: emailController.text,
        );
        Fluttertoast.showToast(
          msg: 'ส่งลิงก์รีเซ็ตรหัสผ่านไปยังอีเมลของคุณแล้ว',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        ).then(
          (value) => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Welcomescreen(),
            ),
          ),
        );
        Navigator.of(context).pop();
      } on FirebaseAuthException catch (e) {
        Fluttertoast.showToast(
          msg: e.message!,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    }
  }

  Widget buildTextFormField(
      String hintText, IconData iconData, TextEditingController controller) {
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
    }
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Form(
              key: _formKey,
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
                                      color: Colors.white, fontSize: 20)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 30),
                    width: 330,
                    height: 250,
                    child: Image.asset('asset/images/Logo2.png'),
                  ),
                  buildText('Forgot Password'),
                  buildTextFormField(
                      'Email', Icons.account_circle, emailController),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFFFFF),
                        elevation: 5,
                      ),
                      child: const Text(
                        'รีเซ็ตรหัสผ่าน',
                        style: TextStyle(color: Colors.black, fontSize: 20),
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

  Widget buildText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 30, color: Colors.white),
    );
  }
}
