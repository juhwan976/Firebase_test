import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewPostPage extends StatefulWidget {
  NewPostPage({Key? key}) : super(key: key);

  @override
  _NewPostPage createState() => _NewPostPage();
}

class _NewPostPage extends State<NewPostPage> {
  TextEditingController _titleController = new TextEditingController();
  TextEditingController _contentController = new TextEditingController();

  Widget _buildPage() {
    return Container(
      child: Scrollbar(
        child: ListView(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
          children: <Widget>[
            Container(
              child: TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  icon: Text('제목'),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  icon: Text('내용'),
                ),
                minLines: 10,
                maxLines: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        titleSpacing: 0,
        title: Text(
          '새 게시글 작성',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: CupertinoButton(
          child: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          CupertinoButton(
            child: Text('게시하기'),
            onPressed: () async {
              DateTime now = DateTime.now();
              DocumentSnapshot _snapshot = await FirebaseFirestore.instance
                  .collection('Account')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .get();

              Map<String, dynamic> _data = _snapshot.data as Map<String, dynamic>;

              await FirebaseFirestore.instance
                  .collection('Posts')
                  .doc(now.toString())
                  .set(
                {
                  'author': FirebaseAuth.instance.currentUser!.uid,
                  'nickName' : _data['nickName'],
                  'title': _titleController.text,
                  'content': _contentController.text.trimRight(),
                  'likeNum': 0,
                  'commentNum': 0,
                  'dateTime' : now.toString(),
                },
              );

              await FirebaseFirestore.instance
                  .collection('Account')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .update(
                {'posts': FieldValue.arrayUnion([now.toString()])},
              );

              log('upload done!');

              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: _buildPage(),
    );
  }
}
