import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_chat_app/Screens/chatScreen/chatScreen.dart';
import 'package:my_chat_app/Screens/splashScreen/showSnackBarMessage.dart';
import 'package:my_chat_app/control/navigationHelper.dart';
import 'package:my_chat_app/control/printString.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  bool _loading = false;
  List<Contact> searchContacts = [];
  List<Contact> contacts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text("Contact"),
      ),
      body: Column(
        children: [
          TextField(
            onChanged: (val) {
              _search(val);
            },
            decoration: InputDecoration(hintText: "Search contact..."),
          ),
          if (_loading)
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 8),
                height: 20,
                width: 20,
                child: CircularProgressIndicator(),
              ),
            ),
          Expanded(
            child: ListView.separated(
              itemCount: searchContacts.length,
              itemBuilder: (BuildContext context, int index) {
                return Visibility(
                  visible: searchContacts[index].phones.isNotEmpty,
                  child: ListTile(
                    onTap: () {
                      _checkUserAvailable(
                          searchContacts[index].phones.first.value);
                    },
                    title: Text(searchContacts[index].displayName == null
                        ? "${searchContacts[index].phones}"
                        : '${searchContacts[index].displayName}'),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Visibility(
                  visible: searchContacts[index].phones.isNotEmpty,
                  child: Divider(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getPermission();
  }

  _getPermission() async {
    var contactStatus = await Permission.contacts.request();
    if (contactStatus.isGranted) {
      _getContacts();
    }
  }

  _getContacts() async {
    setState(() {
      _loading = true;
    });
    var list = await ContactsService.getContacts();
    setState(() {
      contacts = list.toList();
      searchContacts = contacts;
    });
    setState(() {
      _loading = false;
    });
    setState(() {});
  }

  _checkUserAvailable(String phoneNumber) async {
    phoneNumber = phoneNumber.replaceAll(" ", "");
    if (phoneNumber.length == 10) {
      phoneNumber = "+91$phoneNumber";
    }
    PrintString(phoneNumber);
    await Firebase.initializeApp();
    QuerySnapshot data = await FirebaseFirestore.instance
        .collection("user")
        .where('phone', isEqualTo: phoneNumber)
        .get();

    if (data.docs.length != 0) {
      pushAndReplace(
        context,
        ChatScreen(
          selectedUserId: data.docs.first.id,
        ),
      );
    } else {
      showSnackBarMessage(context, "This number is not available");
    }
  }

  _search(String val) {
    searchContacts = [];
    contacts.forEach((element) {
      if (element.displayName != null &&
          element.displayName.toLowerCase().contains(val.toLowerCase())) {
        setState(() {
          searchContacts.add(element);
        });
      }
    });
  }
}
