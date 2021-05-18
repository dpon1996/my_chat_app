import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_5.dart';
import 'package:my_chat_app/control/printString.dart';
import 'package:my_chat_app/provider/homeProvider.dart';
import 'package:my_chat_app/res/color.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final selectedUserId;
  final QueryDocumentSnapshot chat;

  const ChatScreen({Key key, this.selectedUserId, this.chat}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  QueryDocumentSnapshot chatData;
  TextEditingController _controller = TextEditingController();
  HomeProvider _homeProvider;
  Stream _stream;

  @override
  Widget build(BuildContext context) {
    _homeProvider = Provider.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text("Chat"),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
            left: 8,
            right: 8,
            top: 8,
            bottom: 8 + MediaQuery.of(context).viewInsets.bottom),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12)],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: "Write a message..."),
              ),
            ),
            SizedBox(width: 8),
            InkWell(
              onTap: () {
                if (_controller.text.isNotEmpty) {
                  _validate();
                }
              },
              child: CircleAvatar(
                backgroundColor: primaryColor,
                child: Icon(
                  Icons.send,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          if(_stream != null)StreamBuilder<QuerySnapshot>(
            stream: _stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 20),
                itemCount: snapshot.data.docs.length,
                reverse: true,
                itemBuilder: (BuildContext context, int index) {
                  QueryDocumentSnapshot data = snapshot.data.docs[index];

                  return ChatBubble(
                    backGroundColor: data["userId"] == _homeProvider.userId
                        ? secondaryColor
                        : Colors.grey[200],
                    alignment: data["userId"] == _homeProvider.userId
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 10, left: 8, right: 8),
                    clipper: ChatBubbleClipper5(
                      type: data["userId"] == _homeProvider.userId
                          ? BubbleType.sendBubble
                          : BubbleType.receiverBubble,
                    ),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      child: Text(
                        data["msg"],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    chatData = widget.chat;
    if (chatData != null) {
      _stream = FirebaseFirestore.instance
          .collection("chat/${widget.chat.id}/messages")
          .orderBy("date", descending: true)
          .snapshots();
    }

    Firebase.initializeApp();
  }

  _validate() async {
    var chat = FirebaseFirestore.instance.collection("chat");
    if (chatData == null) {
      QuerySnapshot data = await chat
          .where("chatId",
              isEqualTo: "${widget.selectedUserId}${_homeProvider.userId}")
          .get();
      QuerySnapshot data1 = await chat
          .where("chatId",
              isEqualTo: "${_homeProvider.userId}${widget.selectedUserId}")
          .get();

      if (data.docs.length != 0) {
        QuerySnapshot chatData = await chat
            .where("chatId",
                isEqualTo: "${widget.selectedUserId}${_homeProvider.userId}")
            .get();
        _sendMessage(chatData.docs.first);
      } else if (data1.docs.length != 0) {
        QuerySnapshot chatData = await chat
            .where("chatId",
                isEqualTo: "${_homeProvider.userId}${widget.selectedUserId}")
            .get();
        _sendMessage(chatData.docs.first);
      } else {
        await chat.add({
          "chatId": "${widget.selectedUserId}${_homeProvider.userId}",
          "uid1": widget.selectedUserId,
          "uid2": _homeProvider.userId,
        });

        QuerySnapshot chatData = await chat
            .where("chatId",
                isEqualTo: "${widget.selectedUserId}${_homeProvider.userId}")
            .get();

        PrintString(chatData.docs.first.id);

        this.chatData = chatData.docs.first;

        setState(() {
          _stream = FirebaseFirestore.instance
              .collection("chat/${this.chatData.id}/messages")
              .orderBy("date", descending: true)
              .snapshots();
        });

        _sendMessage(chatData.docs.first);
      }
    } else {
      _sendMessage(chatData);
    }

  }

  _sendMessage(QueryDocumentSnapshot chatData) async {
    PrintString(DateTime.now().microsecondsSinceEpoch);
    var chat =
        FirebaseFirestore.instance.collection("chat/${chatData.id}/messages");
    chat.add({
      "msg": _controller.text,
      "userId": _homeProvider.userId,
      "date": DateTime.now().microsecondsSinceEpoch,
    });
    _controller.clear();
  }
}
