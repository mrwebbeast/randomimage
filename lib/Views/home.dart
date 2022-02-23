import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:randomimage/Services/authentication.dart';
import 'package:randomimage/Services/counter_prefs.dart';
import 'package:randomimage/Views/customecard.dart';
import 'package:randomimage/dogs_model.dart';

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

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 10; i++) {
      fetchedDogs = fetchImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<Counter>(context).loadHearts();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text("${currentUser!.displayName}"),
        actions: [
          IconButton(
              onPressed: () {
                Authentication.signOut(context);
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FutureBuilder<DogsModel>(
            future: fetchedDogs,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                String imgUrl = snapshot.data!.imgUrl;
                return Center(
                  child: CustomCard(imgUrl: imgUrl),
                );
              } else if (snapshot.hasError) {
                return const Center(child: Text("Oops Something Went Wrong"));
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.heart_fill,
                    color: Colors.red,
                    size: 48,
                  ),
                  Text(
                    "${Provider.of<Counter>(context).redHearts}",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  )
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.heart_fill,
                    color: Colors.black,
                    size: 48,
                  ),
                  Text(
                    "${Provider.of<Counter>(context).blackHearts}",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  )
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.heart_fill,
                    color: Colors.blue,
                    size: 48,
                  ),
                  Text(
                    "${Provider.of<Counter>(context).blueHearts}",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
