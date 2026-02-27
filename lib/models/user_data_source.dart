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

  UserGridItem({required this.id, required this.fio, required this.position, required this.sector});

  factory UserGridItem.fromJson(Map<String, dynamic> json) {
    return UserGridItem(
      id: json['id'],
      fio: json['fio'] ?? '',
      position: json['position'] ?? '',
      sector: json['sector'] ?? '',
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
  String _sortColumn = 'created_at';
  bool _sortAscending = false;

  ServerUserDataSource(this._api);

  num get rowsPerPage => _rowsPerPage;

  // Метод для обновления параметров и перезагрузки
  Future<void> updateParams({
    int? page,
    String? search,
    String? sortColumn,
    bool? sortAscending,
  }) async {
    if (page != null) _currentPage = page;
    if (search != null) _searchQuery = search;
    if (sortColumn != null) _sortColumn = sortColumn;
    if (sortAscending != null) _sortAscending = sortAscending;

    await _fetchData();
    print('---- after fetch page=${_currentPage} ------ ');
    notifyListeners(); // Обновляет таблицу
  }

  Future<void> _fetchData() async {
    try {
      final response = await _api.getUsers(
        page: _currentPage,
        limit: _rowsPerPage,
        sortBy: _sortColumn,
        sortOrder: _sortAscending ? 'asc' : 'desc',
        search: _searchQuery,
      );

      // print('---- user responce ------ : ${response}');
      _users = response.data;
      _totalUsers = response.total;
    } catch (e) {
      _users = [];
      _totalUsers = 0;
      print('Error ${e}');
    }
  }

  @override
  DataRow getRow(int index) {
    final startIndex = (_currentPage - 1) * _rowsPerPage;
    final localIndex = index - startIndex;
    print(
        '----index=${index}  local=${localIndex} limit = ${_rowsPerPage} current page=${_currentPage}');
    if (localIndex < 0 || localIndex >= _users.length)
      return DataRow(cells: [
        DataCell(Text('')),
        DataCell(Text('')),
        DataCell(Text('')),
      ]);

    final user = _users[localIndex];
    return DataRow(cells: [
      DataCell(Text(user.fio)),
      DataCell(Text(user.position)),
      DataCell(Text(user.sector)),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _totalUsers;

  @override
  int get selectedRowCount => 0;
}
