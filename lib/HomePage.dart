import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:unitedindians/screens/CoursePage.dart';
import 'package:unitedindians/screens/Profile.dart';
import 'package:unitedindians/values/User.dart';
import 'package:unitedindians/values/colors.dart';
import 'package:unitedindians/values/config.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabaseReference databaseReference;
  @override
  void initState() {
    databaseReference = FirebaseDatabase.instance.reference();
    _getUserData();
    super.initState();
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

  static List<Widget> bodyOptions = [
    Coursepage(),
    Center(
        child: Padding(
      padding: const EdgeInsets.all(58.0),
      child: Image.asset(
        "assets/images/coming_soon.png",
        fit: BoxFit.scaleDown,
      ),
    )),
    Center(
        child: Padding(
      padding: const EdgeInsets.all(58.0),
      child: Image.asset(
        "assets/images/coming_soon.png",
        fit: BoxFit.scaleDown,
      ),
    )),
    ProfilePage(),
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
      pageIndex = index;
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
    double iconHeight = 40;
    return Scaffold(
      backgroundColor: colorPrimary,
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 4,
          right: 4,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(29)),
          child: SizedBox(
            height: 62,
            child: BottomNavigationBar(
              items: [
                BottomNavigationBarItem(
                  icon: SizedBox(
                    height: iconHeight,
                    child: IconButton(
                      icon: Image.asset(
                        "assets/images/courses.png",
                      ),
                      onPressed: null,
                    ),
                  ),
                  title: Text("Courses"),
                ),
                BottomNavigationBarItem(
                  icon: SizedBox(
                    height: iconHeight,
                    child: IconButton(
                      icon: Image.asset("assets/images/counselling.png"),
                      onPressed: null,
                    ),
                  ),
                  title: Text(
                    "Tab",
                  ),
                ),
                BottomNavigationBarItem(
                  icon: SizedBox(
                    height: iconHeight,
                    child: IconButton(
                      icon: Image.asset("assets/images/forum.png"),
                      onPressed: null,
                    ),
                  ),
                  title: Text("Tab"),
                ),
                BottomNavigationBarItem(
                  icon: SizedBox(
                    height: iconHeight,
                    child: IconButton(
                      icon: Image.asset("assets/images/profile.png"),
                      onPressed: null,
                    ),
                  ),
                  title: Text("Profile"),
                ),
              ],
              onTap: onItemTapped,
              showUnselectedLabels: true,
              showSelectedLabels: true,
              selectedItemColor: darkGrey,
              unselectedItemColor: grey,
              type: BottomNavigationBarType.fixed,
              currentIndex: selectedIndex,
            ),
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: onWillPop,
        child: Container(
          decoration: bodyBackgroundDecoration,
          child: Center(child: bodyOptions.elementAt(pageIndex)),
        ),
      ),
    );
  }
}
