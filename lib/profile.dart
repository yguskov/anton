import 'package:example/providers/auth_provider.dart';
import 'package:example/src/app_bar_with_menu.dart';
import 'package:example/src/constants.dart';
import 'package:example/src/utils.dart';
import 'package:example/src/widgets/bottom_bar.dart';
import 'package:example/src/widgets/steps_progress_indicator.dart';
import 'package:example/src/widgets/text_bar.dart';
import 'package:example/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markup_text/markup_text.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final double h20 = 20; // vertical indent
  final _formKey = GlobalKey<FormState>(); // for change email
  final _oldPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController();
  final _resumeController = TextEditingController();
  final TextEditingController _resultDescController = TextEditingController();

  bool get _passwordChangeEnabled =>
      _oldPasswordController.text.isNotEmpty &&
      _oldPasswordController.text.isNotEmpty &&
      _password2Controller.text.isNotEmpty;

  get commonTextStyle => TextStyle(fontSize: 20);

  @override
  void initState() {
    super.initState();
    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      authProvider.fetchCurrentUser();
    }
    authProvider.loadUserCV(authProvider.currentUser!.guid);
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

    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: true);
    if (authProvider.isAuth) {
      _resumeController.text = authProvider.currentUser!.userData['resume'] ?? '';
      _resultDescController.text = authProvider.currentUser!.userData['result_description'] ?? '';
    }

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
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
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
                            minHeight: constraints.maxHeight - bottomHeight,
                            maxWidth: baseScreenWidth),
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20.0),
                            child: Column(
                              children: [
                                SizedBox(height: 20),
                                Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(11),
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
                                              flex: 6,
                                              child: Center(
                                                child: StepsProgressIndicator(
                                                  count: stepMenuIconFiles.length,
                                                  index: stepMenuIconFiles.length - 1,
                                                  size: 33,
                                                  padding: 4,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: h20),
                                            Expanded(
                                              flex: 6,
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
                                if (authProvider.userCV != null &&
                                    authProvider.userCV!.getValue('assign') != null &&
                                    authProvider.userCV!.getValue('assign') != 0)
                                  Card(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(11),
                                      side: BorderSide(
                                        color: authProvider.userCV!.getValue('assign') == 1
                                            ? cardColorLike
                                            : cardColorDislike,
                                        width: 1,
                                      ),
                                    ),
                                    color: Colors.white,
                                    child: Padding(
                                      padding: EdgeInsets.all(h20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          authProvider.userCV!.getValue('assign') == 1
                                              ? MarkupText(
                                                  '(b)Результат:(/b) (c #47b33d)Положительный(/c)',
                                                  style: commonTextStyle)
                                              : MarkupText(
                                                  '(b)Результат:(/b) (c #cd3735)Отрицательный(/c)',
                                                  style: commonTextStyle),
                                          SizedBox(height: h20),
                                          MarkupText('${authProvider.userCV!.getValue('comment')}',
                                              style: commonTextStyle),
                                        ],
                                      ),
                                    ),
                                  ),
                                SizedBox(height: h20),
                                Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(11),
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
                                          'Сообщите нам о результате общения о достижении вашей цели, получилось ли? Добились каких-то альтернатив?',
                                          textAlign: TextAlign.center,
                                          style: header2Style,
                                        ),
                                        SizedBox(height: h20),
                                        ElevatedButton(
                                            onPressed: () => _openResultDialog(context),
                                            child: Text('Сообщить о результате'),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: cardAddButtonBackColor)),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: h20),
                                Text(
                                  'Если затея провалилась, то мы можем через наших партнеров подобрать вам, как выдающемуся специалисту, новую работу',
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(height: h20),
                                Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(11),
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
                                        TextBar('Оставьте ссылку на ваше резюме'),
                                        TextFormField(
                                          controller: _resumeController,
                                          decoration: inputDecoration('http://'),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Укажите ссылку';
                                            }
                                            return null;
                                          },
                                        ),
                                        SizedBox(height: h20 / 2),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: saveJob,
                                                child: Text((authProvider
                                                            .currentUser?.userData['need_job'] ??
                                                        false)
                                                    ? 'Отменить поиск работы'
                                                    : 'Найдите мне новую работу!'),
                                                style: whiteButtonStyle,
                                              ),
                                            ),
                                            SizedBox(width: h20),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: saveResume,
                                                child: Text('Сохранить ссылку'),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: h20),
                                Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(11),
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
                                                      decoration: inputDecoration('Старый пароль'),
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
                                                      decoration: inputDecoration('Новый пароль'),
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
                                                      decoration:
                                                          inputDecoration('Подтвердите пароль'),
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
                                        ElevatedButton(
                                          onPressed: changePassword,
                                          style: _passwordChangeEnabled
                                              ? ElevatedButton.styleFrom(
                                                  backgroundColor: cardAddButtonBackColor)
                                              : whiteButtonStyle,
                                          child: Text('Сменить пароль'),
                                        ),
                                      ],
                                    ),
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

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      hintText: label,
      filled: true,
      fillColor: Colors.white,
      floatingLabelStyle: TextStyle(color: Colors.grey[800]),
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Ссылка скопирована в буфер!')));
    }
  }

  Future<void> saveResume() async {
    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.currentUser!.userData['resume'] = _resumeController.text;
    if (await authProvider.saveCV(authProvider.currentUser!.userData)) {
      // показать уведомление
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Ссылка на резюме сохранена!')));
    }
  }

  Future<void> _openResultDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Добились ли вы своей цели?'),
          contentPadding: EdgeInsets.all(h20),
          // insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: baseScreenWidth / 2,
              maxWidth: baseScreenWidth,
            ),
            child: TextFormField(
              controller: _resultDescController,
              decoration: inputDecoration(
                'Расскажите вкратце какая реакция была на презентацию, и чего добились',
              ),
              autofocus: true,
              minLines: 3,
              maxLines: 3,
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.all(h20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                        onPressed: () => sendResult(context, 'yes'),
                        child: Text('Получилось'),
                        style: ElevatedButton.styleFrom(backgroundColor: cardAddButtonBackColor)),
                  ),
                  SizedBox(width: h20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => sendResult(context, 'no'),
                      child: Text('Отказали'),
                    ),
                  ),
                ],
              ),
            ),
          ],
          actionsPadding: EdgeInsets.zero,
          actionsAlignment: MainAxisAlignment.center,
        );
      },
    );
  }

  sendResult(BuildContext context, String result) async {
    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.currentUser!.userData['result_description'] = _resultDescController.text;
    authProvider.currentUser!.userData['result'] = result;
    if (await authProvider.saveCV(authProvider.currentUser!.userData)) {
      // показать уведомление
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result == 'yes' ? 'Поздравляем!' : 'Сожалеем')));
    }
    Navigator.pop(context);
  }

  // toggle need_job flag
  Future<void> saveJob() async {
    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.currentUser!.userData['need_job'] =
        !(authProvider.currentUser?.userData['need_job'] ?? false);
    if (await authProvider.saveCV(authProvider.currentUser!.userData)) {
      // показать уведомление
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ok')));
    }
  }
}
