import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:unitedindians/services/authService.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UI Forums',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: "product",
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
     home: Authservice().handleAuth(),
    //  home: HomePage(),
    );
  }
}
