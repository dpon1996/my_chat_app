import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_chat_app/Screens/auth/login.dart';
import 'package:my_chat_app/Screens/homePage/homePage.dart';
import 'package:my_chat_app/control/navigationHelper.dart';
import 'package:my_chat_app/res/color.dart';
import 'package:my_chat_app/res/sharedPrefKey.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: DefaultTextStyle(
          style: TextStyle(color: Colors.white),
          child: AnimatedTextKit(
            repeatForever: true,
            animatedTexts: [
              TyperAnimatedText(
                "Chat with my chat app",
                textAlign: TextAlign.center,
                speed: Duration(
                  milliseconds: 100,
                ),
              )
            ],
          ),
        ),
      ),
      body: Center(
        child: CircleAvatar(
          backgroundColor: secondaryColor,
          radius: 50,
          child: Icon(
            Icons.chat_outlined,
            color: primaryColor,
            size: 35,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();

    Timer(
      Duration(seconds: 3),
      () {
        _getUserData();
      },
    );
  }

  _getUserData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    var userId = sharedPreferences.getString(userIdKey);

    if (userId != null && userId.isNotEmpty) {
      pushAndReplace(context, HomePage());
    } else {
      pushAndReplace(context, LoginPage());
    }
  }
}
