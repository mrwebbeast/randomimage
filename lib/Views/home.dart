import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:randomimage/Services/authentication.dart';
import 'package:randomimage/Views/customecard.dart';
import 'package:randomimage/dogs_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

final currentUser = FirebaseAuth.instance.currentUser;

class _HomeState extends State<Home> {
  String api = "https://dog.ceo/api/breeds/image/random";

  late Future<DogsModel> fetchedDogs;

  Future<DogsModel> fetchImage() async {
    final response = await http.get(Uri.parse(api));

    if (response.statusCode == 200) {
      return DogsModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to ,load image");
    }
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<int> _counter;
  Future<void> counterIncrement() async {
    final prefs = await _prefs;
    int counter = (prefs.getInt("Counter") ?? 0) + 1;
    setState(() {
      _counter = prefs.setInt("Counter", counter).then((value) => counter);
    });
  }

  @override
  void initState() {
    super.initState();
    _counter = _prefs.then((prefs) {
      return (prefs.getInt("Counter") ?? 0);
    });
    fetchedDogs = fetchImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text("${currentUser!.displayName}"),
        actions: [
          FutureBuilder<int>(
            future: _counter,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Center(
                  child: Text("${(snapshot.data)}"),
                );
              } else if (snapshot.hasError) {
                return const Center(child: Text("0"));
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
          IconButton(
              onPressed: () {
                Authentication.signOut(context);
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: FutureBuilder<DogsModel>(
        future: fetchedDogs,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            String imgUrl = snapshot.data!.imgUrl;
            return GestureDetector(
              onPanCancel: () {
                counterIncrement();
              },
              child: Center(
                child: CustomCard(imgUrl: imgUrl),
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text("Oops Something Went Wrong"));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
