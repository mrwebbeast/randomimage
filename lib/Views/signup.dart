import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Services/authentication.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool isLoading = false;

  final loginFormKey = GlobalKey<FormState>();

  late String name, email, password;

  FirebaseAuth auth = FirebaseAuth.instance;

  FirebaseFirestore db = FirebaseFirestore.instance;

  signUpWithEmail() async {
    if (loginFormKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      await Authentication.signUpWithEmail(
        context,
        name,
        email,
        password,
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Sign Up"),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: Form(
                  key: loginFormKey,
                  child: Card(
                    elevation: 5,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Sign Up",
                              style: TextStyle(color: Colors.blue, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.person),
                                labelText: "Name",
                                hintText: "Name",
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.blueAccent),
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return "Enter Name";
                                }
                              },
                              onChanged: (value) {
                                name = value;
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.email),
                                labelText: "Email",
                                hintText: "Email",
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.blueAccent),
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return "Enter Email Id";
                                } else if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(val)) {
                                  return "Please Enter valid Email !";
                                }
                              },
                              onChanged: (value) {
                                email = value;
                              },
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              obscureText: true,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock),
                                labelText: "Password",
                                hintText: "Password",
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.blueAccent),
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return "Enter Password";
                                } else if (val.length < 6) {
                                  return "Weak Password! must be of 6 words";
                                }
                              },
                              onChanged: (value) {
                                password = value;
                              },
                            ),
                            const SizedBox(height: 10),
                            CupertinoButton(
                              color: Colors.blue,
                              child: const Text("Sign Up"),
                              onPressed: () {
                                signUpWithEmail();
                              },
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Already have an Account? ",
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pushReplacementNamed(context, "/login");
                                  },
                                  child: const Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
