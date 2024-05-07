import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreen();
}

class _RegisterScreen extends State<RegisterScreen> {
  String groupValue = 'yes';
  @override
  Widget build(BuildContext context) {
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
        title: const Text('ลงทะเบียน', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildInputText('Username', 'Your Username'),
                buildInputText('Password', 'Your Password'),
                buildInputText('Name', 'Your Name'),
                buildInputText('Lastname', 'Your Lastname'),
                buildInputText('Gender', 'Your Gender'),
                buildInputText('Email', 'Your Email'),
                buildInputText('Phone', 'Your Phone'),
                buildInputText('Address', 'Your Address'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Radio(
                              value: '1',
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
                              value: '2',
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
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFFFF),
                      elevation: 5,
                    ),
                    child: const Text(
                      'ลงทะเบียน',
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

  Widget buildInputText(String name, String nameHint) {
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
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: nameHint,
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              cursorColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
