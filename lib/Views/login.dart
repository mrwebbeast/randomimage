import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Services/authentication.dart';
import 'forgetpassword.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  static bool isLoading = false;
  late String email, password;
  final loginFormKey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;

  signInWithGoogle() async {
    setState(() {
      isLoading = true;
    });
    await Authentication.signInWithGoogle(context: context);
    setState(() {
      isLoading = false;
    });
  }

  signInWithEmail() async {
    if (loginFormKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      await Authentication.signInWithEmail(context, email, password);
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
        title: const Text("Sign In"),
        elevation: 0,
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 20,
                  ),
                  Text("Processing...")
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: loginFormKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "SIGN In",
                        style: TextStyle(color: Colors.blue, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 30,
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
                            return "Enter Email id";
                          } else if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(val)) {
                            return "Please Enter valid Email";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          email = value;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock),
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
                            return "invalid Password !";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          password = value;
                        },
                      ),
//Forget Password  Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CupertinoButton(
                            child: const Text("Forget Password"),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ForgetPassword(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
//Email Login Button
                      CupertinoButton(
                        color: Colors.blue,
                        child: const Text("Sign In"),
                        onPressed: () {
                          signInWithEmail();
                        },
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "OR",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
//Google Login Button
                      InkWell(
                        onTap: () {
                          signInWithGoogle();
                        },
                        child: Image.asset(
                          "assets/images/btn_google_signin.png",
                          height: 45,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "don't have an Account? ",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, "/signup");
                            },
                            child: const Text(
                              "Sign up",
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
    );
  }
}
