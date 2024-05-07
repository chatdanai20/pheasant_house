import 'package:flutter/material.dart';
import 'package:pheasant_house/screen/homescreen/homescreen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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
                buildTextFormField('Email', Icons.account_circle),
                buildTextFormField('Password', Icons.lock, isPassword: true),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'ลืมรหัสผ่าน?',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFFFFF), elevation: 5),
                    child: const Text(
                      'เข้าสู่ระบบ',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildText(String text) {
  return Text(text, style: const TextStyle(fontSize: 30, color: Colors.white));
}

Widget buildTextFormField(String hintText, IconData iconData,
    {bool isPassword = false}) {
  return Stack(
    alignment: Alignment.centerLeft,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: TextFormField(
          obscureText: isPassword,
          style: const TextStyle(color: Color(0xFFD9D9D9)),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
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
            contentPadding: const EdgeInsets.symmetric(vertical: 20),
          ),
          textAlign: TextAlign.center,
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
