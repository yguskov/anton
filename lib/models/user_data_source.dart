import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UsersResponse {
  final List<UserGridItem> data;
  final int total; // Общее количество записей (для пагинации)

  UsersResponse({required this.data, required this.total});

  factory UsersResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List? ?? [];
    return UsersResponse(
      data: list.map((i) => UserGridItem.fromJson(i)).toList(),
      total: json['total'] ?? 0,
    );
  }
}

class UserGridItem {
  final int id;
  final String fio;
  final String position;
  final String sector;
  final bool processed;

  UserGridItem(
      {required this.id,
      required this.fio,
      required this.position,
      required this.sector,
      required this.processed});

  factory UserGridItem.fromJson(Map<String, dynamic> json) {
    return UserGridItem(
      id: json['id'],
      fio: json['fio'] ?? '',
      position: json['position'] ?? '',
      sector: json['sector'] ?? '',
      processed: json['processed'],
    );
  }
}

// импорты вашего API сервиса

class ServerUserDataSource extends DataTableSource {
  final ApiService _api;

  List<UserGridItem> _users = [];
  int _totalUsers = 0;
  int _rowsPerPage = 10;

  // Параметры запроса
  int _currentPage = 1;
  String _searchQuery = '';
  int _onlyNew = 0;
  String _sortColumn = 'created_at';
  bool _sortAscending = false;
  String error = '';

  final Set<int> _selectedUserIds = {};

  ServerUserDataSource(this._api);

  num get rowsPerPage => _rowsPerPage;

  // Метод для обновления параметров и перезагрузки
  Future<void> updateParams({
    int? page,
    String? search,
    String? sortColumn,
    bool? sortAscending,
    required int onlyNew,
  }) async {
    if (page != null) _currentPage = page;
    if (search != null) _searchQuery = search;
    _onlyNew = onlyNew;
    if (sortColumn != null) _sortColumn = sortColumn;
    if (sortAscending != null) _sortAscending = sortAscending;

    await _fetchData();
    print('---- after fetch ${error} ------ ');
    notifyListeners(); // Обновляет таблицу
  }

  Future<void> _fetchData() async {
    try {
      final response = await _api.getUsers(
        page: _currentPage,
        limit: _rowsPerPage,
        onlyNew: _onlyNew,
        sortBy: _sortColumn,
        sortOrder: _sortAscending ? 'asc' : 'desc',
        search: _searchQuery,
      );

      // print('---- user responce ------ : ${response}');
      _users = response.data;
      for (var item in _users) {
        if (item.processed) {
          _selectedUserIds.add(item.id);
        }
      }

      _totalUsers = response.total;
      error = '';
    } catch (e) {
      _users = [];
      _totalUsers = 1;
      error = e.toString().substring(10);
      print('Error ${e}');
    }
  }

  @override
  DataRow getRow(int index) {
    final startIndex = (_currentPage - 1) * _rowsPerPage;
    final localIndex = index - startIndex;

    final user = _users[localIndex];
    final isSelected = _selectedUserIds.contains(user.id);

    print(
        '----index=${index}  local=${localIndex} limit = ${_rowsPerPage} current page=${_currentPage}');
    if (localIndex < 0 || localIndex >= _users.length)
      return DataRow(cells: [
        DataCell(Text('')),
        DataCell(Text(localIndex == 0 ? error : '')),
        DataCell(Text('')),
        DataCell(Text('')),
      ]);

    return DataRow(cells: [
      DataCell(Text(user.fio)),
      DataCell(Text(user.position)),
      DataCell(Text(user.sector)),
      DataCell(
        Checkbox(
          value: isSelected,
          onChanged: (bool? value) {
            if (value != null) {
              _onUserSelected(user.id, value);
            }
          },
        ),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _totalUsers;

  @override
  int get selectedRowCount => 0;

  void _onUserSelected(int id, bool value) {
    if (value) {
      _selectedUserIds.add(id);
    } else {
      _selectedUserIds.remove(id);
    }

    _callApiForUser(id, value);

    print("user $id=$value");
  }

  // Метод для вызова API
  Future<void> _callApiForUser(int userId, bool isSelected) async {
    try {
      // Замените на ваш реальный вызов API
      // await _api.markUser(userId, isSelected);
      print('Calling API for user $userId, selected: $isSelected');
      _api.process(userId, isSelected);
      notifyListeners();
      // Если нужно обновить данные после успешного вызова
      // await updateParams(page: _currentPage);
    } catch (e) {
      print('Error calling API: $e');
      notifyListeners();
      // Можно откатить состояние при ошибке
    }
  }
}
