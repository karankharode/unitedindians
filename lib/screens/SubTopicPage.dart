import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kumi_popup_window/kumi_popup_window.dart';
import 'package:page_transition/page_transition.dart';
import 'package:unitedindians/screens/VideoPlayerScreen.dart';
import 'package:unitedindians/services/date_time.dart';
import 'package:unitedindians/values/colors.dart';
import 'package:unitedindians/values/config.dart';
import 'package:unitedindians/values/coursedata.dart';
import 'package:unitedindians/values/lessons.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class SubTopicPage extends StatefulWidget {
  final int index;
  final int courseIndexRecieved;
  final String lessonName;

  SubTopicPage(this.index, this.courseIndexRecieved, this.lessonName);
  @override
  _SubTopicPageState createState() => _SubTopicPageState();
}

class _SubTopicPageState extends State<SubTopicPage> {
  bool dataFetched = false;
  DatabaseReference dbreference;
  TextStyle courseNameStyle = TextStyle(color: white, fontSize: 15);
  TextStyle descriptionStyle = TextStyle(fontSize: 12, color: white);

  // popup
  GlobalKey btnKey = GlobalKey();
  KumiPopupWindow popupWindow;
  final TextEditingController _textController = TextEditingController();
  bool isComposing = false;
  firebase_auth.User _user;
  int lessonIndex;

  @override
  void initState() {
    dataFetched = false;
    dbreference = FirebaseDatabase.instance.reference();
    getLessonData();
    this._user = firebase_auth.FirebaseAuth.instance.currentUser;
    super.initState();
  }

  Future<void> getLessonData() async {
    if (!dataFetched) {
      await dbreference
          .child("Courses")
          .child(categoryNames[widget.index])
          .child(categoryList[widget.index]
              .courseDataListModelList[widget.courseIndexRecieved]
              .courseId)
          .child("Lessons")
          .child(widget.lessonName)
          .once()
          .then((DataSnapshot value) {
        lessonList.clear();
        setState(() {
          value.value.forEach((key, value) {
            if (value != null) {
              lessonList.add(new Lesson(
                  value["Info"]['duration'],
                  value["Info"]['link'],
                  value["Info"]['name'],
                  key.toString()));
            }
          });
          lessonList.sort((a, b) {
            return a.key.toLowerCase().compareTo(b.key.toLowerCase());
          });
          if (value.value != null) {
            dataFetched = true;
          }
        });
      });
    } else {}
  }

