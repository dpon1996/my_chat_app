import 'package:flutter/material.dart';
import 'package:my_chat_app/Screens/splashScreen/splashScreen.dart';
import 'package:my_chat_app/provider/homeProvider.dart';
import 'package:my_chat_app/res/color.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: HomeProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
      ),
      home: SplashScreen(),
    );
  }
}
