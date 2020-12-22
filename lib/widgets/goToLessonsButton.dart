import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:unitedindians/screens/LessonsPage.dart';
import 'package:unitedindians/values/colors.dart';

Widget buildLessonsButton(String buttontext, BuildContext context,int index, int courseIndexRecieved) {
  return Container(
    alignment: Alignment.center,
    child: Padding(
      padding: const EdgeInsets.only(right: 15, left: 8, bottom: 25,top: 6),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(25)),
            boxShadow: [
              new BoxShadow(
                  color: shadowBlack,
                  blurRadius: 2,
                  spreadRadius: 1,
                  offset: Offset(1, 1))
            ],
            gradient: LinearGradient(colors: [gradientColor1, gradientColor2])),
        child: FlatButton(
          onPressed: () {
            Navigator.push(
                context,
                PageTransition(
                    child: LessonsPage(index,courseIndexRecieved),
                    type: PageTransitionType.rightToLeftWithFade,
                    duration: Duration(milliseconds: 400)));
          },
          child: Padding(
            padding:
                const EdgeInsets.only(top: 8.0, bottom: 8, left: 39, right: 39),
            child: Text(
              buttontext,
              style: TextStyle(
                  color: white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    ),
  );
}
