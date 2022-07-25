import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../MainPage.dart';

///*****************************************************************************
///
/// 새로운 유저 일 경우 정보를 입력받는 화면을 출력하는 페이지
///
///*****************************************************************************
///
class AccountPage extends StatefulWidget {
  AccountPage({Key? key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  TextEditingController _nickNameController = new TextEditingController();

  Widget _buildNewAccountPage() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 10, 50, 0),
      child: Scrollbar(
        child: ListView(
          children: <Widget>[
            /// 닉네임 만들기
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('닉네임'),
                Container(
                  height: 50,
                  width: 200,
                  child: TextField(
                    controller: _nickNameController,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage() {
    return Container(
      child: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('Account')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            /// 데이터가 존재한다면 메인 페이지 출력
            if (snapshot.data!.exists) {
              /// setState 가 끝난후에 실행
              WidgetsBinding.instance.addPostFrameCallback(
                (Duration duration) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return MainPage();
                      },
                    ),
                  );
                },
              );
            }

            /// 데이터가 존재하지 않는다면 새 계정을 만드는 페이지 출력
            else {
              return _buildNewAccountPage();
            }
          }

          return Center(
            child: CupertinoActivityIndicator(),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        centerTitle: true,
        title: Text(
          '계정 생성',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        leading: CupertinoButton(
          child: Icon(Icons.arrow_back),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('경고'),
                  content: Text('초기화면으로 돌아가시겠습니까?'),
                  actions: <Widget>[
                    /// '예' 버튼, 초기화면으로 돌아가는 것을 원할 경우
                    CupertinoButton(
                      child: Text('예'),
                      onPressed: () async {
                        Navigator.pop(context);

                        GoogleSignIn _googleSignIn = new GoogleSignIn();

                        await _googleSignIn.signOut();
                        await FirebaseAuth.instance.signOut();
                      },
                    ),

                    /// '아니오' 버튼, 초기화면으로 돌아가는 것을 원하지 않을 경우
                    CupertinoButton(
                      child: Text('아니오'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
        actions: <Widget>[
          CupertinoButton(
            child: Text('저장'),
            onPressed: () async {
              bool _flag = false;
              if (_nickNameController.text.length == 0) _flag = true;

              if (!_flag) {
                await FirebaseFirestore.instance
                    .collection('Account')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .set({
                  'nickName': _nickNameController.text,
                }).whenComplete(
                  () {
                    setState(() {});
                  },
                );
              }
            },
          ),
        ],
      ),
      body: _buildPage(),
    );
  }
}
