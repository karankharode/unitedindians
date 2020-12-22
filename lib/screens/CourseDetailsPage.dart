import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:kumi_popup_window/kumi_popup_window.dart';
import 'package:page_transition/page_transition.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:unitedindians/LessonPage/Model.dart';
import 'package:unitedindians/screens/DemoLessonPage.dart';
import 'package:unitedindians/screens/LessonsPage.dart';
import 'package:unitedindians/services/date_time.dart';
import 'package:unitedindians/values/User.dart';
import 'package:unitedindians/values/colors.dart';
import 'package:unitedindians/values/config.dart';
import 'package:unitedindians/values/coursedata.dart';
import 'package:unitedindians/values/educators.dart';
import 'package:unitedindians/widgets/LockedBanner.dart';
import 'package:unitedindians/widgets/goToLessonsButton.dart';
import 'package:unitedindians/widgets/lockIcon.dart';
import 'package:unitedindians/widgets/progressIndicator.dart';

class CourseDetailsPage extends StatefulWidget {
  final int index;
  final int courseIndexRecieved;
  CourseDetailsPage(this.index, this.courseIndexRecieved);
  @override
  _CourseDetailsPageState createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  //razorpay
  static const platform = const MethodChannel("razorpay_flutter");
  Razorpay _razorpay;
  var finalAmount;
  String courseName;
  String description;
  bool isEnrolled = false;
  bool comingSoon = false;
  bool open = false;
  bool free = false;

  double noOfRatings = 0;
  double averageRating = 0;
  DatabaseReference databaseReference;
  double rating = 3.0;
  double userRating;
  bool rated = false;
  bool isCommentsEmpty = true;
  bool showEducators = false;

  // popup
  GlobalKey btnKey = GlobalKey();
  KumiPopupWindow popupWindow;
  final TextEditingController _textController = TextEditingController();
  bool isComposing = false;
  bool selected = false;
  firebase_auth.User _user;

  ValueNotifier<bool> isSelect = ValueNotifier(false);
  var aaa = "false";

  TextStyle courseNameStyle =
      TextStyle(color: white, fontSize: 15, fontWeight: FontWeight.bold);
  TextStyle discountPriceStyle =
      TextStyle(color: white, fontSize: 18, fontWeight: FontWeight.bold);
  TextStyle sellingPriceStyle = TextStyle(
      color: white, fontSize: 15, decoration: TextDecoration.lineThrough);
  TextStyle headingStyle =
      TextStyle(fontSize: 15, color: white, fontWeight: FontWeight.bold);
  TextStyle descriptionStyle = TextStyle(fontSize: 13, color: white);
  TextStyle courseDetailBlockTextStyle = TextStyle(fontSize: 12, color: white);

