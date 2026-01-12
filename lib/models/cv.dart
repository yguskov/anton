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
/*
{
  "aim": "Продвижения по карьере", 
  "fio": "Вас Васич", 
  "why": "Взял/Готов взять на себя дополнительную ответственность", 
  "duty": [
    {"name": "Разработка приложений", "type": "base", "period": "каждый день", "attitude": "1"}, 
    {"name": "Тестирование", "type": "extra", "period": "раз в неделю", "attitude": "-1"}
  ], 
  "skill": [
    {"name": "Посетил курсы про php", "when": "1", "skill": "Пишу на PHP", "result": "Играю с листа"}, 
    {"name": "Читал книгу для чайников", "when": "12", "skill": "Пишу на Java", "result": "Пишу двумя руками"}
  ], 
  "salary": "20000", 
  "sector": "ИТ", 
  "achieve": [
    {"name": "Написал сайт про погоду", "when": "1", "result": "Все в компании знают погоду на завтра"}, 
    {"name": "Написал заказчику сайт про визитку", "when": "6", "result": "Получили прибыль"}, 
    {"name": "Написал приложения под Андроид", "when": "3", "result": "Добавили его в портфолио"}
  ], 
  "boss_fio": "Огнев Евгений", 
  "position": "Джуниор фронтэнд программист", 
  "want_tip": "1", 
  "want_info": "1", 
  "work_from": "office", 
  "boss_email": "ogo@e.ru", 
  "last_upgrade": "6", 
  "office_country": "Россия", 
  "office_location": "Красноярск"
}
*/