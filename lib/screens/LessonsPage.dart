import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:unitedindians/LessonPage/Model.dart';
import 'package:unitedindians/screens/SubTopicPage.dart';
import 'package:unitedindians/values/colors.dart';
import 'package:unitedindians/values/config.dart';

bool topicFetched = false;

class LessonsPage extends StatefulWidget {
  final int index;
  final int courseIndexRecieved;

  LessonsPage(this.index, this.courseIndexRecieved);
  @override
  _LessonsPageState createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage> {
  DatabaseReference databaseReference;

  TextStyle courseNameStyle = TextStyle(color: white, fontSize: 15);
  TextStyle descriptionStyle = TextStyle(fontSize: 12, color: white);

  @override
  void initState() {
    databaseReference = FirebaseDatabase.instance.reference();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: bodyBackgroundDecoration,
      child: ListView(
        children: [
          topicFetched ? drawLessonBox() : CircularProgressIndicator(),
        ],
      ),
    ));
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
                            " Classroom",
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
                    itemCount: topicList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    child: SubTopicPage(
                                        widget.index,
                                        widget.courseIndexRecieved,
                                        topicList[index].topicName.toString()),
                                    type: PageTransitionType.rightToLeft));
                          },
                          child: new Container(
                            decoration: courseDetailsPageDecoration,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Container(
                                            child: index % 2 == 0
                                                ? CircleAvatar(
                                                    child: Image.asset(
                                                      "assets/images/presentation.png",
                                                    ),
                                                    backgroundColor:
                                                        Colors.transparent)
                                                : CircleAvatar(
                                                    child: Image.asset(
                                                        "assets/images/classroom.png"),
                                                    backgroundColor:
                                                        Colors.transparent)),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(topicList[index].topicName,
                                                  style: courseNameStyle),
                                              Text(
                                                  "Total Lectures: ${topicList[index].totalTopic.toString()}",
                                                  style: descriptionStyle),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 40,
                                    child: IconButton(
                                        icon: Image(
                                            image: AssetImage(
                                                "assets/images/circle_arrow.png")),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              PageTransition(
                                                child: SubTopicPage(
                                                    widget.index,
                                                    widget.courseIndexRecieved,
                                                    topicList[index]
                                                        .topicName
                                                        .toString()),
                                                type: PageTransitionType
                                                    .rightToLeft,
                                              ));
                                        }),
                                  )
                                ],
                              ),
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
}
