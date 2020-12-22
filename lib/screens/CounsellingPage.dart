import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CounsellingPage extends StatefulWidget {
  @override
  _CounsellingPageState createState() => _CounsellingPageState();
}

class _CounsellingPageState extends State<CounsellingPage> {
  DatabaseReference databaseReference;
  bool fetchCompleted = false;
  bool fetchCategoryCompleted = false;

  Future<void> getCounsellingCategories() async {
    if (!fetchCategoryCompleted) {
      await databaseReference
          .child("Counselling")
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      
    );
  }
}