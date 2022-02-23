import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../Model/currentuser_model.dart';
import '../Views/emailverification.dart';
import 'loginstatus.dart';

class Authentication {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore db = FirebaseFirestore.instance;
  static CollectionReference users = FirebaseFirestore.instance.collection('Users');

//0) Firebase Get Current User....
  static Future<CurrentUser> getCurrentUser() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    Map<String, dynamic> data = {};
    await users.doc(uid).get().then((value) => data = value.data() as Map<String, dynamic>);
    return CurrentUser.fromMap(data);
  }

//1) Firebase  SignIn Using Email_Password Authentication....

  static Future signInWithEmail(context, String email, password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user!.emailVerified) {
        final users = FirebaseFirestore.instance.collection('Users');
        users.doc().update({
          "uid": userCredential.user!.uid,
          "name": userCredential.user!.displayName,
          "email": userCredential.user!.email,
          "lastSignInTime": userCredential.user!.metadata.lastSignInTime,
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
                  "Welcome ${userCredential.user!.email}",
                  style: const TextStyle(color: Colors.white),
                )
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            margin: const EdgeInsets.all(10),
            shape: const StadiumBorder(),
            behavior: SnackBarBehavior.floating,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Unverified Email $email"),
                const Icon(
                  Icons.email,
                  color: Colors.white,
                ),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pushReplacementNamed(context, "/login");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            margin: const EdgeInsets.all(10),
            shape: const StadiumBorder(),
            behavior: SnackBarBehavior.floating,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("No user found with email...\n$email"),
                const Icon(
                  Icons.email,
                  color: Colors.white,
                ),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pushReplacementNamed(context, "/login");
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            margin: const EdgeInsets.all(10),
            shape: const StadiumBorder(),
            duration: const Duration(milliseconds: 1500),
            behavior: SnackBarBehavior.floating,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text("Wrong Password"),
                Icon(
                  Icons.lock,
                  color: Colors.white,
                ),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pushReplacementNamed(context, "/login");
      }
    }
  }

//2) Firebase  SignUp Using Email_Password Signup ....

  static Future signUpWithEmail(context, String name, email, password) async {
    List usernameList = email.split("@").toList();
    String userName = "${usernameList[0]}";
    try {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("transfer");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EmailVerification(
            name: name,
            email: '$email',
            password: '$password',
            userCredential: userCredential,
            userName: userName.toLowerCase(),
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            margin: const EdgeInsets.all(10),
            shape: const StadiumBorder(),
            duration: const Duration(milliseconds: 1500),
            behavior: SnackBarBehavior.floating,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Text("The password provided is too weak."),
                Icon(
                  Icons.email,
                  color: Colors.white,
                ),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pushReplacementNamed(context, "/signup");
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            margin: const EdgeInsets.all(10),
            shape: const StadiumBorder(),
            duration: const Duration(milliseconds: 1500),
            behavior: SnackBarBehavior.floating,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Text("Email already exists "),
                Icon(
                  Icons.email,
                  color: Colors.white,
                ),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pushReplacementNamed(context, "/signup");
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  //3.) Firebase SignIn With Google Authentication...

  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    User? user;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      try {
        final userCredential = await auth.signInWithCredential(credential);
        user = userCredential.user;
        final uid = userCredential.user!.uid;
        final userEmail = userCredential.user!.email;
        List usernameList = userEmail!.split("@").toList();
        String userName = "${(usernameList[0])}";
        //Firebase Firestore Collection...
        final users = FirebaseFirestore.instance.collection('Users');

        users.doc(uid).get().then((doc) {
          if (doc.exists) {
            //old user
            doc.reference.update({
              "uid": uid,
              "name": userCredential.user!.displayName,
              "email": userCredential.user!.email,
              "photoUrl": userCredential.user!.photoURL,
              "lastSignInTime": userCredential.user!.metadata.lastSignInTime,
            });
          } else {
            // New User
            users.doc(uid).set({
              "uid": uid,
              "userName": userName.toLowerCase(),
              "name": userCredential.user!.displayName,
              "email": userCredential.user!.email,
              "photoUrl": userCredential.user!.photoURL,
              "lastSignInTime": userCredential.user!.metadata.lastSignInTime,
              "creationTime": userCredential.user!.metadata.creationTime,
            });
          }
        });

        LoginStatus.prefs.setBool("isLoggedIN", true);
        Navigator.pushReplacementNamed(context, "/home");
        print("Successfully SignIn");
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          print("account-exists-with-different-credential");
          // handle the error here
        } else if (e.code == 'invalid-credential') {
          print("invalid-credential");
          // handle the error here
        }
      } catch (e) {
        // handle the error here
      }
    }

    return user;
  }

//4) Firebase SignOut User....

  static Future signOut(context) async {
    LoginStatus.prefs.setBool("isLoggedIN", false);
    try {
      // if (FirebaseAuth.instance.currentUser!.providerData[1].providerId ==
      //     "google.com") {}
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          margin: const EdgeInsets.all(10),
          shape: const StadiumBorder(),
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "Successfully Logout",
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
          backgroundColor: Colors.blue,
        ),
      );
      Navigator.pushReplacementNamed(context, "/login");
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

//5) FireBase Forget Email PassWord
  static late String resetEmail;
  static Future resetPasswordValidation(String email, context) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          margin: const EdgeInsets.all(10),
          shape: const StadiumBorder(),
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Reset Password Email Sent to \n$resetEmail"),
              const Icon(
                CupertinoIcons.lock,
                color: Colors.white,
              ),
            ],
          ),
          backgroundColor: CupertinoColors.activeGreen,
        ),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            margin: const EdgeInsets.all(10),
            shape: const StadiumBorder(),
            duration: const Duration(milliseconds: 1500),
            behavior: SnackBarBehavior.floating,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("No User Found With Email \n$resetEmail"),
                const Icon(
                  Icons.email,
                  color: Colors.white,
                ),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print("error is $e");
    }
  }

//6) Forget Password Button

//Call this Method on Login Screen To Reset Password....

}
