import 'package:example/models/user_data_source.dart';
import 'package:example/services/api_service.dart';
import 'package:flutter/material.dart';

class UserGridWidget extends StatefulWidget {
  @override
  _UserGridWidgetState createState() => _UserGridWidgetState();
}

class _UserGridWidgetState extends State<UserGridWidget> {
  late ServerUserDataSource _dataSource;
  final _searchController = TextEditingController();

  // 1. Состояние сортировки хранится в виджете
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  final _api = ApiService();

  @override
  void initState() {
    super.initState();
    _dataSource = ServerUserDataSource(_api);
    _loadData();
  }

  // 2. Метод загрузки с текущими параметрами
  Future<void> _loadData({int? page}) async {
    await _dataSource.updateParams(
      page: page ?? 1,
      search: _searchController.text,
      sortColumn: _getSortColumnByIndex(_sortColumnIndex),
      sortAscending: _sortAscending,
    );
  }

  String _getSortColumnByIndex(int index) {
    switch (index) {
      case 0:
        return 'fio_virtual';
      case 1:
        return 'position_virtual';
      case 2:
        return 'sector_virtual';
      default:
        return 'created_at';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Поиск
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Поиск',
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: () => _loadData(page: 1), // Сброс на 1 страницу
              ),
            ),
            onSubmitted: (_) => _loadData(page: 1),
          ),
        ),
        Expanded(
          child: PaginatedDataTable(
            // header: Text('Сотрудники'),
            source: _dataSource,
            rowsPerPage: 10,
            dataRowMinHeight: 30,
            dataRowMaxHeight: 33,

            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,

            onPageChanged: (int firstRowIndex) {
              final page = (firstRowIndex ~/ _dataSource.rowsPerPage) + 1;
              _loadData(page: page);
            },

            columns: [
              DataColumn(
                label: Text('ФИО'),
                // 4. Логика сортировки в каждой колонке
                onSort: (columnIndex, ascending) {
                  setState(() {
                    _sortColumnIndex = columnIndex;
                    _sortAscending = ascending;
                  });
                  _loadData(page: 1); // При сортировке сбрасываем на 1 стр.
                },
              ),
              DataColumn(
                label: Text('Должность'),
                onSort: (columnIndex, ascending) {
                  setState(() {
                    _sortColumnIndex = columnIndex;
                    _sortAscending = ascending;
                  });
                  _loadData(page: 1);
                },
              ),
              DataColumn(
                label: Text('Индустрия'),
                onSort: (columnIndex, ascending) {
                  setState(() {
                    _sortColumnIndex = columnIndex;
                    _sortAscending = ascending;
                  });
                  _loadData(page: 1);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
