import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Services/authentication.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({Key? key}) : super(key: key);

  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  bool isLoading = false;
  static final resetEmailController = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Forget Password",
          style: TextStyle(
            color: Colors.blue,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 5,
                  child: Form(
                    key: resetEmailController,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Center(
                              child: Text(
                            "FORGET PASSWORD",
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          )),
                          Column(
                            children: [
                              const Text(
                                "Enter the Email Associated with your Account ",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "We will Email you a Link to Reset \nYour Password",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextFormField(
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return "Enter Email id";
                                } else if (!RegExp(
                                        "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                    .hasMatch(val)) {
                                  return "Please Enter valid Email";
                                }
                              },
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.email),
                                hintText: "Email",
                                labelText: "Enter your Email",
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.blueAccent),
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              onChanged: (value) {
                                Authentication.resetEmail = value;
                              },
                            ),
                          ),
                          CupertinoButton(
                            color: Colors.blue,
                            child: const Text("Next"),
                            onPressed: () async {
                              if (resetEmailController.currentState!
                                  .validate()) {
                                print(Authentication.resetEmail);
                                setState(() {
                                  isLoading = true;
                                });
                                await Authentication.resetPasswordValidation(
                                    Authentication.resetEmail, context);
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
