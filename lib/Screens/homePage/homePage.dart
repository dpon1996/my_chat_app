import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_chat_app/Screens/chatScreen/chatScreen.dart';
import 'package:my_chat_app/Screens/contactPage/contactPage.dart';
import 'package:my_chat_app/control/navigationHelper.dart';
import 'package:my_chat_app/provider/homeProvider.dart';
import 'package:my_chat_app/res/sharedPrefKey.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeProvider _homeProvider;

  @override
  Widget build(BuildContext context) {
    _homeProvider = Provider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("My Chat"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          push(context, ContactPage());
        },
        child: Icon(Icons.message),
      ),
      body: StreamBuilder<QuerySnapshot>(
        //stream: FirebaseFirestore.instance.collection("chat").where("chatId",isGreaterThanOrEqualTo: _homeProvider.userId).where("chatId",isLessThanOrEqualTo: _homeProvider.userId+"\uf8ff").snapshots(),
        stream: FirebaseFirestore.instance.collection("chat").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 20),
            itemCount: snapshot.data.docs.length,
            itemBuilder: (BuildContext context, int index) {
              QueryDocumentSnapshot data = snapshot.data.docs[index];
              return ListTile(
                onTap: (){
                  push(context, ChatScreen(chat: data));
                },
                leading: CircleAvatar(),
                title: Text(data["chatId"]),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  _getUserData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var userId = sharedPreferences.getString(userIdKey);
    _homeProvider.setUserId(userId);
  }
}
