import 'package:firebase_auth/firebase_auth.dart';
import 'package:unitedindians/services/date_time.dart';

String userName = '';

class CompleteProfile {
  String address = '';
  String dob = '';
  String dor = GMTDateTime().sendingTime();
  String education = '';
  String email = '';
  String name = '';
  String number = FirebaseAuth.instance.currentUser.phoneNumber;
  String reference = '';
  String paid = "false";
  String password = '';
  String refName = '';
  String state = '';
  String username = '';
  String wnumber = '';
  CompleteProfile(
    this.address,
    this.dob,
    this.education,
    this.email,
    this.name,
    this.reference,
    this.state,
  );
}

List<CompleteProfile> user = [];
