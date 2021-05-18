import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_chat_app/Screens/auth/registerProfile.dart';
import 'package:my_chat_app/Screens/homePage/homePage.dart';
import 'package:my_chat_app/Screens/splashScreen/showSnackBarMessage.dart';
import 'package:my_chat_app/control/navigationHelper.dart';
import 'package:my_chat_app/control/printString.dart';
import 'package:my_chat_app/res/color.dart';
import 'package:my_chat_app/res/sharedPrefKey.dart';
import 'package:my_chat_app/supporingWidgets/mainButton.dart';

import 'package:flutter_otp/flutter_otp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FlutterOtp _flutterOtp = FlutterOtp();
  var border =
      OutlineInputBorder(borderSide: BorderSide(color: secondaryColor));

  TextEditingController _ctrl = TextEditingController();
  bool _loading = false;
  bool _verifyLoading = false;
  bool _verificationFailed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Icon(
                    Icons.fingerprint_sharp,
                    color: secondaryColor,
                    size: 60,
                  ),
                  SizedBox(height: 35),
                  Text(
                    "Sign in with phone number",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Lorem ipsum, or lipsum as it is sometimes known, \nis dummy text used in laying",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white24, height: 1.3, fontSize: 13),
                  ),
                  SizedBox(height: 60),
                  TextField(
                    controller: _ctrl,
                    cursorColor: secondaryColor,
                    cursorWidth: 1,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: border,
                      enabledBorder: border,
                      focusedBorder: border,
                      labelText: "Phone number",
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  MainButton(
                    title: "Login",
                    loading: _loading,
                    onTap: () {
                      if (!_loading) {
                        _getOtp();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          ///
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: AnimatedContainer(
              padding: EdgeInsets.only(top: 30),
              height: _verificationFailed ? 90 : 0,
              color: Colors.red,
              duration: Duration(milliseconds: 700),
              child: Center(
                child: Text(
                  "Enter a valid OTP",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  _getOtp() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
    });
    await Firebase.initializeApp();
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91${_ctrl.text}",
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  verificationCompleted(PhoneAuthCredential phoneAuthCredential) async {
    UserCredential userData =
        await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
    _saveUserData(userData.user);
    PrintString(userData.user);
    setState(() {
      _loading = false;
    });
  }

  verificationFailed(FirebaseAuthException error) {
    showSnackBarMessage(context, "something went wrong ${error.message}");
    PrintString("something went wrong ${error.message}");
    setState(() {
      _loading = false;
    });
  }

  codeSent(String verificationId, int forceResendingToken) {
    setState(() {
      _loading = false;
    });
    showOtpSheet(verificationId);
  }

  codeAutoRetrievalTimeout(String verificationId) {
    setState(() {
      _loading = false;
    });
  }

  ///bottom sheet

  showOtpSheet(String verificationId) async {
    setState(() {
      _verificationFailed = false;
    });
    TextEditingController controller = TextEditingController();

    showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, _) {
            return Padding(
              padding: EdgeInsets.only(
                left: 8,
                right: 8,
                top: 20,
                bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Enter OTP"),
                    SizedBox(height: 16),
                    TextField(
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      controller: controller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Enter OTP here",
                      ),
                    ),
                    SizedBox(height: 16),
                    MainButton(
                      title: "VERIFY",
                      color: primaryColor,
                      titleColor: Colors.white,
                      loading: _verifyLoading,
                      onTap: () {
                        PrintString(controller.text);
                        if (!_verifyLoading) {
                          _verifyOTP(verificationId, controller.text);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// verify otp function

  _verifyOTP(String verificationId, String otp) async {
    FocusScope.of(context).unfocus();
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: otp);
    try {
      UserCredential userData =
          await FirebaseAuth.instance.signInWithCredential(credential);
      _saveUserData(userData.user);
      setState(() {
        _verificationFailed = false;
      });
    } catch (e) {
      setState(() {
        _verificationFailed = true;
      });
      PrintString("msg ss : $e");
    }
  }

  _saveUserData(User userData) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString(userIdKey, userData.uid);
      var userCollection = FirebaseFirestore.instance.collection("user");
      QuerySnapshot res = await userCollection
          .where("phone", isEqualTo: userData.phoneNumber)
          .get();
      PrintString(res.docs.length);
      if (res.docs.length == 0) {
        userCollection.add({
          "id": userData.uid,
          "phone": userData.phoneNumber,
        });

        pushAndRemoveUntil(
          context,
          HomePage(),
        );

      }else{
        pushAndRemoveUntil(
          context,
          HomePage(),
        );
      }


    } catch (e) {
      PrintString(e);
      showSnackBarMessage(context, "Something went wrong", color: Colors.red);
    }
  }

// _loginFun() async {
//   await Firebase.initializeApp();
//   GoogleSignIn _googleSignIn = GoogleSignIn();
//
//   try {
//     GoogleSignInAccount user = await _googleSignIn.signIn();
//     PrintString(user.id);
//     PrintString(user.email);
//     PrintString(user.photoUrl);
//
//     if (user != null) {
//       final googleAuth = await user.authentication;
//       final credential = GoogleAuthProvider.credential(
//         idToken: googleAuth.idToken,
//         accessToken: googleAuth.accessToken,
//       );
//
//       UserCredential data =
//           await FirebaseAuth.instance.signInWithCredential(credential);
//       _saveUserData(data.user);
//     }
//   } catch (e) {
//     PrintString(e);
//   }
// }
//

}
