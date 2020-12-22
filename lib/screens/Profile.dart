import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:unitedindians/screens/EditUserData.dart';
import 'package:unitedindians/services/date_time.dart';
import 'package:unitedindians/values/User.dart';
import 'package:unitedindians/values/colors.dart';
import 'package:unitedindians/values/config.dart';
import 'package:unitedindians/widgets/button.dart';
import 'package:unitedindians/widgets/profilePrimeButton.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
//razorpay
  static const platform = const MethodChannel("razorpay_flutter");
  Razorpay _razorpay;
  var finalAmount;
  String courseName;
  String description;
  bool isEnrolled = false;

  DatabaseReference databaseReference;

  TextStyle headingStyle =
      TextStyle(fontSize: 19, color: white, fontWeight: FontWeight.bold);
  TextStyle nameStyle =
      TextStyle(fontSize: 17, color: white, fontWeight: FontWeight.bold);
  TextStyle descriptionStyle = TextStyle(fontSize: 11, color: white);
  TextStyle hintTextStyle = TextStyle(fontSize: 13, color: shadowGrey);

  phoneTextFieldVisibilitySetter() {
    setState(() {
      phoneNumberVisibility = true;
      otpTextfieldVisibility = false;
      selectedIndex = 0;
      pageIndex = 0;
    });
  }

  void initState() {
    super.initState();
    databaseReference = FirebaseDatabase.instance.reference();
    _getUserData();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  //razorpay
  openCheckout() async {
    setState(() {
      finalAmount = 100;
    });
    description = "Prime Membership";

    var options = {
      // card - 4111 1111 1111 1111
      // 'key': 'rzp_live_SxBV5sId38OFu7',
      // prefill values
      'key': 'rzp_test_0sTTgVXKNPPfbQ', //test
      'amount': 10000,
      'name': 'UI Forums',
      'description': description,
      'prefill': {'contact': '7757885725', 'email': 'devtas.dts@gmail.com'},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e);
    }
  }

  void _primeMembershipEnrolling() {
    databaseReference
        .child("Users")
        .child(FirebaseAuth.instance.currentUser.uid)
        .child("Info")
        .child("paid")
        .set("true");
  }

  // Razorpay methods
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // prime membership
    _primeMembershipEnrolling();
    setState(() {
      isPrimeMember = true;
    });
    databaseReference.child("Payment").push().set({
      "amount": finalAmount.toString(),
      "course": "Prime Membership",
      "date_time": GMTDateTime().sendingTime(),
      "email": currentUserData[0].email,
      "name": currentUserData[0].name,
      "uid": FirebaseAuth.instance.currentUser.uid,
    });
    Fluttertoast.showToast(
        backgroundColor: Colors.greenAccent,
        toastLength: Toast.LENGTH_LONG,
        textColor: black,
        msg: "Yeah ! Now you are a prime member !");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: "ERROR: " + response.code.toString() + " - " + response.message,
        timeInSecForIosWeb: 4);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName, timeInSecForIosWeb: 4);
  }

  void _editUserData() {
    Navigator.push(
        context,
        PageTransition(
            child: EditUserData(),
            type: PageTransitionType.rightToLeftWithFade));
  }

  Future<void> _getUserData() async {
    try {
      await databaseReference
          .child("Users")
          .child(FirebaseAuth.instance.currentUser.uid)
          .child("Info")
          .once()
          .then((DataSnapshot dataSnapshot) {
        currentUserData.clear();
        setState(() {
          currentUserData.add(new UserData(
            dataSnapshot.value["address"],
            dataSnapshot.value["dob"],
            dataSnapshot.value["education"],
            dataSnapshot.value["email"],
            dataSnapshot.value["name"],
            dataSnapshot.value["paid"],
            dataSnapshot.value["reference"],
            dataSnapshot.value["state"],
            dataSnapshot.value["username"],
            dataSnapshot.value["wnumber"],
          ));
          if (dataSnapshot.value["paid"] == "true") {
            setState(() {
              isPrimeMember = true;
            });
          }
        });
      });
    } catch (e) {
      debugPrint(e);
      setState(() {
        currentUserData.add(new UserData(
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
        ));
      });
    }
  }

  Widget drawDivider() {
    return Divider(
      color: shadowGrey,
      indent: 40,
      endIndent: 40,
    );
  }

  Widget buildHeadingDatablock(String heading, String data, IconData dataIcon) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 2, bottom: 2),
      child: Container(
        decoration: courseDetailsPageDecoration,
        child: Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                dataIcon,
                color: white,
              ),
              SizedBox(
                width: 9,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    heading,
                    style: descriptionStyle,
                  ),
                  (data == "")
                      ? Text("Enter $heading", style: hintTextStyle)
                      : Text(
                          data,
                          style: nameStyle,
                        ),
                  SizedBox(
                    height: 15,
                  ),
                ],
              ),
              (data == "")
                  ? IconButton(
                      icon: Icon(
                        Icons.mode_edit,
                        color: white,
                      ),
                      onPressed: () {
                        _editUserData();
                      })
                  : Container()
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDataBlock() {
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
              buildHeadingDatablock(
                  "Email", currentUserData[0].email, Icons.alternate_email),
              drawDivider(),
              buildHeadingDatablock(
                  "Username", currentUserData[0].username, Icons.tag),
              drawDivider(),
              buildHeadingDatablock("Education", currentUserData[0].education,
                  Icons.menu_book_rounded),
              drawDivider(),
              buildHeadingDatablock(
                  "Reference", currentUserData[0].reference, Icons.work),
              drawDivider(),
              buildHeadingDatablock(
                  "DOB", currentUserData[0].dob, Icons.date_range),
              drawDivider(),
              buildHeadingDatablock("State", currentUserData[0].state,
                  Icons.photo_size_select_actual_outlined),
              drawDivider(),
              buildHeadingDatablock(
                  "WhatsApp Number", currentUserData[0].wnumber, Icons.message),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: [
          SizedBox(
            height: 10,
          ),
          // profile heading
          Padding(
            padding: const EdgeInsets.only(top: 18.0, bottom: 10, left: 25),
            child: Container(
              child: Text(
                "Profile",
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
                        IconButton(
                            icon: Icon(
                              Icons.mode_edit,
                              color: white,
                            ),
                            onPressed: () {
                              _editUserData();
                            }),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
          // data box
          // buildDataBlock(),

          //PrimeButton
          SizedBox(
            height: 20,
          ),
          Center(
              child: buildProfilePrimeButton(
                  isPrimeMember
                      ? "You are a Prime Member"
                      : "Get Prime Membership now ! ",
                  openCheckout,
                  context)),
          // Logout button
          Center(
              child: buildButton(
                  "Logout", phoneTextFieldVisibilitySetter(), context)),
        ],
      ),
    );
  }
}
