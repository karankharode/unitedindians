import 'package:firebase_auth/firebase_auth.dart';

class UserData {
  String address = '';
  String dob = '';
  String education = '';
  String email = '';
  String name = '';
  String number = FirebaseAuth.instance.currentUser.phoneNumber;
  String paid = '';
  String reference = '';
  String refName = '';
  String state = '';
  String username = '';
  String wnumber = '';
  UserData(
    this.address,
    this.dob,
    this.education,
    this.email,
    this.name,
    this.paid,
    this.reference,
    this.state,
    this.username,
    this.wnumber
    
  );

}

List<UserData> currentUserData = [UserData(
    " ",
    " ",
    " ",
    " ",
    " ",
    " ",
    " ",
    " ",
    " ",    
    " ",    
  )];