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

  List<Map<String, String>> get duty => _jsonToMap(_data['duty']);
  List<Map<String, String>> get skill => _jsonToMap(_data['skill']);
  List<Map<String, String>> get know => _jsonToMap(_data['know']);

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

/** Example 
 a@a.com
 {
  "aim": "Профессионального роста", 
  "fio": "Августин Михайлович", 
  "why": "Активно развиваюсь и обещаю продолжать расти", 
  "salary": "200000", 
  "sector": "Строительство", 
  "boss_fio": "Алевтина Петровна", 
  "position": "Строитель-монтажник", 
  "want_tip": "1", 
  "want_info": "1", 
  "work_from": "office", 
  "boss_email": "a@p.k", 
  "last_upgrade": "3", 
  "office_country": "Россия", 
  "office_location": "Бедрск"

  "duty": [
    {"name": "Монтаж плит", "type": "base", "period": "раз в неделю", "attitude": "-1"}, 
    {"name": "Размазывание швов", "type": "new", "period": "каждый день", "attitude": "0"}, 
    {"name": "Сварочные работы", "type": "extra", "period": "2 раза в неделю", "attitude": "1"}
  ], 
  "skill": [
    {"name": "Замазка швов", "type": "Не знаю", "level": "3", "power": "Слабым навыком"}, 
    {"name": "Установка плит", "type": "hard", "level": "4", "power": "Сильным навыком"}, 
    {"name": "Сварка", "type": "Не знаю", "level": "0", "power": "Сильным навыком"}, 
    {"name": "Кладка", "type": "софт", "level": "3", "power": "Сильным навыком"}
  ], 
  "know": [
    {"name": "Изучил устройство башенного крана", "when": "6", "skill": "Установка плит", "result": "Поднимаю плиты"}, 
    {"name": "Смотрел  ютуб про сварку", "when": "1", "skill": "Сварка", "result": "Научился варить"}
  ], 
  "achieve": [
    {"name": "Сварил навес", "when": "1", "result": "Теперь есть где курить сотрудникам компании"}, 
    {"name": "Построил дом директору", "when": "12", "result": "Директору есть где жить и с кем"}, 
    {"name": "Бросил курить", "when": "3", "result": "Сэкономил расходы на зарплату"}
  ], 
}
*/