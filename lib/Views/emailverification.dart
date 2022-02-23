import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Services/loginstatus.dart';

class EmailVerification extends StatefulWidget {
  const EmailVerification({
    Key? key,
    required this.name,
    required this.email,
    required this.password,
    required this.userCredential,
    required this.userName,
  }) : super(key: key);

  final String name;
  final String email;
  final String password;
  final String userName;
  final UserCredential userCredential;

  @override
  _EmailVerificationState createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  static final auth = FirebaseAuth.instance;
  static final db = FirebaseFirestore.instance;
  late String userName = "";

  late User user;
  late Timer timer;
  bool isChecking = false;

  @override
  void initState() {
    super.initState();
    user = auth.currentUser!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Card(
                  elevation: 5,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.90,
                    height: MediaQuery.of(context).size.height * 0.45,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Center(
                                child: Text(
                                  isChecking ? "Check Your Email to Verify" : "Verify Your Email Address",
                                  style: const TextStyle(
                                      color: Colors.blue, fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                "Hlo ${(widget.name).toUpperCase()}",
                                style: TextStyle(
                                    color: Colors.grey.shade700, fontSize: 18, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                isChecking ? "We Have Sent You Verification Email" : " You Have Entered ",
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              isChecking
                                  ? const CircularProgressIndicator()
                                  : Text(
                                      "${widget.email} Please Verify this Email Address ",
                                      style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                            ],
                          ),
                        ),
                        isChecking
                            ? CupertinoButton(
                                child: const Text(("Waiting for Verification")),
                                onPressed: () {},
                              )
                            : CupertinoButton(
                                color: Colors.green,
                                child: const Text(("Verify Email")),
                                onPressed: () {
                                  setState(() {
                                    isChecking = true;
                                  });
                                  user.sendEmailVerification();
                                  timer = Timer.periodic(const Duration(seconds: 3), (timer) {
                                    checkEmailVerified();
                                    print("Checking...");
                                  });
                                },
                              ),
                      ],
                    ),
                  ),
                ),
                const Positioned(
                  top: -20,
                  child: SizedBox(
                    height: 60,
                    width: 60,
                    child: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(
                        CupertinoIcons.mail_solid,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> checkEmailVerified() async {
    user = auth.currentUser!;
    await user.reload();
    if (user.emailVerified) {
      timer.cancel();
      String? uid = user.uid;

      db.collection("Users").doc(uid).set({
        "uid": uid,
        "coins": 0,
        "userName": widget.userName,
        "role": "reader",
        "name": widget.name,
        "email": widget.email,
        "photoUrl": "",
        "creationTime": widget.userCredential.user!.metadata.creationTime,
        "lastSignInTime": widget.userCredential.user!.metadata.lastSignInTime,
      });
      LoginStatus.prefs.setBool("isLoggedIN", true);
      Navigator.pushReplacementNamed(context, "/home");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          margin: const EdgeInsets.all(10),
          shape: const StadiumBorder(),
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome ${user.email}",
                style: const TextStyle(color: Colors.white),
              )
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
