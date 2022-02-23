import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Counter with ChangeNotifier {
  late int _redHearts = 0;
  int get redHearts => _redHearts;

  late int _blueHearts = 0;
  int get blueHearts => _blueHearts;

  late int _blackHearts = 0;
  int get blackHearts => _blackHearts;

  void loadHearts() async {
    final prefs = await SharedPreferences.getInstance();
    _redHearts = (prefs.getInt('RedHearts') ?? 0);
    _blueHearts = (prefs.getInt('BlueHearts') ?? 0);
    _blackHearts = (prefs.getInt('BlackHearts') ?? 0);
    notifyListeners();
  }

  Future<void> incrementRedHearts() async {
    final prefs = await SharedPreferences.getInstance();
    _redHearts = (prefs.getInt('RedHearts') ?? 0) + 1;
    prefs.setInt("RedHearts", _redHearts).then((value) => _redHearts);
    notifyListeners();
  }

  Future<void> incrementBlueHearts() async {
    final prefs = await SharedPreferences.getInstance();
    _blueHearts = (prefs.getInt('BlueHearts') ?? 0) + 1;
    prefs.setInt("BlueHearts", _blueHearts).then((value) => _blueHearts);
    notifyListeners();
  }

  Future<void> incrementBlackHearts() async {
    final prefs = await SharedPreferences.getInstance();
    _blackHearts = (prefs.getInt('BlackHearts') ?? 0) + 1;
    prefs.setInt("BlackHearts", _blackHearts).then((value) => _blackHearts);
    notifyListeners();
  }
}
