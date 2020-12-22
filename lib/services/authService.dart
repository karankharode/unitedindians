import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unitedindians/CompleteProfilePage.dart';
import 'package:unitedindians/HomePage.dart';
import 'package:unitedindians/LoginPage.dart';
import 'package:unitedindians/values/config.dart';

bool isProfileComplete = true;
String authValue;

class Authservice {
  //Handles Auth
  handleAuth() {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            return handleProfile();
          } else {
            return LoginPage();
          }
        });
  }

  handleProfile() {
    return StreamBuilder(
        stream: FirebaseDatabase.instance
            .reference()
            .child("Users")
            .child(FirebaseAuth.instance.currentUser.uid)
            .child("Info")
            .child("name")
            .once()
            .asStream(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data.value == null) {
              return CompleteProfilepage();
            } else {
              return HomePage();
            }
          }
          return HomePage();
        });
  }

  //Sign out Profile Page
  signOutProfile(BuildContext context) {
    FirebaseAuth.instance.signOut().then((value) {
      // _selectedIndex = 0;
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
    otpTextfieldVisibility = false;
    phoneNumberVisibility = true;
  }

  //Sign out
  signOut() {
    FirebaseAuth.instance.signOut();
    otpTextfieldVisibility = false;
    phoneNumberVisibility = true;
  }

  //SignIn
  signIn(AuthCredential authCreds) {
    FirebaseAuth.instance.signInWithCredential(authCreds);
  }

  signInWithOTP(smsCode, verId) {
    AuthCredential authCreds =
        PhoneAuthProvider.credential(verificationId: verId, smsCode: smsCode);
    signIn(authCreds);
  }
}
