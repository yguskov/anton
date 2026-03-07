import 'package:example/models/user_data_source.dart';
import 'package:example/services/api_service.dart';
import 'package:example/src/widgets/toggle_button.dart';
import 'package:flutter/material.dart';

class UserGridWidget extends StatefulWidget {
  @override
  _UserGridWidgetState createState() => _UserGridWidgetState();
}

class _UserGridWidgetState extends State<UserGridWidget> {
  late ServerUserDataSource _dataSource;
  final _searchController = TextEditingController();

  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  int onlyNew = 0;

  final _api = ApiService();

  @override
  void initState() {
    super.initState();
    _dataSource = ServerUserDataSource(_api);
    _loadData();
  }

  Future<void> _loadData({int? page}) async {
    await _dataSource.updateParams(
      page: page ?? 1,
      search: _searchController.text,
      onlyNew: onlyNew,
      sortColumn: _getSortColumnByIndex(_sortColumnIndex),
      sortAscending: _sortAscending,
    );
    setState(() {});
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomToggleButton(
                textOn: 'Только обработанные',
                textOff: 'Убрать обработанные',
                iconOn: Icons.check_circle,
                iconOff: Icons.cancel,
                colorOn: Colors.blueGrey,
                // colorOff: Theme.of(context).colorScheme.primary,
                // colorOff: Colors.grey[300],
                textColorOn: Colors.white,
                // textColorOff: Colors.black54,
                height: 36,
                onToggle: (value) {
                  onlyNew = value ? 1 : 0;
                  _loadData(page: 1);
                },
              ),
              const SizedBox(width: 17),
              Expanded(
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
            ],
          ),
        ),
        Expanded(
          child: _dataSource.error != ''
              ? Center(child: Text(_dataSource.error))
              : PaginatedDataTable(
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
                        _sortColumnIndex = columnIndex;
                        _sortAscending = ascending;

                        _loadData(page: 1); // При сортировке сбрасываем на 1 стр.
                      },
                    ),
                    DataColumn(
                      label: Text('Должность'),
                      onSort: (columnIndex, ascending) {
                        _sortColumnIndex = columnIndex;
                        _sortAscending = ascending;

                        _loadData(page: 1);
                      },
                    ),
                    DataColumn(
                      label: Text('Индустрия'),
                      onSort: (columnIndex, ascending) {
                        _sortColumnIndex = columnIndex;
                        _sortAscending = ascending;

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
