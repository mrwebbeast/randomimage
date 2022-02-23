import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:randomimage/card_provider.dart';

class CustomCard extends StatefulWidget {
  const CustomCard({Key? key, required this.imgUrl}) : super(key: key);
  final String imgUrl;

  @override
  _CustomCardState createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  late String imgUrl = widget.imgUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      final size = MediaQuery.of(context).size;
      final provider = Provider.of<CardProvider>(context, listen: false);
      provider.setScreenSize(size);
    });
  }

  @override
  Widget build(BuildContext context) {
    return buildFrontCard();
  }

  Widget buildFrontCard() => GestureDetector(
        child: LayoutBuilder(builder: (context, constraints) {
          final provider = Provider.of<CardProvider>(context);
          final position = provider.position;
          final angle = provider.angle * pi / 180;
          final center = constraints.smallest.center(Offset.zero);
          final rotateMatrix = Matrix4.identity()
            ..translate(center.dx, center.dy)
            ..rotateZ(angle)
            ..translate(-center.dx, -center.dy);
          int milliseconds = provider.isDragging ? 0 : 400;
          return AnimatedContainer(
            duration: Duration(milliseconds: milliseconds),
            transform: Matrix4.identity()..translate(position.dx, position.dy),
            child: buildCard(),
          );
        }),
        onPanStart: (details) {
          final provider = Provider.of<CardProvider>(context, listen: false);
          provider.startPosition(details);
        },
        onPanUpdate: (details) {
          final provider = Provider.of<CardProvider>(context, listen: false);
          provider.updatePosition(details);
        },
        onPanEnd: (details) {
          final provider = Provider.of<CardProvider>(context, listen: false);
          provider.endPosition();
          String heart = Provider.of<CardProvider>(context, listen: false).heart;
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              margin: const EdgeInsets.all(10),
              shape: const StadiumBorder(),
              duration: const Duration(milliseconds: 1500),
              behavior: SnackBarBehavior.floating,
              content: heart.toString() == "Blue"
                  ? const Icon(
                      CupertinoIcons.heart_fill,
                      color: Colors.blue,
                    )
                  : heart == "Red"
                      ? const Icon(
                          CupertinoIcons.heart_fill,
                          color: Colors.red,
                        )
                      : heart == "Black"
                          ? const Icon(
                              CupertinoIcons.heart_fill,
                              color: Colors.black,
                            )
                          : const Text("No Heart"),
              backgroundColor: Colors.white,
              elevation: 0,
            ),
          );
        },
      );
  Widget buildCard() => Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.grey,
              image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover),
            ),
          ),
        ),
      );
}
