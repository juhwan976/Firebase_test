import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../GlobalClass/AppUser.dart';
import '../GlobalWidget/MainAppBar.dart';
import 'EditProfilePage.dart';

///*****************************************************************************
///
/// 내 정보를 출력하는 페이지
///
///*****************************************************************************
///
class MyProfilePage extends StatefulWidget {
  MyProfilePage({Key? key}) : super(key: key);

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  AppUser _user = new AppUser();

  Widget _buildPage() {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('Account')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        /// 에러가 있을 경우
        if (snapshot.hasError) {
          log('Error!');
        }

        /// 데이터가 존재 할 경우
        if (snapshot.hasData) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

          _user.setNickName = data['nickName'];
          _user.setPosts = data['posts'];

          return Container(
            child: Scrollbar(
              child: ListView(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                children: <Widget>[
                  /// 사용자 닉네임 출력
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: Text('닉네임 : '),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: Text(data['nickName']),
                      ),
                    ],
                  ),

                  /// 내가 작성한 게시글 리스트 불러오기
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Column(
                      children: List.generate(
                        ((data['posts'] == null || data['posts'].isEmpty)
                                ? 1
                                : data['posts'].length) +
                            1,
                        (int index) {
                          if (index == 0) {
                            return Container(
                              child: Text('내가 작성한 게시글'),
                            );
                          } else {
                            if (data['posts'] == null ||
                                data['posts'].isEmpty) {
                              return Container(
                                child: Text('아직 작성한 게시글이 없습니다.'),
                              );
                            } else {
                              return Container(
                                child: Text(data['posts'].elementAt(index - 1)),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ),

                  /// 내가 즐겨찾기 한 게시글 리스트 불러오기
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Column(
                      children: List.generate(
                        ((data['favorites'] == null || data['favorites'].isEmpty)
                            ? 1
                            : data['favorites'].length) +
                            1,
                            (int index) {
                          if (index == 0) {
                            return Container(
                              child: Text('내가 즐겨찾기 한 게시글'),
                            );
                          } else {
                            if (data['favorites'] == null ||
                                data['favorites'].isEmpty) {
                              return Container(
                                child: Text('아직 즐겨찾기한 게시글이 없습니다.'),
                              );
                            } else {
                              return Container(
                                child: Text(data['favorites'].elementAt(index - 1)),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Center(
          child: CupertinoActivityIndicator(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        context: context,
        title: '내 프로필 페이지',
        actions: <Widget>[
          CupertinoButton(
            child: Text('수정'),
            onPressed: () async {
              /// value 는 변경정보가 있을경우 true 값이 되는데
              /// 아무런 변경이 없을 경우 null 이 된다.
              /// 하지만 bool 은 null 이 될 수 없어서 var 으로 해주었다.
              var value = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return EditProfilePage(appUser: _user);
                  },
                ),
              );

              if (value == true) {
                _user.updateNickName().whenComplete(
                  () {
                    log('update Complete!');
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
