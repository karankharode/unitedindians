import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:unitedindians/screens/VideoPlayerScreen.dart';
import 'package:unitedindians/values/colors.dart';
import 'package:unitedindians/values/config.dart';
import 'package:unitedindians/values/coursedata.dart';
import 'package:unitedindians/values/lessons.dart';

class DemoLessonPage extends StatefulWidget {
  final int index;
  final int courseIndexRecieved;
  final String lessonName;

  DemoLessonPage(this.index, this.courseIndexRecieved, this.lessonName);
  @override
  _DemoLessonPageState createState() => _DemoLessonPageState();
}

class _DemoLessonPageState extends State<DemoLessonPage> {
  bool _dataFetched = false;
  int demoLessonCount;
  DatabaseReference dbreference;
  TextStyle courseNameStyle = TextStyle(color: white, fontSize: 15);
  TextStyle descriptionStyle = TextStyle(fontSize: 12, color: white);

  @override
  void initState() {
    _dataFetched = false;
    dbreference = FirebaseDatabase.instance.reference();
    getLessonData();
    demoLessonCount = 2;
    super.initState();
  }

  Future<void> getLessonData() async {
    if (!_dataFetched) {
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
        demoLessonList.clear();
        setState(() {
          value.value.forEach((key, value) {
            if (value != null) {
              demoLessonList.add(new Lesson(
                  value["Info"]['duration'],
                  value["Info"]['link'],
                  value["Info"]['name'],
                  key.toString()));
            }
          });
          demoLessonList.sort((a, b) {
            return a.key.toLowerCase().compareTo(b.key.toLowerCase());
          });
          if (value.value != null) {
            _dataFetched = true;
          }
        });
      });
    } else {}
  }

  Widget drawLessonBox() {
    try {
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
                              " Demo Lessons - ${widget.lessonName}",
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
                      itemCount: (demoLessonList.length>2)? 02:demoLessonList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(4, 8.0, 4, 8),
                          child: new Container(
                            decoration: alternateTheme(index),
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(8, 10.0, 8, 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          demoLessonList[index].name,
                                          style: courseNameStyle,
                                        ),
                                        new SizedBox(
                                          height: 18.0,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.7,
                                          child: new Center(
                                            child: new Container(
                                              margin: new EdgeInsetsDirectional
                                                  .only(start: 1.0, end: 1.0),
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
                                                      "  ${demoLessonList[index].duration}",
                                                      style: TextStyle(
                                                          color: white)),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
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
                                                        demoLessonList[index]
                                                            .duration,
                                                        demoLessonList[index]
                                                            .link,
                                                        demoLessonList[index]
                                                            .name),
                                                    type:
                                                        PageTransitionType.fade,
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
                                                      color: white,
                                                      fontSize: 12),
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
    } catch (e) {
      return Container();
      // debugPrint(e);
     
    }
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
          _dataFetched
              ? drawLessonBox()
              : Container(
                  height: MediaQuery.of(context).size.height / 6,
                  child: Center(child: CircularProgressIndicator())),
        ],
      ),
    ));
  }
}
