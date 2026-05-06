import 'package:example/providers/auth_provider.dart';
import 'package:example/src/app_bar_with_menu.dart';
import 'package:example/src/constants.dart';
import 'package:example/src/utils.dart';
import 'package:example/src/widgets/bottom_bar.dart';
import 'package:example/src/widgets/text_bar.dart';
import 'package:example/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>(); // for change email
  final _oldPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController();
  final _resumeController = TextEditingController();

  bool get _passwordChangeEnabled =>
      _oldPasswordController.text.isNotEmpty &&
      _oldPasswordController.text.isNotEmpty &&
      _password2Controller.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);

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
    var grayButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.blueGrey,
      foregroundColor: Colors.white,
    );

    const header2Style = TextStyle(
      fontWeight: FontWeight.bold,
    );
    double h20 = 20; // vertical indent

    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: true);

    return AntLayout(
      Scaffold(
        appBar: AntAppBar(
          title: "Профиль пользователя ${authProvider.currentUser?.email}",
        ),
        body: Theme(
          data: Theme.of(context).copyWith(
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0.5,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 19,
                ),
                backgroundColor: secondaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                color: groundColor,
                child: ListView(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            minHeight: constraints.maxHeight - bottomHeight, maxWidth: 820),
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20.0),
                            child: Column(
                              children: [
                                SizedBox(height: 20),
                                Card(
                                  elevation: 0, // убираем тень
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  color: Colors.white,
                                  child: Padding(
                                    padding: EdgeInsets.all(h20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          'Ваш профиль:',
                                          style: header2Style,
                                        ),
                                        SizedBox(height: h20),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                  onPressed: edit,
                                                  child: Text('Редактировать данные')),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: h20),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: view,
                                                child: Text('Предпросмотр'),
                                                style: whiteButtonStyle,
                                              ),
                                            ),
                                            SizedBox(width: h20),
                                            Expanded(
                                              child: ElevatedButton(
                                                  onPressed: copyLink,
                                                  child: Text('Получить ссылку')),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: h20),
                                Text(
                                  'Сообщите нам о результате общения о достижении вашей цели, получилось ли? или добились каких-то альтернатив?',
                                  textAlign: TextAlign.center,
                                  style: header2Style,
                                ),
                                SizedBox(height: h20),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: edit,
                                    child: Text('Сообщить о результате'),
                                  ),
                                ),
                                SizedBox(height: h20),
                                Text(
                                  'Если затея провалится, то мы можем через наших партнеров подобрать вам, как выдающемуся специалисту, новую работу',
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(height: h20),
                                TextBar('Оставьте ссылку на ваше резюме'),
                                SizedBox(height: h20),
                                TextFormField(
                                  controller: _resumeController,
                                  decoration: inputDecorattion('http://'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Укажите ссылку';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: h20),
                                TextBar('Сменить пароль'),
                                SizedBox(height: h20),
                                authProvider.isLoading
                                    ? Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(50),
                                          child: SizedBox(
                                            width: 100,
                                            height: 100,
                                            child: CircularProgressIndicator(
                                              backgroundColor: Colors.white,
                                              strokeWidth: 6,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Form(
                                        key: _formKey,
                                        onChanged: () => setState(() {}),
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              controller: _oldPasswordController,
                                              decoration: inputDecorattion('Старый пароль'),
                                              obscureText: true,
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Укажите пароль';
                                                }
                                                return null;
                                              },
                                            ),
                                            SizedBox(height: 16),
                                            TextFormField(
                                              controller: _passwordController,
                                              decoration: inputDecorattion('Новый пароль'),
                                              obscureText: true,
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Укажите пароль';
                                                }
                                                if (value.length < 3) {
                                                  return 'Пароль не может быть меньше 3 символов';
                                                }
                                                return null;
                                              },
                                            ),
                                            SizedBox(height: 20),
                                            TextFormField(
                                              controller: _password2Controller,
                                              decoration: inputDecorattion('Подтвердите пароль'),
                                              obscureText: true,
                                              validator: (value) {
                                                if (value != _passwordController.text) {
                                                  return 'Пароль не совпадает';
                                                }
                                                return null;
                                              },
                                            ),
                                            if (authProvider.error != null)
                                              Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Text(
                                                  authProvider.error!,
                                                  style: TextStyle(color: Colors.red),
                                                ),
                                              ),
                                            authProvider.isLoading
                                                ? CircularProgressIndicator()
                                                : SizedBox(height: 20),
                                          ],
                                        )),
                                Align(
                                  alignment: Alignment.center,
                                  child: ElevatedButton(
                                    onPressed: changePassword,
                                    style:
                                        _passwordChangeEnabled ? redButtonStyle : grayButtonStyle,
                                    child: Text('Сохранить'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Нижняя панель
                    BottomBar(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void edit() {
    Navigator.pushNamed(context, '/register');
  }

  void view() {
    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser?.guid != null) {
      Navigator.pushNamed(context, '/review/' + authProvider.currentUser!.guid);
    }
  }

  InputDecoration inputDecorattion(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[200],
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[600]!, width: 1.5),
        borderRadius: const BorderRadius.all(
          Radius.circular(4),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[800]!, width: 2.0),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(6),
          bottomRight: Radius.circular(6),
        ),
      ),
      contentPadding: const EdgeInsets.all(16),
    );
  }

  Future<void> changePassword() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_formKey.currentState!.validate()) {
      final success = await authProvider.changePassword(
        _oldPasswordController.text,
        _passwordController.text,
      );

      if (success) {
        setState(() {
          _oldPasswordController.text = '';
          _passwordController.text = '';
          _password2Controller.text = '';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('\nПароль изменен!\n',
                textAlign:
                    TextAlign.center), /* backgroundColor: Theme.of(context).colorScheme.primary */
          ),
        );

        // Navigator.pushNamed(context, '/profile');
      } else {
        print('Ошибка смены пароля');
      }
    }
  }

  // Copy link for manager
  void copyLink() {
    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser?.guid != null) {
      String path = Uri.base.toString();
      // Копируем текст в буфер
      Clipboard.setData(ClipboardData(
          text: path.substring(0, path.lastIndexOf('#') + 1) +
              '/review/' +
              authProvider.currentUser!.guid));

      // показать уведомление
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Ссылка скопирована в буфер!'),
          backgroundColor: Theme.of(context).colorScheme.primary));
    }
  }
}
