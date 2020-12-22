import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unitedindians/values/colors.dart';
import 'package:unitedindians/values/coursedata.dart';

class LockedBanner extends StatelessWidget {
  final int categoryIndex;
  final int courseIndex;
  final bool comingSoon;
  LockedBanner(this.categoryIndex, this.courseIndex,this.comingSoon);
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: height / 3.8,
        decoration: BoxDecoration(
            border: new Border.all(
              color: white,
            ),
            borderRadius: BorderRadius.all(Radius.circular(12)),
            image: DecorationImage(
                image: NetworkImage(categoryList[categoryIndex]
                    .courseDataListModelList[courseIndex]
                    .main_banner),
                fit: BoxFit.fill)),
        child: !comingSoon
            ? Container()
            : BackdropFilter(
                filter: ImageFilter.blur(),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    color: Colors.black.withOpacity(0.7),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.lock,
                      color: grey,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
