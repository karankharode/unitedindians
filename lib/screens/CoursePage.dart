import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:page_transition/page_transition.dart';
import 'package:unitedindians/screens/CourseDetailsPage.dart';
import 'package:unitedindians/values/colors.dart';
import 'package:unitedindians/values/coursedata.dart';

List<String> imgList = [];

bool fetchCompleted = false;
bool fetchCategoryCompleted = false;

class Coursepage extends StatefulWidget {
  @override
  _CoursepageState createState() => _CoursepageState();
}

class _CoursepageState extends State<Coursepage> {
  Future future;
  DatabaseReference databaseReference;

  Future<void> getBannerImage() async {
    if (!fetchCompleted) {
      await databaseReference
          .child('Banners')
          .once()
          .then((DataSnapshot dataSnapshot) {
        var data = dataSnapshot.value;
        imgList.clear();
        // int nullChecker = 0;
        data.forEach((key, value) {
          if (value == null) {
          } else {
            setState(() {
              imgList.add(value['pic'].toString());
            });
          }
        });
      }).then((value) {
        setState(() {
          fetchCompleted = true;
        });
      });
      return 0;
    } else {
      return 0;
    }
  }

  Future<void> getData(DataSnapshot dataSnapshot) async {
    categoryList = [];
    Map<dynamic, dynamic> categoryData = dataSnapshot.value;
    categoryData.forEach((key, value) {
      courseDataList.clear();
      categoryNames.add(key);
      Map<dynamic, dynamic> subCategoryData = dataSnapshot.value[key];

      subCategoryData.forEach((key, value) {
        if (value['Info']['hide'] != "true") {
          courseDataList.add(new courseData(
            value['Info']['banner_square'],
            value['Info']['coming_soon'],
            value['Info']['dateAdded'],
            value['Info']['description'],
            value['Info']['discountPrice'],
            value['Info']['free'],
            value['Info']['hide'],
            value['Info']['listing'],
            value['Info']['main_banner'],
            key,
            value['Info']['name'],
            value['Info']['open'],
            value['Info']['sellingPrice'],
          ));
        }
      });
      categoryList.add(new courseDataListModel(courseDataList.toList()));
    });
  }

  Future<void> getCourses() async {
    if (!fetchCategoryCompleted) {
      await databaseReference
          .child("Courses")
          .once()
          .then((DataSnapshot dataSnapshot) async {
        await getData(dataSnapshot);
        setState(() {
          fetchCategoryCompleted = true;
        });
      });
    } else {
      return 0;
    }
  }

  void initState() {
    databaseReference = FirebaseDatabase.instance.reference();
    future = getCourses();
    super.initState();
  }

