import 'dart:js_interop';

import 'package:example/providers/auth_provider.dart';
import 'package:example/src/app_bar_with_menu.dart';
import 'package:example/src/constants.dart';
import 'package:example/src/widgets/cv_widget.dart';
import 'package:example/src/widgets/text_bar.dart';
import 'package:example/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markup_text/markup_text.dart';
import 'package:provider/provider.dart';
import 'dart:html' if (dart.library.io) 'dart:io' as html;

import 'models/cv.dart';

class ShowPage extends StatefulWidget {
  String id;

  ShowPage(String id) : id = id;

  @override
  _ShowPageState createState() => _ShowPageState();
}

class _ShowPageState extends State<ShowPage> {
  final _formKey = GlobalKey<FormState>(); // for change email
  final _oldPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController();
  final _resumeController = TextEditingController();
  final TextEditingController _resultDescController = TextEditingController();

  get commonTextStyle => TextStyle(fontSize: 20);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      html.document.title = 'Презентация';
    });

    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);

    // final queryParams = Uri.base.queryParameters;
    String id = widget.id;
    authProvider.loadUserCV(id);
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: true);

    print('---BUILD------------ ${authProvider.userCV}');

    CV? cv = authProvider.userCV;
    Widget cvWidget;
    if (cv != null) {
      cvWidget = CVWidget(cv: cv, guid: widget.id);
    } else {
      cvWidget = Center(
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
      );
    }

    double h20 = 20; // vertical indent

    return Scaffold(
      appBar: AntAppBar(
        title: "Презентация намерений",
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
                      constraints: BoxConstraints(maxWidth: baseScreenWidth),
                      child: Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20.0),
                          child: ListView(
                            children: [
                              // TextBar('Презентация намерений'),
                              SizedBox(height: h20),
                              cvWidget,
                              SizedBox(height: h20),

                              // set assign result buttons
                              if (authProvider.currentUser == null)
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: h20, horizontal: h20),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => _openManagerReactDialog(context, false),
                                          child: Text('Разьяснить отказ'),
                                          style: ElevatedButton.styleFrom(
                                            elevation: 0.5,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 19,
                                            ),
                                            backgroundColor: cardColorDislike,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: h20),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => _openManagerReactDialog(context, true),
                                          child: Text('Можно обсудить'),
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
                                    ],
                                  ),
                                ),
                              // view assign result
                              if (cv != null &&
                                  cv.getValue('assign') != null &&
                                  authProvider.userCV!.getValue('assign') != 0)
                                Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(11),
                                    side: BorderSide(
                                      color: cv.getValue('assign') == 1
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
                                        cv.getValue('assign') == 1
                                            ? MarkupText(
                                                '(b)Результат:(/b) (c #47b33d)Положительный(/c)',
                                                style: commonTextStyle)
                                            : MarkupText(
                                                '(b)Результат:(/b) (c #cd3735)Отрицательный(/c)',
                                                style: commonTextStyle),
                                        SizedBox(height: h20),
                                        MarkupText('${cv.getValue('comment')}',
                                            style: commonTextStyle),
                                      ],
                                    ),
                                  ),
                                ),

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
                                          /* TextFormField(
                                            controller: _oldPasswordController,
                                            decoration: inputDecorattion(
                                                'Старый пароль'),
                                            obscureText: true,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Укажите пароль';
                                              }
                                              return null;
                                            },
                                          ) */
                                          SizedBox(height: 16),
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
                              /* Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: changePassword,
                                  style: _passwordChangeEnabled
                                      ? redButtonStyle
                                      : grayButtonStyle,
                                  child: Text('Сохранить'),
                                ),
                              ) */
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Нижняя панель
                Container(
                  height: 10,
                  color: Colors.white,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void edit() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('\nOk\n', textAlign: TextAlign.center),
          backgroundColor: Theme.of(context).colorScheme.primary),
    );

    // Navigator.pushNamed(context, '/');
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
              content: Text('\nПароль изменен!\n', textAlign: TextAlign.center),
              backgroundColor: Theme.of(context).colorScheme.primary),
        );

        // Navigator.pushNamed(context, '/Show');
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
              '/show?id=' +
              authProvider.currentUser!.guid));

      // показать уведомление
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Ссылка скопирована в буфер!'),
          backgroundColor: Theme.of(context).colorScheme.primary));
    }
  }

  Future<void> _openManagerReactDialog(BuildContext context, bool assign) async {
    double h20 = 20;

    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(assign ? 'Можно обсудить наши возможности' : 'Разъяснение'),
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
                assign
                    ? 'Можете оставить комментарий, либо назначить встречу'
                    : 'Можете оставить комментарий',
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
                      onPressed: () => Navigator.pop(context),
                      child: Text('Отмена'),
                      // style: ElevatedButton.styleFrom(backgroundColor: cardAddButtonBackColor)
                    ),
                  ),
                  SizedBox(width: h20),
                  Expanded(
                    child: ElevatedButton(
                        onPressed: () => sendManagerResult(context, assign),
                        child: Text('Сохранить'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          foregroundColor: Colors.white,
                        )),
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

  sendManagerResult(BuildContext context, bool assign) async {
    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (await authProvider.saveResult(widget.id, assign ? 1 : -1, _resultDescController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ok')));
    }
    Navigator.pop(context);
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
}

// d56iefpams3vsfqpk5k0