  Widget drawLessonBox() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.only(left: 4, right: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 15,
              ),
              // classroom and back button
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 8.0),
                child: Container(
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            " Classroom - ${widget.lessonName}",
                            style: courseNameStyle,
                          ),
                          Text(
                            "(All Subjects/Lectures)",
                            style: descriptionStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              // Lesson List
              Container(
                height: MediaQuery.of(context).size.height - 150,
                child: ListView.builder(
                    itemCount: lessonList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(4, 8.0, 4, 8),
                        child: new Container(
                          decoration: alternateTheme(index),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 10.0, 8, 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lessonList[index].name,
                                        style: courseNameStyle,
                                      ),
                                      new SizedBox(
                                        height: 18.0,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.7,
                                        child: new Center(
                                          child: new Container(
                                            margin:
                                                new EdgeInsetsDirectional.only(
                                                    start: 1.0, end: 1.0),
                                            height: 1.0,
                                            color: white,
                                          ),
                                        ),
                                      ),
                                      // button bar
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 8.0, 8, 8),
                                        child: Row(
                                          children: [
                                            drawButton("TEST"),
                                            drawButton("SUMMARY"),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.watch_later_outlined,
                                                  color: white,
                                                  size: 14,
                                                ),
                                                Text(
                                                    "  ${lessonList[index].duration}",
                                                    style: TextStyle(
                                                        color: white)),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            lessonIndex = index;
                                          });
                                          showPopupWindow(
                                            context,
                                            //childSize:Size(240, 800),
                                            gravity:
                                                KumiPopupGravity.centerBottom,
                                            //curve: Curves.elasticOut,
                                            bgColor:
                                                colorPrimary.withOpacity(0.5),
                                            clickOutDismiss: true,
                                            clickBackDismiss: true,
                                            customAnimation: false,
                                            customPop: false,
                                            customPage: false,
                                            // targetRenderBox: (btnKey.currentContext.findRenderObject() as RenderBox),
                                            //needSafeDisplay: true,
                                            underStatusBar: false,
                                            underAppBar: false,
                                            //offsetX: -180,
                                            //offsetY: 50,
                                            duration:
                                                Duration(milliseconds: 200),
                                            onShowStart: (pop) {},
                                            onShowFinish: (pop) {},
                                            onDismissStart: (pop) {},
                                            onDismissFinish: (pop) {},
                                            onClickOut: (pop) {},
                                            onClickBack: (pop) {},
                                            childFun: (pop) {
                                              return StatefulBuilder(
                                                  key: GlobalKey(),
                                                  builder:
                                                      (popContext, popState) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        //isSelect.value = !isSelect.value;
                                                        popState(() {});
                                                      },
                                                      child: ListView(
                                                        // mainAxisAlignment: MainAxisAlignment.end,
                                                        children: [
                                                          Container(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height -
                                                                35,
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            decoration:
                                                                bodyBackgroundDecoration,
                                                            // width: 300,
                                                            alignment: Alignment
                                                                .center,
                                                            child: Column(
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          12.0,
                                                                      top: 8,
                                                                      bottom:
                                                                          8),
                                                                  child:
                                                                      Container(
                                                                    height: 20,
                                                                    child: Text(
                                                                        "Comments",
                                                                        style:
                                                                            courseNameStyle,
                                                                        textAlign:
                                                                            TextAlign.center),
                                                                  ),
                                                                ),
                                                                _buildMessagesList(
                                                                    widget
                                                                        .courseIndexRecieved,
                                                                    widget
                                                                        .index,
                                                                    index),
                                                                _buildComposeMsgRow(),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  });
                                            },
                                          );
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.7,
                                          decoration: BoxDecoration(
                                              color:
                                                  colorDiscussionBlockBackground,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5))),
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      2, 4, 2, 4),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.message_outlined,
                                                    color: white,
                                                    size: 15,
                                                  ),
                                                  Text("   Discussion",
                                                      style: TextStyle(
                                                          color: white,
                                                          fontSize: 14))
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 40,
                                    width: 80,
                                    child: Container(
                                      decoration: buttonDecoration,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              PageTransition(
                                                  child: VideoPlayerScreen(
                                                      lessonList[index]
                                                          .duration,
                                                      lessonList[index].link,
                                                      lessonList[index].name),
                                                  type: PageTransitionType.fade,
                                                  duration: Duration(
                                                      milliseconds: 700)));
                                        },
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              4, 4, 4, 3),
                                          child: Center(
                                              child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "WATCH ",
                                                style: TextStyle(
                                                    color: white, fontSize: 12),
                                              ),
                                              Icon(
                                                Icons.play_circle_fill,
                                                color: white,
                                                size: 15,
                                              ),
                                            ],
                                          )),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              ),
              SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesList(
    int courseIndex,
    int categoryIndex,
    int lessonIndex,
  ) {
    return Flexible(
      child: Scrollbar(
        child: FirebaseAnimatedList(
          defaultChild: const Center(child: CircularProgressIndicator()),
          query: dbreference
              .child("Courses")
              .child(categoryNames[widget.index])
              .child(categoryList[categoryIndex]
                  .courseDataListModelList[courseIndex]
                  .courseId)
              .child("Lessons")
              .child(widget.lessonName)
              .child(lessonList[lessonIndex].key)
              .child("Comments"),
          // sort: (a, b) => b.key.compareTo(a.key),
          padding: const EdgeInsets.all(8.0),
          reverse: false,
          itemBuilder: (BuildContext ctx, DataSnapshot snapshot,
                  Animation<double> animation, int idx) =>
              _messageFromSnapshot(snapshot, animation),
        ),
      ),
    );
  }

  Widget _messageFromSnapshot(
      DataSnapshot snapshot, Animation<double> animation) {
    final senderName = snapshot.value['uid'] as String ?? '?? <unknown>';
    final msgText = snapshot.value['comment'] as String ?? '??';
    // final sentTime = snapshot.value['date_time'] as String ?? "??";
    final sentTime = GMTDateTime().formatRecieved(snapshot.value['date_time']);

    // sentTime = sentTime.replaceAll("GMT+5:30", "");

    final messageUI = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                backgroundImage: AssetImage("assets/images/profile.png"),
              )),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: commentDecoration,
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      FutureBuilder(
                        future: getCommentsusername(senderName),
                        builder: (context, snapshot) {
                          return Text(snapshot.data ?? "Username",
                              style: TextStyle(color: black)
                              // style: headingStyle
                              );
                        },
                      ),
                      Text(
                        msgText,
                        style: TextStyle(color: black),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 2,
                ),
                Text(
                  sentTime.toString(),
                  // DateTime.parse(sentTime).toString(),
                  style: TextStyle(color: grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ),
      child: messageUI,
    );
  }

  // Builds the row for composing and sending message.
  Widget _buildComposeMsgRow() {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              padding: EdgeInsets.only(left: 5,top: 5,bottom: 5),
              decoration: BoxDecoration(color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.all(Radius.circular(10))),
              child: TextField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                maxLength: 200,
                decoration:
                    const InputDecoration.collapsed(hintText: "Send a message"),
                controller: _textController,
                onChanged: (String text) {
                  if (text.length == 0) {
                    setState(() {
                      isComposing = false;
                    });
                  } else {
                    setState(() {
                      isComposing = true;
                    });
                  }
                },
                onSubmitted: _onTextMsgSubmitted,
              ),
            ),
          ),
          IconButton(
              icon: const Icon(Icons.send, color: white),
              onPressed: () => isComposing
                  ? _onTextMsgSubmitted(_textController.text)
                  : null
              )
        ],
      ),
    );
  }

  // Triggered when text is submitted (send button pressed).
  Future<void> _onTextMsgSubmitted(String text) async {
    // Clear input text field.
    _textController.clear();
    setState(() {
      isComposing = false;
    });
    print(lessonList[lessonIndex].key);

    // Send message to firebase realtime database.
    dbreference
        .child("Courses")
        .child(categoryNames[widget.index])
        .child(categoryList[widget.index]
            .courseDataListModelList[widget.courseIndexRecieved]
            .courseId)
        .child("Lessons")
        .child(widget.lessonName)
        .child(lessonList[lessonIndex].key)
        .child("Comments")
        .push()
        .set({
      'uid': this._user.uid,
      'comment': text,
      'date_time': GMTDateTime().sendingTime(),
    });
  }

  Future<String> getCommentsusername(String uid) async {
    String username = '';
    await dbreference
        .child("Users")
        .child(uid)
        .child("Info")
        .child("name")
        .once()
        .then((value) {
      setState(() {
        username = value.value;
      });
    });
    return username;
  }

  Widget drawButton(String buttonText) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 2, 8, 2),
      child: Container(
        decoration: flatButtonDecoration,
        child: InkWell(
          onTap: () {
            Fluttertoast.showToast(
                msg: "Coming Soon",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: colorPrimaryDark,
                textColor: Colors.white,
                fontSize: 12.0);
          },
          borderRadius: BorderRadius.all(Radius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Center(
                child: Text(
              buttonText,
              style: TextStyle(color: white, fontSize: 12),
            )),
          ),
        ),
      ),
    );
  }

  BoxDecoration alternateTheme(int index) {
    return BoxDecoration(
        color: index % 2 == 0 ? colorBlockBackground : themeshadowBlack,
        borderRadius: BorderRadius.all(Radius.circular(20)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: bodyBackgroundDecoration,
      child: ListView(
        children: [
          dataFetched
              ? drawLessonBox()
              : Container(
                  height: MediaQuery.of(context).size.height / 6,
                  child: Center(child: CircularProgressIndicator())),
        ],
      ),
    ));
  }
}
