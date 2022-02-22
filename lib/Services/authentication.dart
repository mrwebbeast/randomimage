import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:randomimage/Services/loginstatus.dart';

class Authentication {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore db = FirebaseFirestore.instance;

  //1.) Firebase SignIn With Google Authentication...

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
        final users = FirebaseFirestore.instance.collection('users');

        users.doc(uid).get().then((doc) {
          if (doc.exists) {
            //old user
            doc.reference.update({
              "UID": uid,
              "Name": userCredential.user!.displayName,
              "Email": userCredential.user!.email,
              "PhotoUrl": userCredential.user!.photoURL,
              "LastSignInTime": userCredential.user!.metadata.lastSignInTime,
            });
          } else {
            // New User
            users.doc(uid).set({
              "UID": uid,
              "UserName": userName.toLowerCase(),
              "Name": userCredential.user!.displayName,
              "Email": userCredential.user!.email,
              "PhotoUrl": userCredential.user!.photoURL,
              "LastSignInTime": userCredential.user!.metadata.lastSignInTime,
              "CreationTime": userCredential.user!.metadata.creationTime,
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

//Call this Method on Login Screen To Reset Password....

}
