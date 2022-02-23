import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:randomimage/Services/counter_prefs.dart';

enum CardStatus { up, left, right }

class CardProvider with ChangeNotifier {
  late String _heart;
  String get heart => _heart;

  double _angle = 0;
  double get angle => _angle;
  bool _isDragging = false;
  bool get isDragging => _isDragging;

  Size _setScreenSize = Size.zero;

  Offset _position = Offset.zero;
  Offset get position => _position;

  CardStatus? getStatus() {
    final x = _position.dx;
    final y = _position.dy;
    const delta = 100;
    if (x >= delta) {
      return CardStatus.up;
    } else if (x <= -delta / 2) {
      return CardStatus.left;
    } else if (y <= -delta / 2) {
      return CardStatus.up;
    }
  }

  String setHeart() {
    final x = _position.dx;
    final y = _position.dy;
    const delta = 100;
    if (x >= delta) {
      print("right");
      _heart = "Blue";
      Counter().incrementBlueHearts();
      notifyListeners();
      print(_heart);
      return _heart;
    } else if (x <= -delta / 2) {
      print("left");
      _heart = "Red";
      Counter().incrementRedHearts();
      notifyListeners();
      print(_heart);
      return _heart;
    } else if (y <= -delta / 2) {
      print("top");
      _heart = "Black";
      notifyListeners();
      print(_heart);
      return _heart;
    } else {
      print("bottom");
      _heart = "Black";
      Counter().incrementBlackHearts();
      notifyListeners();
      print(_heart);
      return _heart;
    }
  }

  void setScreenSize(Size size) {
    _setScreenSize = size;
    notifyListeners();
  }

  void startPosition(DragStartDetails details) {
    _isDragging = true;
    notifyListeners();
  }

  void updatePosition(DragUpdateDetails details) {
    _position += details.delta;
    final x = _position.dx;
    _angle = 45 * x / _setScreenSize.width;
    notifyListeners();
  }

  void endPosition() {
    _isDragging = false;

    final status = getStatus();
    setHeart();
    switch (status) {
      case CardStatus.right:
        like();
        print("right");
        break;
      default:
        resetPosition();
    }
  }

  void like() {
    _angle = 20;
    _position += Offset(_setScreenSize.width / 2, 0);
    notifyListeners();
  }

  void resetPosition() {
    _angle = 0;
    _position = Offset.zero;
    notifyListeners();
  }
}
