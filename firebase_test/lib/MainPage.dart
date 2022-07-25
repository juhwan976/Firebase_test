import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'ImagePage/ImagePage.dart';
import 'MyProfilePage/MyProfilePage.dart';
import 'PostPage/PostPage.dart';
import 'main.dart';

///*****************************************************************************
///
/// 메인 화면을 출력하기 전에, Drawer 와 Navigation 을 설정하는 페이지
///
///*****************************************************************************
///
class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GoogleSignIn _googleSignIn = new GoogleSignIn();

  int _selectedIndex = 0;

  void _onTap(int index) {
    setState(
      () {
        _selectedIndex = index;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: CupertinoButton(
                child: Text(
                  '로그아웃',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(context);

                  await _googleSignIn.signOut();
                  await FirebaseAuth.instance.signOut();

                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return MyHomePage();
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        unselectedFontSize: 12.0,
        selectedFontSize: 12.0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: '이미지 테스트',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: '내 프로필',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.comment),
            label: '게시판',
          ),
        ],
        onTap: _onTap,
        currentIndex: _selectedIndex,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          ImagePage(),
          MyProfilePage(),
          PostPage(),
        ],
      ),
    );
  }
}
