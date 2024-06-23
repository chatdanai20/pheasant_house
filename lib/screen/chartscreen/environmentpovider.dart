import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EnvironmentDataProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _environmentData = [];

  List<Map<String, dynamic>> get environmentData => _environmentData;

  void updateEnvironmentData(List<Map<String, dynamic>> newData) {
    _environmentData = newData;
    notifyListeners();
  }
}