import 'package:flutter/material.dart';

import 'views/auth/splash_page.dart';

void main() {
runApp(const SafeDonateApp());
}

class SafeDonateApp extends StatelessWidget {
const SafeDonateApp({super.key});

@override
Widget build(BuildContext context) {
return MaterialApp(
debugShowCheckedModeBanner: false,

  title: 'SafeDonate',

  theme: ThemeData(
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor:
        const Color(0xFFF5F7FA),
    fontFamily: 'Roboto',
  ),

  home: const SplashPage(),
);

}
}
