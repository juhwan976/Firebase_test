import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../GlobalWidget/MainAppBar.dart';
import 'NewPostPage.dart';
import 'PostDetailPage.dart';

class PostPage extends StatefulWidget {
  PostPage({Key? key}) : super(key: key);

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  ScrollController _postPageScrollController = ScrollController();
  bool _loadDone = false;

  String _makePreviewContent(String content) {
    String _preview;

    /// 글자의 길이가 단순하게 44 자 보다 길 경우
    if (content.length >= 44) {
      /// 줄바꿈이 너무 많을 때에도 판별
      if (content.split('\n').length >= 4) {
        _preview = content.split('\n')[0] +
            '\n' +
            content.split('\n')[1] +
            '\n' +
            content.split('\n')[2] +
            ' ...';
      } else {
        _preview = content.substring(0, 44) + ' ...';
      }
    } else {
      /// 줄바꿈이 너무 많을 때에도 판별
      if (content.split('\n').length >= 4) {
        _preview = content.split('\n')[0] +
            '\n' +
            content.split('\n')[1] +
            '\n' +
            content.split('\n')[2] +
            ' ...';
      } else {
        _preview = content;
      }
    }

    return _preview;
  }

  Widget _buildPage() {
    /*
    return Container(
      child: CupertinoButton(
        child: Text('불러오기'),
        onPressed: () async {
          var first = FirebaseFirestore.instance
              .collection('Posts')
              .orderBy('dateTime', descending: true)
              .limit(2);

          first.get().then(
            (QuerySnapshot snapshot) {
              log(snapshot.size.toString());
              log(snapshot.docs[0].id);
              log(snapshot.docs[1].id);

              var lastVisible = snapshot.docs[snapshot.size - 1];

              var next = FirebaseFirestore.instance
                  .collection('Posts')
                  .orderBy('dateTime', descending: true)
                  .startAfter([snapshot.docs[snapshot.size - 1].id]).limit(2);

              next.get().then(
                    (QuerySnapshot snapshot) {
                      log(snapshot.size.toString());
                      log(snapshot.docs[0].id);
                      log(snapshot.docs[1].id);
                    },
                  );
            },
          );
        },
      ),
    );
    */
    return Container(
      child: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('Posts')
            .orderBy('dateTime', descending: true)
            .limit(20)
            .get()
            .whenComplete(
          () {
            _loadDone = true;
          },
        ),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            log('Error!');
          }

          if (snapshot.hasData) {
            var _dataList = snapshot.data!.docs;
            return Scrollbar(
              controller: _postPageScrollController,
              child: SmartRefresher(
                controller: _refreshController,
                header: ClassicHeader(),
                enablePullDown: true,
                enablePullUp: true,
                onRefresh: () async {
                  _loadDone = false;
                  setState(() {});

                  Timer.periodic(
                    Duration(milliseconds: 100),
                    (Timer _timer) {
                      if (_loadDone) {
                        _timer.cancel();
                        log('refresh done!');
                        _refreshController.refreshCompleted();
                      }
                    },
                  );
                },
                onLoading: () async {
                  Timer.periodic(
                    Duration(seconds: 1),
                    (Timer _timer) {
                      _refreshController.loadComplete();
                    },
                  );
                },
                child: ListView.builder(
                  controller: _postPageScrollController,
                  itemCount: _dataList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      child: Container(
                        height: 87,
                        color: Colors.white,
                        child: Column(
                          children: <Widget>[
                            /// 제목 및 작성시간 및 작성자
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    _dataList[index]['title'],
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    _dataList[index]['dateTime']
                                            .substring(0, 19) +
                                        ' | ' +
                                        _dataList[index]['nickName'],
                                  ),
                                ),
                              ],
                            ),

                            /// 내용
                            Container(
                              alignment: Alignment.topLeft,
                              height: 50,
                              child: Text(
                                _makePreviewContent(
                                    _dataList[index]['content']),
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ),

                            /// 좋아요 및 댓글 수
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                  child: Icon(Icons.favorite, size: 15),
                                ),
                                Container(
                                  child: Text(
                                    ' ' +
                                        (_dataList[index].data()
                                                .toString()
                                                .contains('favorites')
                                            ? _dataList[index]['favorites']
                                                .length
                                                .toString()
                                            : '0'),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                  child: Icon(Icons.comment, size: 15),
                                ),
                                Container(
                                  child: Text(
                                    ' ' +
                                        (_dataList[index].data()
                                            .toString()
                                            .contains('comments')
                                            ? _dataList[index]['comments']
                                            .length
                                            .toString()
                                            : '0'),
                                  ),
                                ),
                              ],
                            ),

                            /// 분할선
                            Container(
                              height: 1,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      onTap: () async {
                        var _result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return PostDetailPage(
                                  postDateTime: snapshot.data!.docs[index]
                                      ['dateTime']);
                            },
                          ),
                        );

                        /// _result 가 null 일 수도 있어서 먼저 판별 후 true 인지 판별
                        if (_result != null && _result) {
                          setState(() {});
                        }
                      },
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                child: Column(
                                  children: <Widget>[
                                    CupertinoButton(
                                      child: Text('신고하기'),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                footer: CustomFooter(
                  builder: (context, mode) {
                    Widget body;
                    if (mode == LoadStatus.idle) {
                      body = Text("데이터 더 불러오기");
                    } else if (mode == LoadStatus.loading) {
                      body = CupertinoActivityIndicator();
                    } else if (mode == LoadStatus.failed) {
                      body = Text("로딩 실패");
                    } else if (mode == LoadStatus.canLoading) {
                      body = Text("놓아서 더 불러오기");
                    } else {
                      body = Text("더 표시할게 없습니다");
                    }
                    return Container(
                      height: 55.0,
                      child: Center(child: body),
                    );
                  },
                ),
              ),
            );
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
      appBar: MainAppBar(
        context: context,
        title: '게시판',
        actions: <Widget>[
          CupertinoButton(
            child: Icon(Icons.post_add),
            onPressed: () async {
              /// _result 의 반환값은 true 또는 null 이다.
              /// bool 로 해줘도 상관없지만, bool 은 null 이 될 수 없어서 var 로 해주었다.
              var _result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return NewPostPage();
                  },
                ),
              );

              if (_result == true) {
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: _buildPage(),
    );
  }
}
