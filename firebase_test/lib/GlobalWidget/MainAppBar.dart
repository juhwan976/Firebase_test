import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///*****************************************************************************
///
/// 앱에서 전체적으로 사용하는 앱바를 빌드하는 메서드
///
/// @params
/// @required BuildContext  context  : AppBar 를 사용하려는 페이지의 context
///           String        title    : AppBar 에 표시될 제목
///           List<Widget>  actions  : AppBar 에 표시될 actions
///
/// @기타 설정
/// elevation       : 0
/// titleSpacing    : 0
/// centerTitle     : true
/// backgroundColor : Colors.white
/// leading         : 터치하면 Drawer 를 보이게 하는 버튼
///
///*****************************************************************************
///
// ignore: non_constant_identifier_names
AppBar MainAppBar({
  required BuildContext context,
  required String title,
  List<Widget>? actions,
}) {
  return AppBar(
    elevation: 0,
    titleSpacing: 0,
    centerTitle: true,
    title: Text(
      title,
      style: TextStyle(
        color: Colors.black,
      ),
    ),
    backgroundColor: Colors.white,
    leading: CupertinoButton(
      child: Icon(Icons.menu),
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
    ),
    actions: actions,
  );
}
