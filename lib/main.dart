import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:randomimage/Services/loginstatus.dart';
import 'package:randomimage/Views/home.dart';
import 'package:randomimage/Views/login.dart';
import 'package:randomimage/card_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  LoginStatus.prefs = await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => CardProvider(),
      child: MaterialApp(
        title: 'Random Image',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LoginStatus.prefs.getBool("isLoggedIN") == true ? const Home() : const Login(),
        routes: {
          "/home": (context) => const Home(),
          "/login": (context) => const Login(),
        },
      ),
    );
  }
}
