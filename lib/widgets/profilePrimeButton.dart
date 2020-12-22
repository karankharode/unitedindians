import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unitedindians/values/colors.dart';
import 'package:unitedindians/values/config.dart';

Widget buildProfilePrimeButton(
    String buttontext, Function openCheckout, BuildContext context) {
  // add onPressed method acceoptor parameter
  return Container(
    alignment: Alignment.center,
    child: Padding(
      padding: const EdgeInsets.only(right: 15, left: 8, bottom: 25),
      child: Container(
        decoration: buttonDecoration,
        child: FlatButton(
          onPressed: () {
            isPrimeMember
            ?null
            :openCheckout();
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
