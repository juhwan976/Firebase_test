import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_sign_in/google_sign_in.dart';

///*****************************************************************************
///
/// 로그인 버튼이 나오는 페이지
///
///*****************************************************************************
///
class LogInPage extends StatefulWidget {
  LogInPage({
    Key? key,
  }) : super(key: key);

  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final GoogleSignIn _googleSignIn = new GoogleSignIn();

  Future<bool> googleSignIn() async {
    GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();

    if (googleSignInAccount != null) {
      GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      UserCredential result =
          await FirebaseAuth.instance.signInWithCredential(credential);

      User user = result.user!;
      log("uid : ${user.uid}");

      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Container(
            height: 50,
            child: SignInButton(
              Buttons.Google,
              onPressed: () async {
                late BuildContext _dialogContext;

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    _dialogContext = context;

                    return AlertDialog(
                      content: CupertinoActivityIndicator(),
                    );
                  },
                );

                googleSignIn().then(
                  (bool loginResult) {
                    Navigator.pop(_dialogContext);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
