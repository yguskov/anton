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

  List<Map<String, String>> get duty {
    return _jsonToMap(_data['duty']);
  }

  _jsonToMap(listOfJson) {
    try {
      return listOfJson
          .map((jsonMap) =>
              // print('<<<<<${jsonMap.runtimeType}:=$jsonMap==>>>>');
              Map<String, String>.from(jsonMap))
          // .where((name) => name != null)
          .cast<Map<String, String>>()
          .toList();

      // Если вы уверены в типе данных
      // result = (_data['duty'] ?? [] as List<Map<String, String>>);
    } on Error catch (e) {
      print('------------- Ошибка приведения: $e\n===${listOfJson}=====');
      // Альтернативная обработка
    }
    return [];
  }
}
