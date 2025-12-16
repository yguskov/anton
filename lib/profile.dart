import 'package:example/providers/auth_provider.dart';
import 'package:example/src/app_bar_with_menu.dart';
import 'package:example/src/widgets/text_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    final AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      authProvider.fetchCurrentUser();
    }
    // final sccess = await authProvider.register();
    //       dynamic response = await _apiService.login(request);
    // _currentUser = response.User;
    // _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    var redButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Color(0xFFF76D12),
      // foregroundColor: Colors.white,
    );
    double h20 = 20; // vertical indent

    final AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: true);

    return Scaffold(
      appBar: AntAppBar(
        title: "Профиль пользователя ${authProvider.currentUser?.email}",
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              // backgroundColor: Colors.green,
              // foregroundColor: Colors.white,
            ),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 640),
                      child: Container(
                        // color: Colors.grey[300],
                        child: authProvider.isLoading
                            ? CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 20.0),
                                child: ListView(
                                  children: [
                                    SizedBox(height: 20),
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: edit,
                                        child: Text('Редактировать данные'),
                                      ),
                                    ),
                                    SizedBox(height: h20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                            onPressed: edit,
                                            child: Text('Предпросмотр')),
                                        SizedBox(width: h20),
                                        ElevatedButton(
                                            onPressed: edit,
                                            child: Text('Получить ссылку'),
                                            style: redButtonStyle),
                                      ],
                                    ),
                                    SizedBox(height: h20),
                                    Text(
                                      'Если затея провалится, то мы можем через наших партнеров подобрать вам, как выдающемуся специалисту, новую работу',
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: h20),
                                    TextBar('Оставьте ссылку на ваше резюме'),
                                    SizedBox(height: h20),
                                    Text(
                                      'Создан: ${authProvider.currentUser?.createdAt}',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                ),

                // Нижняя панель
                Container(
                    height: 90,
                    color: Colors.white,
                    child: Center(
                        child: ElevatedButton(
                            onPressed: () {}, child: Text('Сохранить ')))),
              ],
            );
          },
        ),
      ),
    );
  }

  void edit() {
    Navigator.pushNamed(context, '/');
  }
}
