import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsProvider extends ChangeNotifier {
  late Box _settingsBox;

  SettingsProvider() {
    _settingsBox = Hive.box('settings');
  }

  bool get isDarkMode => _settingsBox.get('isDarkMode', defaultValue: false);
  set isDarkMode(bool value) {
    _settingsBox.put('isDarkMode', value);
    notifyListeners();
  }

  bool get autoPrintReceipt => _settingsBox.get('autoPrintReceipt', defaultValue: true);
  set autoPrintReceipt(bool value) {
    _settingsBox.put('autoPrintReceipt', value);
    notifyListeners();
  }

  double get defaultTaxRate => _settingsBox.get('defaultTaxRate', defaultValue: 2.0);
  set defaultTaxRate(double value) {
    _settingsBox.put('defaultTaxRate', value);
    notifyListeners();
  }

  String get storeName => _settingsBox.get('storeName', defaultValue: 'Super Store');
  set storeName(String value) {
    _settingsBox.put('storeName', value);
    notifyListeners();
  }

  String get storeAddress => _settingsBox.get('storeAddress', defaultValue: '123 Main Street, City');
  set storeAddress(String value) {
    _settingsBox.put('storeAddress', value);
    notifyListeners();
  }

  String get storePhone => _settingsBox.get('storePhone', defaultValue: '+92 300 1234567');
  set storePhone(String value) {
    _settingsBox.put('storePhone', value);
    notifyListeners();
  }
}
