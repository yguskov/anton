import 'dart:convert';

class CV {
  static CV? _instance;

  CV._() : _data = {};

  Map<String, dynamic> _data = {};

  static fromJson(String json) {
    _instance ??= CV._();
    _instance?._data = jsonDecode(json);
    return _instance;
  }

  static CV get instance {
    return _instance ??= CV._();
  }

  void setValue(String key, value) {
    _data[key] = value;
  }

  dynamic getValue(String key) {
    return _data[key];
  }

  String toJson() {
    print(' ----------------- ${jsonEncode(_data)}');
    return jsonEncode(_data);
  }

  get data => _data;
}
