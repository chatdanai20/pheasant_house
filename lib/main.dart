import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pheasant_house/constants.dart';
import 'screen/welcome/welcome.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  runApp(const MyApp());
   initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.promptTextTheme(),
        scaffoldBackgroundColor: kDefaultColor,
      ),
      color: const Color(0xFF7EA48F),
      home: const Welcomescreen(),

    );
  }
}
