import 'package:flutter/material.dart';
import 'package:pheasant_house/screen/registerscreen/register.dart';

import '../../constants.dart';
import '../loginscreen/login.dart';

class Welcomescreen extends StatefulWidget {
  const Welcomescreen({super.key});

  @override
  State<Welcomescreen> createState() => _WelcomescreenState();
}

class _WelcomescreenState extends State<Welcomescreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 120),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 50),
                  width: 330,
                  height: 200,
                  child: Image.asset(
                    'asset/images/Logo2.png',
                  ),
                ),
                Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 50),
                      width: 330,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Image.asset('asset/images/watermark.png',
                          opacity: const AlwaysStoppedAnimation(0.45),
                          fit: BoxFit.none),
                    ),
                    const Positioned.fill(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Column(
                          children: [
                            Text(
                              'Welcome',
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'To Automatic',
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Pheasant House',
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 90,
        child: Container(
          color: const Color(0xFF086D71).withOpacity(0.6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBottomColor,
                  elevation: 5,
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'เข้าสู่ระบบ',
                    style: TextStyle(color: Colors.black, fontSize: 22),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBottomColor,
                  elevation: 5,
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'ลงทะเบียน',
                    style: TextStyle(color: Colors.black, fontSize: 22),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildText(String text) {
  return Text(text, style: const TextStyle(fontSize: 36, color: Colors.white));
}
