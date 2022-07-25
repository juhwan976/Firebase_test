import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../GlobalWidget/SubAppBar.dart';

class PostDetailPage extends StatefulWidget {
  PostDetailPage({
    Key? key,
    required String? postDateTime,
  })
      : _postDateTime = postDateTime,
        super(key: key);

  final String? _postDateTime;

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  TextEditingController _commentController = new TextEditingController();
  FocusNode _commentFocusNode = new FocusNode();
  StreamController<bool> _isAuthorStreamController =
  new StreamController<bool>();
  StreamController<bool> _isFavoriteStreamController =
  new StreamController<bool>();

  Widget _buildPage() {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('Posts')
          .doc(widget._postDateTime)
          .get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData) {
          var _data = snapshot.data!;
          if (FirebaseAuth.instance.currentUser!.uid ==
              _data['author']) {
            _isAuthorStreamController.sink.add(true);
          }

          if (_data.data().toString().contains('favorites')) {
            if (_data['favorites']
                .contains(FirebaseAuth.instance.currentUser!.uid)) {
              _isFavoriteStreamController.sink.add(true);
            } else {
              _isFavoriteStreamController.sink.add(false);
            }
          } else {
            _isFavoriteStreamController.sink.add(false);
          }

          return Container(
            child: Column(
              children: <Widget>[

                /// 게시글 내용이 보이는 곳
                Flexible(
                  child: Scrollbar(
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      children: <Widget>[

                        /// 제목
                        Container(
                          child: Text(
                            _data['title'],
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),

                        /// 작성자 및 작성시간
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '작성자 : ' + _data['nickName'],
                              ),
                              Text(
                                '작성 시간 : ' +
                                    _data['dateTime']
                                        .toString()
                                        .substring(0, 19),
                              ),
                            ],
                          ),
                        ),

                        /// 내용
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          height: 300,
                          child: Text(
                            _data['content'],
                          ),
                        ),

                        /// 댓글
                        Container(
                          child: (_data.data().toString().contains('comments')
                              ? Column(
                            children: List.generate(
                              _data['comments'].length,
                                  (int index) {
                                return Container(
                                  alignment: Alignment.centerLeft,
                                  height: 80,
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                        children: <Widget>[
                                          Text('작성자 : ' +
                                              _data['comments']
                                                  .elementAt(
                                                  index)['author']),
                                          Text(_data['comments']
                                              .elementAt(
                                              index)['dateTime']
                                              .substring(0, 19)),
                                        ],
                                      ),
                                      Text('내용 : ' +
                                          _data['comments']
                                              .elementAt(
                                              index)['comment']),
                                    ],
                                  ),
                                );
                              },
                            ),
                          )
                              : Text(''))
                        ),
                      ],
                    ),
                  ),
                ),

                /// 댓글 작성 공간
                Container(
                  color: Colors.white,
                  child: SafeArea(
                    child: Container(
                      height: 60,
                      child: Row(
                        children: <Widget>[

                          /// 댓글 입력
                          Container(
                            height: 60,
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.85,
                            child: TextField(
                              controller: _commentController,
                              focusNode: _commentFocusNode,
                              decoration: InputDecoration(
                                hintText: '댓글을 남겨주세요',
                              ),
                            ),
                          ),

                          /// 글 저장 버튼
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Icon(Icons.send),
                            onPressed: () async {
                              if (_commentController.text.length == 0) {} else {
                                late BuildContext _dialogContext;

                                _commentFocusNode.unfocus();

                                showDialog(
                                  context: context,
                                  builder: (BuildContext buildContext) {
                                    _dialogContext = buildContext;

                                    return AlertDialog(
                                      content: CupertinoActivityIndicator(),
                                    );
                                  },
                                );

                                FirebaseFirestore.instance
                                    .collection('Account')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .get()
                                    .then(
                                      (DocumentSnapshot thisSnapshot) {
                                    FirebaseFirestore.instance
                                        .collection('Posts')
                                        .doc(_data['dateTime'])
                                        .update(
                                      {
                                        'comments': FieldValue.arrayUnion([
                                          {
                                            'dateTime':
                                            DateTime.now().toString(),
                                            'author':
                                            _data['nickName'],
                                            'comment': _commentController.text
                                          }
                                        ])
                                      },
                                    ).whenComplete(
                                          () {
                                        Navigator.pop(_dialogContext);

                                        _commentController.clear();

                                        setState(() {});
                                        log('comment saved');
                                      },
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          child: Center(
            child: CupertinoActivityIndicator(),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _isAuthorStreamController.sink.add(false);
    _isFavoriteStreamController.sink.add(false);
  }

  @override
  void dispose() {
    super.dispose();

    _isAuthorStreamController.close();
    _isFavoriteStreamController.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SubAppBar(
        buildContext: context,
        title: '자세히보기',
        actions: <Widget>[
          StreamBuilder(
            stream: _isAuthorStreamController.stream,
            initialData: false,
            builder: (BuildContext buildContext, AsyncSnapshot<bool> snapshot) {
              if (snapshot.data!) {
                return CupertinoButton(
                  child: Text('게시글 설정'),
                  onPressed: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext context) {
                        return CupertinoActionSheet(
                          actions: <Widget>[
                            CupertinoActionSheetAction(
                              child: Text(
                                '게시글 삭제',
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();

                                showCupertinoDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CupertinoAlertDialog(
                                      title: Text('주의'),
                                      content: Column(
                                        children: <Widget>[
                                          Text('게시글을 삭제하면 복구할 수 없습니다.'),
                                          Text('계속하시겠습니까?'),
                                        ],
                                      ),
                                      actions: <Widget>[
                                        CupertinoButton(
                                          child: Text(
                                            '삭제',
                                            style: TextStyle(
                                              color: CupertinoColors.systemRed,
                                            ),
                                          ),
                                          onPressed: () {
                                            late BuildContext _dialogContext;

                                            Navigator.of(context).pop();

                                            showDialog(
                                              context: context,
                                              builder:
                                                  (BuildContext buildContext) {
                                                _dialogContext = buildContext;

                                                return AlertDialog(
                                                  content:
                                                  CupertinoActivityIndicator(),
                                                );
                                              },
                                            );

                                            FirebaseFirestore.instance
                                                .collection('Posts')
                                                .doc(widget._postDateTime)
                                                .delete()
                                                .whenComplete(
                                                  () {
                                                FirebaseFirestore.instance
                                                    .collection('Account')
                                                    .doc(FirebaseAuth.instance
                                                    .currentUser!.uid)
                                                    .update({
                                                  'posts':
                                                  FieldValue.arrayRemove([
                                                    widget._postDateTime
                                                  ]),
                                                }).whenComplete(
                                                      () {
                                                    Navigator.of(_dialogContext)
                                                        .pop();

                                                    Navigator.of(buildContext)
                                                        .pop(true);
                                                  },
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        CupertinoButton(
                                          child: Text('취소'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                          cancelButton: CupertinoActionSheetAction(
                            child: Text('닫기'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              } else {
                return StreamBuilder(
                    stream: _isFavoriteStreamController.stream,
                    initialData: false,
                    builder: (BuildContext buildContext,
                        AsyncSnapshot<bool> snapshot) {
                      if (snapshot.data!) {
                        /// 즐겨찾기 동륵이 되어있는 상태
                        return CupertinoButton(
                          child: Icon(Icons.favorite),
                          onPressed: () {
                            late BuildContext _dialogContext;

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                _dialogContext = context;

                                return AlertDialog(
                                  content: CupertinoActivityIndicator(),
                                );
                              },
                            );

                            FirebaseFirestore.instance
                                .collection('Posts')
                                .doc(widget._postDateTime)
                                .update(
                              {
                                'favorites': FieldValue.arrayRemove(
                                    [FirebaseAuth.instance.currentUser!.uid])
                              },
                            ).whenComplete(
                                  () {
                                FirebaseFirestore.instance
                                    .collection('Account')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .update(
                                  {
                                    'favorites': FieldValue.arrayRemove(
                                        [widget._postDateTime])
                                  },
                                ).whenComplete(
                                      () {
                                    Navigator.of(_dialogContext).pop();
                                    setState(() {});
                                  },
                                );
                              },
                            );
                          },
                        );
                      } else {
                        /// 즐겨찾기 동륵이 안된 상태
                        return CupertinoButton(
                          child: Icon(Icons.favorite_border),
                          onPressed: () {
                            late BuildContext _dialogContext;

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                _dialogContext = context;

                                return AlertDialog(
                                  content: CupertinoActivityIndicator(),
                                );
                              },
                            );

                            FirebaseFirestore.instance
                                .collection('Posts')
                                .doc(widget._postDateTime)
                                .update(
                              {
                                'favorites': FieldValue.arrayUnion(
                                    [FirebaseAuth.instance.currentUser!.uid])
                              },
                            ).whenComplete(
                                  () {
                                FirebaseFirestore.instance
                                    .collection('Account')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .update(
                                  {
                                    'favorites': FieldValue.arrayUnion(
                                        [widget._postDateTime])
                                  },
                                ).whenComplete(
                                      () {
                                    Navigator.of(_dialogContext).pop();
                                    setState(() {});
                                  },
                                );
                              },
                            );
                          },
                        );
                      }
                    });
                /*
                return CupertinoButton(
                  child: Text('즐겨찾기 등록'),
                  onPressed: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext context) {
                        return CupertinoActionSheet(
                          cancelButton: CupertinoActionSheetAction(
                            child: Text('닫기'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          actions: <Widget>[
                            CupertinoActionSheetAction(
                              child: Text('TEST'),
                              onPressed: () {},
                            ),
                          ],
                        );
                      },
                    );
                  },
                );

                 */
              }
            },
          ),
        ],
      ),
      body: _buildPage(),
    );
  }
}
