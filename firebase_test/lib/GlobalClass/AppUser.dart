import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  /// 닉네임
  String? _nickName;

  /// 작성한 게시글
  List<dynamic>? _posts = [];

  /// 유저 닉네임을 업데이트하는 메서드
  Future<bool> updateNickName() async {
    await FirebaseFirestore.instance
        .collection('Account')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'nickName': _nickName}).whenComplete(
      () {
        return true;
      },
    ).onError(
      (dynamic _, __) {
        return false;
      },
    );

    return false;
  }

  /// 유저가 작성한 게시글을 업데이트하는 메서드
  Future<bool> updatePosts() async {
    await FirebaseFirestore.instance
        .collection('Account')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'posts': _posts}).whenComplete(
      () {
        return true;
      },
    ).onError(
      (dynamic _, __) {
        return false;
      },
    );

    return false;
  }

  /// setter
  set setNickName(String? nickName) => {_nickName = nickName};

  set setPosts(List<dynamic>? posts) => {_posts = posts};

  /// getter
  get getNickName => _nickName;

  get getPosts => _posts;
}