  @override
  void initState() {
    databaseReference = FirebaseDatabase.instance.reference();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    ratingListener(widget.courseIndexRecieved, widget.index);
    this._user = firebase_auth.FirebaseAuth.instance.currentUser;
    courseName = categoryList[widget.index]
        .courseDataListModelList[widget.courseIndexRecieved]
        .name;
    updateCourseStatus();
    super.initState();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  getCourseStatus() {
    if (comingSoon) {
    } else if (open) {
      getEducators(widget.courseIndexRecieved, widget.index);
      getLessons(widget.courseIndexRecieved, widget.index);
      if (free) {
      } else {
        _primeMembershipChecking();
      }
    } else {
      _primeMembershipChecking();
      _courseEnrolledChecking();
      getEducators(widget.courseIndexRecieved, widget.index);
      getLessons(widget.courseIndexRecieved, widget.index);
    }
  }

  Future<void> getLessons(int courseIndex, int categoryIndex) async {
    try {
      await databaseReference
          .child("Courses")
          .child(categoryNames[widget.index])
          .child(categoryList[categoryIndex]
              .courseDataListModelList[courseIndex]
              .courseId)
          .child("Lessons")
          .once()
          .then((value) {
        topicList.clear();
        Map<dynamic, dynamic> topicSnap = value.value;
        topicSnap.forEach((key, value) {
          if (value != null) {
            topicList.add(TopicDetails(value.length, key.toString()));
          }
        });
        setState(() {
          topicFetched = true;
        });
        topicList.sort((a, b) {
          return a.topicName
              .toString()
              .toLowerCase()
              .compareTo(b.topicName.toString().toLowerCase());
        });
      });
    } catch (e) {
      // debugPrint(e);
    }
  }

  Future<void> updateCourseStatus() async {
    await databaseReference
        .child("Courses")
        .child(categoryNames[widget.index])
        .child(categoryList[widget.index]
            .courseDataListModelList[widget.courseIndexRecieved]
            .courseId)
        .child("Info")
        .once()
        .then((value) {
      setState(() {
        comingSoon = value.value["coming_soon"] == "true";
        free = value.value["free"] == "true";
        open = value.value["open"] == "true";
      });
      getCourseStatus();
    });
  }

  void ratingListener(int courseIndex, int categoryIndex) {
    databaseReference
        .child("Courses")
        .child(categoryNames[widget.index])
        .child(categoryList[categoryIndex]
            .courseDataListModelList[courseIndex]
            .courseId)
        .child("Ratings")
          ..onChildChanged.listen((Event change) {
            updateRating(courseIndex, categoryIndex);
          })
          ..onChildAdded.listen((Event event) {
            updateRating(courseIndex, categoryIndex);
          })
          ..onChildRemoved.listen((Event event) {
            updateRating(courseIndex, categoryIndex);
          });

    databaseReference
        .child("Courses")
        .child(categoryNames[widget.index])
        .child(categoryList[categoryIndex]
            .courseDataListModelList[courseIndex]
            .courseId)
        .child("Info")
          ..onChildChanged.listen((Event change) {
            updateCourseStatus();
          })
          ..onValue.listen((event) {
            updateCourseStatus();
          });
  }

  Future<void> updateRating(int courseIndex, int categoryIndex) async {
    double frating = 0.0;
    double ratingCount = 0;
    await databaseReference
        .child("Courses")
        .child(categoryNames[widget.index].toString())
        .child(categoryList[categoryIndex]
            .courseDataListModelList[courseIndex]
            .courseId
            .toString())
        .child("Ratings")
        .once()
        .then((DataSnapshot dataSnapshot) {
      Map<dynamic, dynamic> ratingSnapshot = dataSnapshot.value;
      ratingSnapshot.forEach((key, value) {
        ratingCount = ratingCount + 1;
        frating = frating + double.tryParse(value["rating"].toString());
      });
      frating = frating / ratingCount;
      if (this.mounted) {
        setState(() {
          rating = frating;
          noOfRatings = ratingCount;
          averageRating = frating;
        });
      }
    });
  }

  void doNothing() {}
  Widget drawRatingBox(int courseIndex, int categoryIndex) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            decoration: courseDetailsPageDecoration,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          "  Rating - (${noOfRatings.toString().split(".").first})",
                          style: headingStyle,
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: RatingBar(
                              initialRating: rated ? userRating : rating,
                              glow: false,
                              unratedColor: grey,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding:
                                  EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) async {
                                setState(() {
                                  rated = true;
                                  userRating = rating;
                                });
                                // call db update
                                await databaseReference
                                    .child("Courses")
                                    .child(categoryNames[widget.index])
                                    .child(categoryList[categoryIndex]
                                        .courseDataListModelList[courseIndex]
                                        .courseId)
                                    .child("Ratings")
                                    .child(
                                        FirebaseAuth.instance.currentUser.uid)
                                    .child("name")
                                    .set(await getusername());

                                await databaseReference
                                    .child("Courses")
                                    .child(categoryNames[widget.index])
                                    .child(categoryList[widget.index]
                                        .courseDataListModelList[
                                            widget.courseIndexRecieved]
                                        .courseId)
                                    .child("Ratings")
                                    .child(
                                        FirebaseAuth.instance.currentUser.uid)
                                    .child("rating")
                                    .set(rating.toString());
                              },
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                              "Average Rating: ${averageRating.toStringAsFixed(2)}",
                              style: courseDetailBlockTextStyle),
                        )
                      ]),
                ))));
  }

  void openCheckout(int amount) async {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
            child: Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Center(child: CircularProgressIndicator())));
      },
    );
    setState(() {
      finalAmount = amount / 100;
    });
    if (amount == 10000)
      description = "Prime Membership";
    else
      description = "Course Fess- $courseName + Prime Membership";

    var options = {
      // card - 4111 1111 1111 1111
      // 'key': 'rzp_live_SxBV5sId38OFu7',
      'key': 'rzp_test_0sTTgVXKNPPfbQ', //test
      'amount': amount,
      'name': 'UI Forums',
      'description': description,
      'prefill': {'contact': '7757885725', 'email': 'devtas.dts@gmail.com'},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e);
    }
  }

  void _enrollUser() {
    if (!isPrimeMember) {
      _primeMembershipEnrolling();
      setState(() {
        isPrimeMember = true;
      });
    }
    databaseReference
        .child("Courses")
        .child(categoryNames[widget.index].toString())
        .child(categoryList[widget.index]
            .courseDataListModelList[widget.courseIndexRecieved]
            .courseId
            .toString())
        .child("EnrolledUsers")
        .child(FirebaseAuth.instance.currentUser.uid)
        .set("true");
  }

  void _primeMembershipEnrolling() {
    databaseReference
        .child("Users")
        .child(FirebaseAuth.instance.currentUser.uid)
        .child("Info")
        .child("paid")
        .set("true");
  }

  void _primeMembershipChecking() {
    databaseReference
        .child("Users")
        .child(FirebaseAuth.instance.currentUser.uid)
        .child("Info")
        .child("paid")
        .once()
        .then((value) {
      if (value.value == "true") {
        setState(() {
          isPrimeMember = true;
        });
      } else {
        setState(() {
          isPrimeMember = false;
        });
      }
    });
  }

  void _courseEnrolledChecking() {
    databaseReference
        .child("Courses")
        .child(categoryNames[widget.index].toString())
        .child(categoryList[widget.index]
            .courseDataListModelList[widget.courseIndexRecieved]
            .courseId
            .toString())
        .child("EnrolledUsers")
        .child(FirebaseAuth.instance.currentUser.uid)
        .once()
        .then((DataSnapshot dataSnapshot) {
      String enrolled = dataSnapshot.value ?? "false";
      if (enrolled == "true") {
        setState(() {
          isEnrolled = true;
        });
      } else {
        setState(() {
          isEnrolled = false;
        });
      }
    });
  }

  // Razorpay methods
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Navigator.pop(context);
    if (finalAmount > 100) {
      // course unlock
      _enrollUser();
      setState(() {
        isPrimeMember = true;
        isEnrolled = true;
      });
      databaseReference.child("Payment").push().set({
        "amount": finalAmount.toString(),
        "course": isPrimeMember ? courseName : "$courseName + Prime Membership",
        "date_time": GMTDateTime().sendingTime(),
        "email": currentUserData[0].email,
        "name": currentUserData[0].name,
        "uid": FirebaseAuth.instance.currentUser.uid,
      });

      Fluttertoast.showToast(
          backgroundColor: Colors.greenAccent,
          toastLength: Toast.LENGTH_LONG,
          textColor: black,
          msg: "You have succesfully enrolled for the course");
    } else {
      // prime membership
      _primeMembershipEnrolling();
      setState(() {
        isPrimeMember = true;
      });
      Fluttertoast.showToast(
          backgroundColor: Colors.greenAccent,
          toastLength: Toast.LENGTH_LONG,
          textColor: black,
          msg: "Yeah ! Now you are a prime member !");

      databaseReference.child("Payment").push().set({
        "amount": finalAmount.toString(),
        "course": "Prime Membership",
        "date_time": GMTDateTime().sendingTime(),
        "email": currentUserData[0].email,
        "name": currentUserData[0].name,
        "uid": FirebaseAuth.instance.currentUser.uid,
      });
    }
    if (!open || (open && free)) {
      Navigator.pop(context);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Navigator.pop(context);
    Fluttertoast.showToast(
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
        msg: "ERROR : " + response.message,
        timeInSecForIosWeb: 4);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        toastLength: Toast.LENGTH_LONG,
        msg: "EXTERNAL_WALLET: " + response.walletName,
        timeInSecForIosWeb: 4);
  }

  Widget drawCommentPopUp(int courseIndex, int categoryIndex) {
    return Container(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 40,
        decoration: courseDetailsPageDecoration,
        child: InkWell(
          onTap: () {
            showPopupWindow(
              context,
              //childSize:Size(240, 800),
              gravity: KumiPopupGravity.centerBottom,
              //curve: Curves.elasticOut,
              bgColor: colorPrimary.withOpacity(0.5),
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
              duration: Duration(milliseconds: 200),
              onShowStart: (pop) {},
              onShowFinish: (pop) {},
              onDismissStart: (pop) {},
              onDismissFinish: (pop) {},
              onClickOut: (pop) {},
              onClickBack: (pop) {},
              childFun: (pop) {
                return StatefulBuilder(
                    key: GlobalKey(),
                    builder: (popContext, popState) {
                      return GestureDetector(
                        onTap: () {
                          //isSelect.value = !isSelect.value;
                          popState(() {
                            aaa = "sasdasd";
                          });
                        },
                        child: ListView(
                          // mainAxisAlignment: MainAxisAlignment.end,
                          shrinkWrap: true,
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height - 35,
                              width: MediaQuery.of(context).size.width,
                              decoration: bodyBackgroundDecoration,
                              // width: 300,
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 12.0, top: 8, bottom: 8),
                                    child: Container(
                                      height: 20,
                                      child: Text("Comments",
                                          style: courseNameStyle,
                                          textAlign: TextAlign.center),
                                    ),
                                  ),
                                  _buildMessagesList(
                                      courseIndex, categoryIndex),
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
          child: Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 8, bottom: 8),
            child: Container(
              child: Text("Comments ^",
                  style: headingStyle, textAlign: TextAlign.center),
            ),
          ),
        ),
      ),
    ));
  }

  Widget drawEducatorsBox() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: courseDetailsPageDecoration,
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text("Educators : ", style: headingStyle),
              ),
              GridView.count(
                crossAxisCount: 2,
                childAspectRatio: (2.9),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: List.generate(educatorList.length, (index) {
                  return Container(
                    child: Row(
                      children: [
                        Container(
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image:
                                        NetworkImage(educatorList[index].img),
                                    fit: BoxFit.fill)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(educatorList[index].name,
                              style: TextStyle(
                                color: white,
                              )),
                        )
                      ],
                    ),
                  );
                }),
              ),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget drawDivider() {
    return Divider(
      color: shadowGrey,
      indent: 40,
      endIndent: 40,
    );
  }

  Widget drawDescriptionBox(int courseIndex, int categoryIndex) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: courseDetailsPageDecoration,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 4,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text("Description : ", style: headingStyle),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                child: Text(
                  categoryList[categoryIndex]
                      .courseDataListModelList[courseIndex]
                      .description,
                  style: courseDetailBlockTextStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> getusername() async {
    String username = '';
    await databaseReference
        .child("Users")
        .child(FirebaseAuth.instance.currentUser.uid.toString())
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

  Future<String> getCommentsusername(String uid) async {
    String username = '';
    await databaseReference
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
    if (username == "null") {
      return "Username";
    }
    return username;
  }

  Future<void> getEducators(int courseIndex, int categoryIndex) async {
    try {
      await databaseReference
          .child("Courses")
          .child(categoryNames[widget.index])
          .child(categoryList[categoryIndex]
              .courseDataListModelList[courseIndex]
              .courseId)
          .child("Educators")
          .once()
          .then((DataSnapshot value) {
        educatorList.clear();
        if (value.value.runtimeType.toString() == "List<dynamic>") {
          List<dynamic> educatorSnap = value.value;
          setState(() {
            educatorSnap.forEach((value) {
              if (value != null) {
                educatorList.add(new Educator(value['img'], value['name']));
              }
            });
            showEducators = true;
          });
        } else if (value.value.runtimeType.toString() ==
            "_InternalLinkedHashMap<dynamic, dynamic>") {
          Map<dynamic, dynamic> educatorSnap = value.value;
          setState(() {
            educatorSnap.forEach((key, value) {
              if (value != null) {
                educatorList.add(new Educator(value['img'], value['name']));
              }
            });
            showEducators = true;
          });
        } else {
          Map<dynamic, dynamic> educatorSnap = value.value;
          setState(() {
            educatorSnap.forEach((key, value) {
              if (value != null) {
                educatorList.add(new Educator(value['img'], value['name']));
              }
            });
            showEducators = true;
          });
        }
      });
    } catch (e) {
      showEducators = false;
      // debugPrint(e);
    }
  }

  Widget drawCourseName(int courseIndex, int categoryIndex) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          decoration: courseDetailsPageDecoration,
          child: Padding(
            padding: const EdgeInsets.only(
                left: 17.0, right: 10, top: 18, bottom: 18),
            child: Text(
              categoryList[categoryIndex]
                  .courseDataListModelList[courseIndex]
                  .name,
              style: courseNameStyle,
            ),
          )),
    );
  }

  Widget drawLessonsButton(int courseIndex, int categoryIndex) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        onTap: () {
          comingSoon
              ? doNothing()
              : open
                  ? free
                      ? Navigator.push(
                          context,
                          PageTransition(
                              child: LessonsPage(
                                  widget.index, widget.courseIndexRecieved),
                              type: PageTransitionType.rightToLeftWithFade,
                              duration: Duration(milliseconds: 400)))
                      : isPrimeMember
                          ? Navigator.push(
                              context,
                              PageTransition(
                                  child: LessonsPage(
                                      widget.index, widget.courseIndexRecieved),
                                  type: PageTransitionType.rightToLeftWithFade,
                                  duration: Duration(milliseconds: 400)))
                          : openCheckout(10000)
                  : isEnrolled
                      ? Navigator.push(
                          context,
                          PageTransition(
                              child: LessonsPage(
                                  widget.index, widget.courseIndexRecieved),
                              type: PageTransitionType.rightToLeftWithFade,
                              duration: Duration(milliseconds: 400)))
                      : doNothing();
        },
        child: Container(
            decoration: courseDetailsPageDecoration,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 17.0, right: 10, top: 8, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  comingSoon
                      ? lockIcon()
                      : open
                          ? free
                              ? IconButton(
                                  icon: Image(
                                      image: AssetImage(
                                          "assets/images/circle_arrow.png")),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            child: LessonsPage(widget.index,
                                                widget.courseIndexRecieved),
                                            type: PageTransitionType
                                                .rightToLeftWithFade,
                                            duration:
                                                Duration(milliseconds: 400)));
                                  })
                              : isPrimeMember
                                  ? IconButton(
                                      icon: Image(
                                          image: AssetImage(
                                              "assets/images/circle_arrow.png")),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                child: LessonsPage(widget.index,
                                                    widget.courseIndexRecieved),
                                                type: PageTransitionType
                                                    .rightToLeftWithFade,
                                                duration: Duration(
                                                    milliseconds: 400)));
                                      })
                                  : lockIcon()
                          : isEnrolled
                              ? IconButton(
                                  icon: Image(
                                      image: AssetImage(
                                          "assets/images/circle_arrow.png")),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            child: LessonsPage(widget.index,
                                                widget.courseIndexRecieved),
                                            type: PageTransitionType
                                                .rightToLeftWithFade,
                                            duration:
                                                Duration(milliseconds: 400)));
                                  })
                              : lockIcon()
                ],
              ),
            )),
      ),
    );
  }

  Widget drawDemoLessonsButton(int courseIndex, int categoryIndex) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        onTap: () {
          Navigator.push(
              context,
              PageTransition(
                  child: DemoLessonPage(widget.index,
                      widget.courseIndexRecieved, topicList[0].topicName),
                  type: PageTransitionType.rightToLeftWithFade,
                  duration: Duration(milliseconds: 400)));
        },
        child: Container(
            decoration: courseDetailsPageDecoration,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 17.0, right: 10, top: 8, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        " Demo Lessons",
                        style: courseNameStyle,
                      ),
                    ],
                  ),
                  IconButton(
                      icon: Image(
                          image: AssetImage("assets/images/circle_arrow.png")),
                      onPressed: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                child: DemoLessonPage(
                                    widget.index,
                                    widget.courseIndexRecieved,
                                    topicList[0].topicName),
                                type: PageTransitionType.rightToLeftWithFade,
                                duration: Duration(milliseconds: 400)));
                      })
                ],
              ),
            )),
      ),
    );
  }

  Widget priceTextButton(bool comingSoon, bool open, bool free) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(children: [
              Column(children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8),
                  child: Text(
                    " \u20B9 ${categoryList[widget.index].courseDataListModelList[widget.courseIndexRecieved].discountPrice}",
                    style: discountPriceStyle,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8),
                  child: Text(
                    " \u20B9 ${categoryList[widget.index].courseDataListModelList[widget.courseIndexRecieved].sellingPrice}",
                    style: sellingPriceStyle,
                  ),
                ),
              ]),
            ]),
            // Buy Now
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                        boxShadow: [
                          new BoxShadow(
                              color: shadowBlack,
                              blurRadius: 2,
                              spreadRadius: 1,
                              offset: Offset(1, 1))
                        ],
                        gradient: LinearGradient(
                            colors: [gradientColor1, gradientColor2])),
                    child: FlatButton(
                      onPressed: () {},
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, bottom: 8, left: 39, right: 39),
                        child: Text(
                          comingSoon
                              ? "Coming Soon"
                              : open
                                  ? free
                                      ? "This course is open for everyone"
                                      : "This course is open only for Prime members"
                                  : "Enroll Now",
                          style: TextStyle(
                              color: white, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList(
    int courseIndex,
    int categoryIndex,
  ) {
    return Flexible(
      child: Scrollbar(
        child: FirebaseAnimatedList(
          defaultChild: const Center(child: CircularProgressIndicator()),
          query: databaseReference
              .child("Courses")
              .child(categoryNames[widget.index])
              .child(categoryList[categoryIndex]
                  .courseDataListModelList[courseIndex]
                  .courseId)
              .child("Comments"),
          sort: (a, b) => b.key.compareTo(a.key),
          padding: const EdgeInsets.all(8.0),
          reverse: true,
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
    // final sentTime = GMTDateTime().formatRecieved(snapshot.value['date_time']) ?? "??";
    // sentTime = sentTime.replaceAll("GMT+5:30", "");
    final messageUI = Padding(
      padding: const EdgeInsets.symmetric(vertical: 9.0),
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
                  padding:
                      EdgeInsets.only(top: 6, bottom: 6, left: 8, right: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      FutureBuilder(
                        future: getCommentsusername(senderName),
                        builder: (context, snapshot) {
                          return Text(snapshot.data ?? "Username",
                              style: TextStyle(
                                color: grey,
                                fontWeight: FontWeight.bold,
                              )
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: EdgeInsets.only(left: 5, top: 5, bottom: 5),
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: TextField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                maxLength: 200,
                decoration:
                    const InputDecoration.collapsed(hintText: "Send a message"),
                controller: _textController,
                enableInteractiveSelection: true,
                onTap: () {
                  setState(() {
                    // selected = true;
                  });
                },
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
                  : null)
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
    // Send message to firebase realtime database.
    databaseReference
        .child("Courses")
        .child(categoryNames[widget.index])
        .child(categoryList[widget.index]
            .courseDataListModelList[widget.courseIndexRecieved]
            .courseId)
        .child("Comments")
        .push()
        .set({
      'uid': this._user.uid,
      'comment': text,
      'date_time': GMTDateTime().sendingTime(),
    });
  }

  // Build Context
  @override
  Widget build(BuildContext context) {
    int categoryIndex = widget.index;
    int courseIndex = widget.courseIndexRecieved;
    return Scaffold(
      body: Container(
        decoration: bodyBackgroundDecoration,
        child: ListView(
          children: [
            LockedBanner(categoryIndex, courseIndex, comingSoon),

            comingSoon
                ? priceTextButton(comingSoon, open, free)
                : (open || free)
                    ? priceTextButton(comingSoon, open, free)
                    : (isPrimeMember && isEnrolled)
                        ? Container(
                            child: buildLessonsButton("Go to Lessons", context,
                                widget.index, widget.courseIndexRecieved),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(children: [
                                    Column(children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 8),
                                        child: Text(
                                          " \u20B9 ${categoryList[categoryIndex].courseDataListModelList[courseIndex].discountPrice}",
                                          style: discountPriceStyle,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 8),
                                        child: Text(
                                          " \u20B9 ${categoryList[categoryIndex].courseDataListModelList[courseIndex].sellingPrice}",
                                          style: sellingPriceStyle,
                                        ),
                                      ),
                                    ]),
                                  ]),
                                  // Buy Now
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(25)),
                                            boxShadow: [
                                              new BoxShadow(
                                                  color: shadowBlack,
                                                  blurRadius: 2,
                                                  spreadRadius: 1,
                                                  offset: Offset(1, 1))
                                            ],
                                            gradient: LinearGradient(colors: [
                                              gradientColor1,
                                              gradientColor2
                                            ])),
                                        child: FlatButton(
                                          onPressed: () {
                                            int amount;
                                            amount = (int.tryParse(categoryList[
                                                        categoryIndex]
                                                    .courseDataListModelList[
                                                        courseIndex]
                                                    .discountPrice) *
                                                100);
                                            showDialog(
                                                context: context,
                                                builder: (_) =>
                                                    NetworkGiffyDialog(
                                                      image: Image.network(
                                                          "https://raw.githubusercontent.com/Shashank02051997/FancyGifDialog-Android/master/GIF's/gif14.gif"),
                                                      title: Text(
                                                          isPrimeMember
                                                              ? 'Click Buy Now to enroll'
                                                              : 'Buy Prime Membership + Course Combo or only Prime',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                      description: Text(
                                                        isPrimeMember
                                                            ? 'Enroll to the course'
                                                            : 'Press Buy Combo to buy both or press Buy prime to only buy Prime membership',
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      buttonCancelText:
                                                          Text("Buy Prime"),
                                                      buttonCancelColor:
                                                          gradientColor1,
                                                      buttonOkColor:
                                                          gradientColor2,
                                                      buttonOkText: Text(
                                                          isPrimeMember
                                                              ? "Buy Course"
                                                              : "Buy Combo"),
                                                      entryAnimation:
                                                          EntryAnimation.BOTTOM,
                                                      onOkButtonPressed: () {
                                                        openCheckout(
                                                            isPrimeMember
                                                                ? (amount)
                                                                : (amount +
                                                                    10000));
                                                      },
                                                      onCancelButtonPressed:
                                                          () {
                                                        openCheckout((10000));
                                                      },
                                                      onlyOkButton:
                                                          isPrimeMember
                                                              ? true
                                                              : false,
                                                    ));
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 8.0,
                                                bottom: 8,
                                                left: 39,
                                                right: 39),
                                            child: Text(
                                              "Enroll Now",
                                              style: TextStyle(
                                                  color: white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
            drawDivider(),
            drawCourseName(courseIndex, categoryIndex),
            drawDivider(),
            drawLessonsButton(courseIndex, categoryIndex),
            drawDivider(),
            comingSoon
                ? Container()
                : drawDemoLessonsButton(courseIndex, categoryIndex),
            comingSoon ? Container() : drawDivider(),
            // Description Box
            drawDescriptionBox(courseIndex, categoryIndex),
            drawDivider(),
            // Rating Box
            drawRatingBox(courseIndex, categoryIndex),
            showEducators ? drawDivider() : Container(),
            showEducators ? drawEducatorsBox() : Container(),
            drawDivider(),
            drawCommentPopUp(courseIndex, categoryIndex),
          ],
        ),
      ),
    );
  }
}
