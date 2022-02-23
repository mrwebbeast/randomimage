import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:randomimage/Services/counter_prefs.dart';
import 'package:randomimage/Services/loginstatus.dart';
import 'package:randomimage/Views/home.dart';
import 'package:randomimage/Views/login.dart';
import 'package:randomimage/Views/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'card_provider.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (BuildContext context) => CardProvider()),
        ChangeNotifierProvider(create: (BuildContext context) => Counter())
      ],
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
          "/signup": (context) => const SignUp(),
        },
      ),
    );
  }
}
