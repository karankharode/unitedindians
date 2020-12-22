import 'package:flutter/cupertino.dart';

import 'colors.dart';

bool otpTextfieldVisibility = false;
bool phoneNumberVisibility = true;
String userSmsCode = '';
String loginButtonText = "Send OTP";
bool isPrimeMember = false;
int selectedIndex = 0;
int pageIndex = 0;

BoxDecoration courseDetailsPageDecoration = BoxDecoration(
    color: colorBlockBackground,
    borderRadius: BorderRadius.all(Radius.circular(20)));

BoxDecoration commentDecoration = BoxDecoration(
    color: white,
    borderRadius: BorderRadius.all(Radius.circular(10)));    

BoxDecoration bodyBackgroundDecoration = BoxDecoration(
  image: DecorationImage(
      image: AssetImage(
        'assets/images/bg_vector.png',
      ),
      alignment: Alignment.bottomCenter,
      fit: BoxFit.scaleDown),
  gradient: LinearGradient(
    colors: [colorPrimaryDark, colorPrimary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ),
);
BoxDecoration buttonDecoration = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(25)),
    boxShadow: [
      new BoxShadow(
          color: shadowBlack,
          blurRadius: 2,
          spreadRadius: 1,
          offset: Offset(1, 1))
    ],
    gradient: LinearGradient(colors: [gradientColor1, gradientColor2]));
BoxDecoration flatButtonDecoration = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(15)),
    gradient: LinearGradient(colors: [gradientColor1, gradientColor2]));
