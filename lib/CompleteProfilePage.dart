import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:unitedindians/HomePage.dart';
import 'package:unitedindians/services/authService.dart';
import 'package:unitedindians/services/completeProfile.dart';
import 'package:unitedindians/values/colors.dart';
import 'package:unitedindians/values/config.dart';
import 'package:date_time_format/date_time_format.dart';

class CompleteProfilepage extends StatefulWidget {
  @override
  _CompleteProfilepageState createState() => _CompleteProfilepageState();
}

class _CompleteProfilepageState extends State<CompleteProfilepage> {
  String address = '';
  String dob = '';
  String dor = '';
  String education = '';
  String email = '';
  String name = '';

  String reference = '';
  String refName = '';
  String state = '';
  String username = '';
  String wnumber = '';
  final profileFormKey = new GlobalKey<FormState>();
  bool _autovalidate = false;
  TextEditingController dateCtl = TextEditingController();

  createUser(CompleteProfile userProfile) async {
    DatabaseReference userEntry = FirebaseDatabase.instance
        .reference()
        .child("Users")
        .child(FirebaseAuth.instance.currentUser.uid.toString())
        .child("Info");
    userEntry.child("email").set(userProfile.email);
    userEntry.child("address").set(userProfile.address);
    userEntry.child("dob").set(userProfile.dob);
    userEntry.child("dor").set(userProfile.dor);
    userEntry.child("education").set(userProfile.education);
    userEntry.child("number").set(userProfile.number);
    userEntry.child("reference").set(userProfile.reference);
    userEntry.child("paid").set(userProfile.paid);
    userEntry.child("state").set(userProfile.state);
    userEntry.child("name").set(userProfile.name);
    userEntry.child("password").set(userProfile.password);
    userEntry.child("refName").set(userProfile.refName);
    userEntry.child("wnumber").set(userProfile.wnumber);
    userEntry.child("username").set(userProfile.username).then((value) {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => HomePage()),
      // );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    });
    // userEntry.child("").set(userProfile.);
  }

  Future _selectDate() async {
    DateTime picked = await showDatePicker(
      context: context,
      initialDate: new DateTime(2000, 03, 22),
      firstDate: new DateTime(1980),
      lastDate: new DateTime(2020),
      initialEntryMode: DatePickerEntryMode.calendar,
    );
    if (picked != null)
      setState(() {
        print(DateTimeFormat.format(picked, format: 'd/m/Y'));

        this.dob = DateTimeFormat.format(picked, format: 'd/m/Y').toString();
        // this.dob = picked.toLocal().toString().split(' ')[0];
        dateCtl.text =
            DateTimeFormat.format(picked, format: 'd/m/Y').toString();
        // picked.toLocal().toString().split(' ')[0].replaceAll("-", "/");
      });
  }
  DateTime currentBackPressTime;
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || 
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: "Do you really want to exit ?");
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: onWillPop,
              child: Container(
          decoration: bodyBackgroundDecoration,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 28.0,
                  left: 20,
                  right: 20,
                ),
                child: Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        height: 20,
                      ),

                      // Complete profile heading
                      Container(
                        width: double.infinity,
                        child: Text(
                          "Complete Profile",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                new Shadow(
                                  offset: Offset(
                                    1.5,
                                    1.5,
                                  ),
                                  color: shadowBlack,
                                  blurRadius: 6,
                                )
                              ]),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),

                      // form fields
                      Form(
                          key: profileFormKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Name
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 28.0, right: 28, top: 0, bottom: 5),
                                child: TextFormField(
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return '';
                                    } else {
                                      return null;
                                    }
                                  },
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.person),
                                    labelText: "Name",

                                    //validator
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      this.name = value;
                                    });
                                  },
                                ),
                              ),

                              // E mail
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 28.0, right: 28, top: 0, bottom: 5),
                                child: TextFormField(
                                  autovalidate: _autovalidate,
                                  validator: (value) {
                                    Pattern pattern =
                                        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                    RegExp regex = new RegExp(pattern);
                                    if (!regex.hasMatch(value))
                                      return 'Enter Valid Email';
                                    else
                                      return null;
                                  },
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.alternate_email),
                                    labelText: "E-Mail",

                                    //validator
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      this.email = value;
                                    });
                                  },
                                ),
                              ),

                              // DOB
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 28.0, right: 28, top: 0, bottom: 5),
                                child: TextFormField(
                                  controller: dateCtl,
                                  onTap: () {
                                    FocusScope.of(context)
                                        .requestFocus(new FocusNode());
                                    _selectDate();
                                  },
                                  keyboardType: TextInputType.datetime,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.date_range),
                                    labelText: "Date of Birth",
                                    //validator
                                  ),
                                ),
                              ),
                              // Education
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 28.0, right: 28, top: 0, bottom: 5),
                                child: TextFormField(
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return '';
                                    } else {
                                      return null;
                                    }
                                  },
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.menu_book_rounded),
                                    labelText: "Education",
                                    //validator
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      this.education = value;
                                    });
                                  },
                                ),
                              ),

                              // Reference
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 28.0, right: 28, top: 0, bottom: 5),
                                child: TextFormField(
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return '';
                                    } else {
                                      return null;
                                    }
                                  },
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.work),
                                    labelText: "Reference",
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      this.reference = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          )),
                      SizedBox(
                        height: 20,
                      ),

                      //Proceed Button

                      Container(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              right: 15, left: 8, bottom: 25),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25)),
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
                              onPressed: () {
                                if (profileFormKey.currentState.validate()) {
                                  createUser(new CompleteProfile(
                                    this.address,
                                    this.dob,
                                    this.education,
                                    this.email,
                                    this.name,
                                    this.reference,
                                    this.state,
                                  ));
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Enter Valid Info",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 8.0, bottom: 8, left: 39, right: 39),
                                child: Text(
                                  "Proceed",
                                  style: TextStyle(
                                      color: white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                    onPressed: Authservice().signOut,
                    child: Text(
                      "Change Number ? Logout",
                      style: TextStyle(color: white),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
