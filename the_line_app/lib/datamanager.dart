import 'package:shared_preferences/shared_preferences.dart';

abstract class IDataManager {
  void saveStrings(String name, List<String> object);

  Future<List<String>> loadString(String name);
}

class SharedPrefDataManager extends IDataManager {
  SharedPreferences _prefs;
  Future<bool> init() async {
    _prefs = await SharedPreferences.getInstance();

    return _prefs != null;
  }

  @override
  void saveStrings(String name, List<String> object) async {
    if (_prefs == null) {
      if (!await init()) return;
    }

    if (!await _prefs.setStringList(name, object))
      throw Exception(
        'An error occurred while saving the settings in Shared Prefereces!!',
      );
  }

  @override
  Future<List<String>> loadString(String name) async {
    if (_prefs == null) {
      if (!await init()) return null;
    }

    if (!_prefs.containsKey(name)) {
      return null;
    }

    return _prefs.getStringList(name);
  }
}
