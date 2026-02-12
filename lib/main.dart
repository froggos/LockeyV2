import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lockey_app/screens/password_list.dart';
import 'package:lockey_app/store/storage.dart';

void main() async {
    // await LockeyStorage.clearData();

  runApp(const Lockey());
}

class Lockey extends StatelessWidget {
  const Lockey({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lockey',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF161A27),
          brightness: Brightness.dark,
        ).copyWith(
          surface: const Color(0xFF161A27),
        ),
        scaffoldBackgroundColor: const Color(0xFF161A27),
        textTheme: GoogleFonts.latoTextTheme(),
      ),
      home: const PasswordList(),
    );
  }
}
