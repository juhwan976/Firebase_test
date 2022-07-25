import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import 'LogInPage/AccountPage.dart';
import 'LogInPage/LogInPage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /// 게시판 페이지에서 당겨서 새로고침을 사용하기 위해서 RefreshConfiguration 사용
    return RefreshConfiguration(
      footerTriggerDistance: 15,
      dragSpeedRatio: 0.91,
      headerBuilder: () => MaterialClassicHeader(),
      footerBuilder: () => ClassicFooter(),
      enableLoadingWhenNoData: false,
      enableRefreshVibrate: false,
      enableLoadMoreVibrate: false,
      shouldFooterFollowWhenNotFull: (state) {
        // If you want load more with noMoreData state ,may be you should return false
        return false;
      },
      child: MaterialApp(
        theme: ThemeData(
          appBarTheme: AppBarTheme(
          ),
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// 초기화를 해주어야한다.
      body: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (BuildContext context, AsyncSnapshot<FirebaseApp> snapshot) {
          /// 에러가 있을 경우.
          if (snapshot.hasError) {
            log('Error!');
          }

          /// 연결 성공일 경우.
          if (snapshot.connectionState == ConnectionState.done) {
            return StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
                /// 유저가 null 일 경우 로그인이 필요.
                if (snapshot.data == null) {
                  return LogInPage();
                }

                /// 그 외의 경우 로그인이 되어있는 것으로 간주.
                else {
                  return AccountPage();
                }
              },
            );
          }

          /// 응답을 받기전에는 로딩화면을 출력.
          return Center(
            child: CupertinoActivityIndicator(),
          );
        },
      ),
    );
  }
}