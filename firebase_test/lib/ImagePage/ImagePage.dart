import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../GlobalWidget/MainAppBar.dart';

///*****************************************************************************
///
/// FirebaseStorage 에 관련된 테스트를 하는 페이지
///
///*****************************************************************************
///
class ImagePage extends StatefulWidget {
  ImagePage({Key? key}) : super(key: key);

  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  ImagePicker _picker = new ImagePicker();
  late File _selectedFile;
  ListResult? result;

  bool _isSelected = false;
  bool _isReadData = false;

  /// 이미지들을 표시할 위젯을 새로고침하는 메서드
  void _refreshGridView() {
    FirebaseStorage.instance
        .ref()
        .child('Images')
        .child('${FirebaseAuth.instance.currentUser!.uid}')
        .listAll()
        .then(
      (ListResult listResult) {
        setState(
          () {
            result = listResult;
            _isSelected = false;
          },
        );
      },
    );
  }

  /// FirebaseStorage 에서 불러온 이미지들을 표시할 위젯을 리턴하는 메서드
  Widget _buildImageGridView(ListResult? result) {
    /// 읽어들인 값이 null 일 경우 아무것도 출력하지 않음
    if (result == null) {
      return Container();
    }

    /// 읽어들인 값이 null 이 아닐 경우 GridView 를 출력
    else {
      return Container(
        height: ((result.items.length / 3).ceil()) * 160.0,
        child: GridView.count(
          /// 스크롤이 불가능하게 하게 위해서 설정해준 physics
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          children: List.generate(
            result.items.length,
            (int index) {
              return Container(
                height: 160,
                width: 90,
                child: FutureBuilder(
                  future: result.items.elementAt(index).getDownloadURL(),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      return TextButton(
                        child: Hero(
                          tag: 'Image_$index',
                          child: Image.network('${snapshot.data}'),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,

                            /// PageRoute 를 할 때 나머지 부분을 투명하게 하고싶으면
                            /// PageRouteBuilder 를 쓰고, opaque 를 false 로 한다.
                            new PageRouteBuilder(
                              opaque: false,
                              pageBuilder: (BuildContext context, _, __) {
                                return Stack(
                                  children: <Widget>[
                                    /// 화면 전체 크기의 Container 를 생성
                                    Opacity(
                                      opacity: 0,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height,
                                      ),
                                    ),

                                    /// 터치한 이미지를 크게 출력
                                    /// 동작을 인식해서 애니메이션을 넣는 것도 고려 중
                                    SafeArea(
                                      child: Center(
                                        child: Stack(
                                          children: <Widget>[
                                            Hero(
                                              tag: 'Image_$index',
                                              child: Image.network(
                                                  '${snapshot.data}'),
                                            ),
                                            Positioned(
                                              top: 10,
                                              left: 10,
                                              child: CupertinoButton(
                                                child: Icon(Icons.close),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        },
                        onLongPress: () async {
                          /// Dialog 에서 선택한 값에 따라 변수를 반환받는다.
                          bool returnValue = await (showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Text('이 이미지를 삭제하시겠습니까?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('예'),
                                    onPressed: () async {
                                      late BuildContext _context;

                                      Navigator.pop(context, true);

                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            _context = context;
                                            return AlertDialog(
                                              content:
                                              CupertinoActivityIndicator(),
                                            );
                                          });

                                      await result.items
                                          .elementAt(index)
                                          .delete()
                                          .then((_) {
                                        Navigator.pop(_context);
                                      });
                                    },
                                  ),
                                  TextButton(
                                    child: Text('아니오'),
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                  ),
                                ],
                              );
                            },
                          ) as Future<bool>);

                          /// Dialog 에서 선택한 값이 '예' 일 경우
                          /// 이미지 목록을 새로고침
                          if (returnValue) _refreshGridView();
                        },
                      );
                    }

                    return CupertinoActivityIndicator();
                  },
                ),
              );
            },
          ),
        ),
      );
    }
  }

  /// 페이지 내용 빌드 메서드
  Widget _buildPage() {
    return Container(
      child: Scrollbar(
        child: ListView(
          children: <Widget>[
            /// 이미지 선택 및 미리보기
            Container(
              margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  /// 이미지 선택 버튼
                  Container(
                    child: TextButton(
                      child: Text('이미지 선택'),
                      onPressed: () async {
                        final _pickedFile =
                            await _picker.getImage(source: ImageSource.gallery);

                        setState(
                          () {
                            if (_pickedFile != null) {
                              _selectedFile = File(_pickedFile.path);
                              _isSelected = true;
                            }
                          },
                        );
                      },
                    ),
                  ),

                  /// 선택한 이미지를 출력하는 공간
                  Container(
                    height: 160,
                    width: 90,
                    decoration: BoxDecoration(
                      border: Border.all(),
                    ),
                    child: (_isSelected)
                        ? Image.file(_selectedFile)
                        : Center(
                            child: Text(
                              '이미지를\n선택해주세요',
                              textAlign: TextAlign.center,
                            ),
                          ),
                  ),
                ],
              ),
            ),

            /// 이미지 업로드 버튼
            TextButton(
              child: Text('이미지 업로드'),
              onPressed: () async {
                /// 이미지를 선택했을 경우에만 업로드 작업을 실행하기 위해서
                /// [_isSelected] 변수를 사용해서 판별해주었다.
                if (_isSelected) {
                  late BuildContext _context;
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      _context = context;
                      return AlertDialog(
                        content: CupertinoActivityIndicator(),
                      );
                    }
                  );
                  Reference _reference = FirebaseStorage.instance
                      .ref()
                      .child('Images')
                      .child('${FirebaseAuth.instance.currentUser!.uid}')
                      .child('${DateTime.now()}.png');

                  UploadTask _uploadTask = _reference.putFile(_selectedFile);
                  TaskSnapshot _taskSnapshot = await _uploadTask.whenComplete(
                    () {
                      log('upload complete!');

                      Navigator.pop(_context);
                      /*
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('이미지가 전송되었습니다.'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      */

                      _refreshGridView();
                    },
                  );

                  await _taskSnapshot.ref.getDownloadURL();
                } else {
                  /* do nothing */
                }
              },
            ),

            /// 이미지 리스트 읽기 버튼
            TextButton(
              child: Text('파일 읽기'),
              onPressed: () async {
                result = await FirebaseStorage.instance
                    .ref()
                    .child('Images')
                    .child('${FirebaseAuth.instance.currentUser!.uid}')
                    .listAll();

                setState(
                  () {
                    _isReadData = true;
                  },
                );
              },
            ),
            Visibility(
              visible: _isReadData,
              child: _buildImageGridView(result),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        context: context,
        title: '이미지 테스트 페이지',
        actions: <Widget>[
          /// 새로고침 버튼
          CupertinoButton(
            child: Icon(Icons.refresh),
            onPressed: () {
              setState(
                () {
                  _isSelected = false;
                  _isReadData = false;
                },
              );
            },
          ),
        ],
      ),
      body: _buildPage(),
    );
  }
}
