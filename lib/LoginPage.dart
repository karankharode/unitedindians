import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:unitedindians/services/authService.dart';
import 'package:unitedindians/values/colors.dart';
import 'package:unitedindians/values/config.dart';

String buttontext = "Login";

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class SimCardServices {
  //  List<SimCard> simCard = [];

  // static List<String> getSuggestions(String query) {
  //   List<String> matches = List();
  //   // matches.addAll(simCard);
  //   matches.retainWhere((s) =>   s.toLowerCase().contains(query.toLowerCase()));
  //   return matches;
  // }
}


class _LoginPageState extends State<LoginPage> {
  final formKey = new GlobalKey<FormState>();
  String phoneNo, verificationId, smsCode;
  int _forceResendingToken;
  bool codeSent = false;
  bool codeReSent = false;

  // mobile no suggestion
  // final TextEditingController _typeAheadController = TextEditingController();
  // String _mobileNumber = '';

  @override
  void initState() {
    super.initState();
    // MobileNumber.listenPhonePermission((isPermissionGranted) {
    //   if (isPermissionGranted) {
    //     initMobileNumberState();
    //   } else {}
    // });

    // initMobileNumberState();

    codeSent = false;
    codeReSent = false;
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  // Future<void> initMobileNumberState() async {
  //   if (!await MobileNumber.hasPhonePermission) {
  //     await MobileNumber.requestPhonePermission;
  //     return;
  //   }
  //   String mobileNumber = '';
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     mobileNumber = await MobileNumber.mobileNumber;
  //     SimCardServices().simCard = await MobileNumber.getSimCards;
  //   } on PlatformException catch (e) {
  //     debugPrint("Failed to get mobile number because of '${e.message}'");
  //   }

  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) return;

  //   setState(() {
  //     _mobileNumber = mobileNumber;
  //   });
  // }
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
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: WillPopScope(
        onWillPop: onWillPop,
              child: Container(
          decoration: bodyBackgroundDecoration,
          child: ListView(
            padding: EdgeInsets.zero,
            physics: NeverScrollableScrollPhysics(),
            children: [
              // Top Heading
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Container(
                  height: (height / 5) + 5,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage(
                        "assets/images/top_vector.png",
                      ),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "UNITED INDIANS",
                      style: TextStyle(
                          fontFamily: "vow",
                          fontSize: 35,
                          color: white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              // Login box
              Padding(
                padding: const EdgeInsets.only(
                    left: 24.0, right: 24, top: 8, bottom: 5),
                child: Container(
                  height: 3 * (height / 5) - 10,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage("assets/images/login_shape_bg.png"),
                    fit: BoxFit.fill,
                  )),

                  //  Box Contents

                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // LOGIN
                        Container(
                          width: double.infinity,
                          child: Text(
                            "LOGIN",
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
                        Column(children: [
                          // Phone number
                          Visibility(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 28.0, right: 28, top: 0, bottom: 5),
                              // child: TypeAheadFormField(
                              //   textFieldConfiguration: TextFieldConfiguration(
                              //       controller: this._typeAheadController,
                              //       decoration: InputDecoration(
                              //         prefixIcon: Icon(Icons.phone),
                              //         labelText: "+91  Phone Number",
                              //       )),
                              //   onSuggestionSelected: null,
                              //   itemBuilder: null,
                              //   suggestionsCallback: (pattern) {
                              //     return _simCard.getSuggestions(pattern);
                              //   },
                              // ),
                              child: TextFormField(
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Please Enter your Mobile Number";
                                  } else {
                                    if (value.length != 10) {
                                      return 'Enter Valid Number';
                                    } else {
                                      return null;
                                    }
                                  }
                                },
                                keyboardType: TextInputType.phone,
                                enableSuggestions: true,
                                autocorrect: true,
                                enableInteractiveSelection: true,
                                decoration: InputDecoration(
                              prefixIcon: Icon(Icons.phone),
                              labelText: "+91  Phone Number",
                                  //validator
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    this.phoneNo = value;
                                  });
                                },
                              ),
                            ),
                            visible: phoneNumberVisibility,
                          ),
                          // otp
                          Visibility(
                            visible: otpTextfieldVisibility,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 28.0, right: 28, top: 5, bottom: 0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value.length != 6) {
                                    return "Enter valid OTP";
                                  } else {
                                    return null;
                                  }
                                },
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.phone_iphone_rounded),
                                  hintText: "OTP",
                                  //validator validateandsave method globalkey formstate
                                ),
                                onChanged: (code) {
                                  setState(() {
                                    this.smsCode = code;
                                  });
                                },
                              ),
                            ),
                          ),
                        ]),
                        // add onPressed method acceptor parameter
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
                                  if (formKey.currentState.validate()) {
                                    setState(() {
                                      phoneNumberVisibility = false;
                                      otpTextfieldVisibility = true;
                                    });
                                    codeSent
                                        ? Authservice().signInWithOTP(
                                            smsCode, verificationId)
                                        : registerUser(phoneNo);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, bottom: 8, left: 39, right: 39),
                                  child: Text(
                                    codeSent ? "Login" : "Verify",
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
              ),
              codeSent
                  ? TextButton(
                      child: Text("Resend Code ?",
                          style: TextStyle(color: white),
                          textAlign: TextAlign.center),
                      onPressed: () {
                        codeResent();
                        registerUser(phoneNo);
                      },
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }

  otpTextFieldVisibilitySetter() {
    setState(() {
      phoneNumberVisibility = false;
      otpTextfieldVisibility = true;
    });
  }

  phoneTextFieldVisibilitySetter() {
    setState(() {
      phoneNumberVisibility = true;
      otpTextfieldVisibility = false;
      codeSent = false;
    });
  }

  codeResent() {
    setState(() {
      codeSent = true;
    });
  }

  Future<void> registerUser(mobile) async {
    final PhoneVerificationCompleted verified = (AuthCredential authResult) {
      Authservice().signIn(authResult);
    };
    final PhoneVerificationFailed verificationfailed =
        (FirebaseAuthException authException) {
      debugPrint('${authException.message}');
    };
    final PhoneCodeSent smsSent = (String verId, [int forceResendingToken]) {
      Fluttertoast.showToast(
          msg: "OTP Sent",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: gradientColor1,
          textColor: Colors.white,
          fontSize: 16.0);
      this.verificationId = verId;
      this._forceResendingToken = forceResendingToken;
      setState(() {
        this.codeSent = true;
      });
    };
    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      this.verificationId = verId;
    };
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91$mobile",
      timeout: const Duration(seconds: 5),
      forceResendingToken: _forceResendingToken,
      verificationCompleted: verified,
      verificationFailed: verificationfailed,
      codeSent: smsSent,
      codeAutoRetrievalTimeout: autoTimeout,
    );
  }
}
