import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../GlobalClass/AppUser.dart';
import '../GlobalWidget/SubAppBar.dart';

class EditProfilePage extends StatefulWidget {
  EditProfilePage({Key? key, AppUser? appUser})
      : _appUser = appUser,
        super(key: key);

  final AppUser? _appUser;

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController? _nickNameController;
  GlobalKey<FormState> _nickNameKey = new GlobalKey<FormState>();

  Widget _buildPage() {
    _nickNameController =
        TextEditingController(text: widget._appUser!.getNickName);

    return Container(
      child: Scrollbar(
        child: ListView(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
          children: <Widget>[
            /// 닉네임 수정
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 250,
                  child: Form(
                    key: _nickNameKey,
                    child: TextFormField(
                      controller: _nickNameController,
                      maxLength: 8,
                      decoration: InputDecoration(
                        icon: Text('닉네임'),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                        counterText: '',
                        suffixIcon: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.close),
                          onPressed: () {
                            _nickNameController!.clear();
                          },
                        ),
                      ),
                      validator: (String? value) {
                        if (value!.isEmpty)
                          return '닉네임을 입력해주세요.';
                        else
                          return null;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SubAppBar(
        buildContext: context,
        title: '내 정보 수정',
        actions: <Widget>[
          CupertinoButton(
            child: Text('저장'),
            onPressed: () {
              if (_nickNameKey.currentState!.validate()) {
                widget._appUser!.setNickName = _nickNameController!.text;

                Navigator.of(context).pop(true);
              }
            },
          ),
        ],
      ),
      body: _buildPage(),
    );
  }
}