  Widget buildCorouselSlider() {
    return FutureBuilder(
        future: getBannerImage(),
        builder: (context, AsyncSnapshot snapshot) {
          List<Widget> imageSliders = imgList
              .map((item) => Container(
                    child: Container(
                      child: Stack(
                        children: <Widget>[
                          ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(7.0)),
                              child: Image.network(item)),
                          //  child: FadeInImage.assetNetwork(placeholder: "assets/images/blur_bg.jpg", image: item,)),
                        ],
                      ),
                    ),
                  ))
              .toList();
          return CarouselSlider(
            options: CarouselOptions(
              autoPlay: true,
              autoPlayAnimationDuration: Duration(seconds: 2),
              autoPlayInterval: Duration(seconds: 9),
              aspectRatio: 3,
              enlargeCenterPage: true,
              viewportFraction: 0.79,
            ),
            items: imageSliders,
          );
        });
  }

  Widget buildCategoryName(int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            categoryNames[index],
            style: TextStyle(color: white, fontSize: 17),
          ),
          IconButton(
              icon: Icon(
                Icons.arrow_forward,
                color: white,
              ),
              onPressed: null)
        ],
      ),
    );
  }

  Widget buildCategoryView() {
    var boxWidth = MediaQuery.of(context).size.width - 48;

    return Container(
      height: (MediaQuery.of(context).size.height / 1.4) + 10,
      child: Container(
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 8),
          scrollDirection: Axis.vertical,
          itemCount: categoryList.length,
          itemBuilder: (context, index) {
            return Padding(
                padding: const EdgeInsets.only(bottom: 2, top: 2),
                child: Column(
                  children: [
                    buildCategoryName(index),
                    Container(
                      height: (MediaQuery.of(context).size.width / 2.1),
                      child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.only(
                              left: 8, top: 4, bottom: 4, right: 4),
                          scrollDirection: Axis.horizontal,
                          itemCount: categoryList[index]
                              .courseDataListModelList
                              .length,
                          itemBuilder: (context, courseIndex) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 6.0, top: 9, bottom: 9, right: 8),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                        child: CourseDetailsPage(
                                            index, courseIndex),
                                        type: PageTransitionType.rightToLeft,
                                      ));
                                },
                                child: Container(
                                  width: boxWidth,
                                  decoration: BoxDecoration(
                                      color: white,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 14.0, bottom: 14),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          height: boxWidth / 2.4,
                                          width: boxWidth / 2.4,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  bottomRight:
                                                      Radius.circular(10),
                                                  topRight:
                                                      Radius.circular(10))),
                                          child: ClipRRect(
                                              borderRadius: BorderRadius.only(
                                                  bottomRight:
                                                      Radius.circular(12),
                                                  topRight:
                                                      Radius.circular(12)),
                                              // child: Image.network(
                                              //   categoryList[index]
                                              //       .courseDataListModelList
                                              //       .elementAt(courseIndex)
                                              //       .banner_square,
                                              //   fit: BoxFit.fill,
                                              // ),
                                              child: FadeInImage.assetNetwork(
                                                placeholder:
                                                    "assets/images/blur_bg.jpg",
                                                image: categoryList[index]
                                                    .courseDataListModelList
                                                    .elementAt(courseIndex)
                                                    .banner_square,
                                                fit: BoxFit.fill,
                                              )),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15.0, bottom: 12),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                width: boxWidth / 1.9,
                                                decoration: BoxDecoration(
                                                    color: gradientColor1,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            bottomLeft: Radius
                                                                .circular(12),
                                                            topLeft:
                                                                Radius.circular(
                                                                    12))),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10.0,
                                                          top: 12,
                                                          right: 32,
                                                          bottom: 12),
                                                  child: Text(
                                                    "${categoryList[index].courseDataListModelList.elementAt(courseIndex).name}",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: boxWidth / 2,
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      categoryList[index]
                                                          .courseDataListModelList
                                                          .elementAt(
                                                              courseIndex)
                                                          .description,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                          fontSize: 11),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  right: 5),
                                                          child: Text(
                                                            " \u20B9 ${categoryList[index].courseDataListModelList[courseIndex].discountPrice}",
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 2.0,
                                                                  right: 2),
                                                          child: Text(
                                                            " \u20B9 ${categoryList[index].courseDataListModelList[courseIndex].sellingPrice}",
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                decoration:
                                                                    TextDecoration
                                                                        .lineThrough),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                  ],
                ));
          },
        ),
      ),
    );
  }

  Widget buildHeading() {
    return Padding(
      padding:
          const EdgeInsets.only(top: 14.0, bottom: 16, left: 12, right: 12),
      child: Container(
        decoration: BoxDecoration(
          color: colorPrimary,
          border: new Border.all(color: white, width: 2),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Center(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              Text("UI FORUMS", style: TextStyle(color: white, fontSize: 18)),
        )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: [
          // buildHeading(),
          SizedBox(
            height: 10,
          ),
          buildCorouselSlider(),
          fetchCategoryCompleted
              ? buildCategoryView()
              : Center(
                  child: CircularProgressIndicator(backgroundColor: white)),
        ],
      ),
    );
  }
}
