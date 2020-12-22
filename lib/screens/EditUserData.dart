import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:unitedindians/values/User.dart';
import 'package:unitedindians/values/colors.dart';
import 'package:unitedindians/values/config.dart';

class EditUserData extends StatefulWidget {
  @override
  _EditUserDataState createState() => _EditUserDataState();
}

class _EditUserDataState extends State<EditUserData> {
  String address = currentUserData[0].address;
  String dob = currentUserData[0].dob;
  String education = currentUserData[0].education;
  String email = currentUserData[0].email;
  String name = currentUserData[0].name;
  String reference = currentUserData[0].reference;
  String refName = currentUserData[0].refName;
  String state = currentUserData[0].state;
  String username = currentUserData[0].username;
  String wnumber = currentUserData[0].wnumber;

  TextStyle headingStyle =
      TextStyle(fontSize: 19, color: white, fontWeight: FontWeight.bold);
  TextStyle nameStyle =
      TextStyle(fontSize: 17, color: white, fontWeight: FontWeight.bold);
  TextStyle descriptionStyle = TextStyle(fontSize: 11, color: white);
  TextStyle hintTextStyle = TextStyle(fontSize: 13, color: shadowGrey);
  TextStyle formTextStyle =
      TextStyle(color: white, fontWeight: FontWeight.bold);

  final userFormKey = new GlobalKey<FormState>();
  bool _autovalidate = false;
  TextEditingController dateCtl = TextEditingController();

  Future<void> _updateUserData(UserData userProfile) async {
    DatabaseReference userEntry = FirebaseDatabase.instance
        .reference()
        .child("Users")
        .child(FirebaseAuth.instance.currentUser.uid.toString())
        .child("Info");
    userEntry.child("email").set(userProfile.email);
    userEntry.child("address").set(userProfile.address);
    userEntry.child("dob").set(userProfile.dob);
    userEntry.child("education").set(userProfile.education);
    userEntry.child("number").set(userProfile.number);
    userEntry.child("reference").set(userProfile.reference);
    userEntry.child("state").set(userProfile.state);
    userEntry.child("name").set(userProfile.name);
    userEntry.child("refName").set(userProfile.refName);
    userEntry.child("wnumber").set(userProfile.wnumber);
    await userEntry
        .child("username")
        .set(userProfile.username)
        .whenComplete(() {
      super.setState(() {
        currentUserData[0].name = userProfile.name;
      });
      Navigator.of(context).pop();
    });
  }

  // Future _selectDate() async {
  //   DateTime picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.tryParse(currentUserData[0].dob) ?? DateTime(2001),
  //     firstDate: new DateTime(1980),
  //     lastDate: new DateTime(2020),
  //     initialEntryMode: DatePickerEntryMode.calendar,
  //   );
  //   if (picked != null) {
  //     // print(DateTimeFormat.format(picked, format: 'd/m/Y'));
  //     setState(() {
  //       dateCtl.text =
  //           DateTimeFormat.format(picked, format: 'd/m/Y').toString();
  //       // picked.toLocal().toString().split(' ')[0].replaceAll("-", "/");
  //     });
  //   }
  // }

  Widget buildUpdateForm() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Container(
                decoration: courseDetailsPageDecoration,
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Form(
                        key: userFormKey,
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
                                initialValue: currentUserData[0].name,
                                style: formTextStyle,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: white,
                                  ),
                                  labelText: "Name",
                                  labelStyle: TextStyle(color: white),
                                  counterStyle: formTextStyle,
                                  fillColor: white,

                                  //validator
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    this.name = value;
                                  });
                                },
                              ),
                            ),

                            // UserName
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
                                initialValue: currentUserData[0].username,
                                style: formTextStyle,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: white,
                                  ),
                                  labelText: "Username",
                                  labelStyle: TextStyle(color: white),
                                  counterStyle: formTextStyle,
                                  fillColor: white,
                                  //validator
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    this.username = value;
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
                                initialValue: currentUserData[0].email,
                                style: formTextStyle,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.alternate_email,
                                    color: white,
                                  ),
                                  labelText: "E-Mail",
                                  labelStyle: TextStyle(color: white),

                                  //validator
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    this.email = value;
                                  });
                                },
                              ),
                            ),

                            // // DOB
                            // Padding(
                            //   padding: const EdgeInsets.only(
                            //       left: 28.0, right: 28, top: 0, bottom: 5),
                            //   child: TextFormField(
                            //     controller: dateCtl,
                            //     onTap: () {
                            //       FocusScope.of(context)
                            //           .requestFocus(new FocusNode());
                            //       _selectDate();
                            //     },
                            //     onFieldSubmitted: (value) {
                            //       print(value);
                            //       setState(() {
                            //         this.dob = dateCtl.text;
                            //       });
                            //     },
                            //     onChanged: (value) {
                            //       print(value);
                            //       setState(() {
                            //         this.dob = dateCtl.text;
                            //       });
                            //     },
                            //     keyboardType: TextInputType.datetime,
                            //     style: formTextStyle,
                            //     decoration: InputDecoration(
                            //       hintText: currentUserData[0].dob,
                            //       prefixIcon: Icon(
                            //         Icons.date_range,
                            //         color: white,
                            //       ),
                            //       labelText: "Date of Birth",
                            //       labelStyle: TextStyle(color: white),
                            //       //validator
                            //     ),
                            //   ),
                            // ),
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
                                initialValue: currentUserData[0].education,
                                style: formTextStyle,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.menu_book_rounded,
                                    color: white,
                                  ),
                                  labelText: "Education",
                                  labelStyle: TextStyle(color: white),
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
                                initialValue: currentUserData[0].reference,
                                style: formTextStyle,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.work,
                                    color: white,
                                  ),
                                  labelText: "Reference",
                                  labelStyle: TextStyle(color: white),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: bodyBackgroundDecoration,
          child: ListView(children: [
            SizedBox(
              height: 10,
            ),
            // profile heading
            Padding(
              padding: const EdgeInsets.only(top: 18.0, bottom: 10, left: 25),
              child: Container(
                child: Text(
                  "Edit Profile",
                  style: headingStyle,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            // profile box
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // image box
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Container(
                    height: MediaQuery.of(context).size.width / 5.5,
                    width: MediaQuery.of(context).size.width / 5.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: white,
                      image: DecorationImage(
                        image: AssetImage(
                          "assets/images/profile.png",
                        ),
                      ),
                    ),
                  ),
                ),
                // name and number box
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.5,
                    height: MediaQuery.of(context).size.width / 5.5,
                    decoration: courseDetailsPageDecoration,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                currentUserData[0].name,
                                style: nameStyle,
                              ),
                              Text(
                                currentUserData[0].number,
                                style: descriptionStyle,
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),

            // editing box
            buildUpdateForm(),

            //Proceed Button

            Container(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 15, left: 8, bottom: 25),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(25)),
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
                      if (userFormKey.currentState.validate()) {
                        _updateUserData(new UserData(
                            this.address,
                            // dateCtl.text,
                            currentUserData[0].dob,
                            this.education,
                            this.email,
                            this.name,
                            currentUserData[0].paid ?? isPrimeMember.toString(),
                            this.reference,
                            this.state,
                            this.username,
                            this.wnumber));
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
                        "Save",
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
          ])),
    );
  }
}
