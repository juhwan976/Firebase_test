import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names
AppBar SubAppBar({
  required BuildContext buildContext,
  required String title,
  List<Widget>? actions,
}) {
  return AppBar(
    centerTitle: true,
    titleSpacing: 0,
    title: Text(
      title,
      style: TextStyle(
        color: Colors.black,
      ),
    ),
    backgroundColor: Colors.white,
    elevation: 0,
    leading: CupertinoButton(
      child: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(buildContext);
      },
    ),
    actions: actions,
  );
}
