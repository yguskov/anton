import 'dart:js_interop';

import 'package:example/providers/auth_provider.dart';
import 'package:example/src/app_bar_with_menu.dart';
import 'package:example/src/widgets/cv_widget.dart';
import 'package:example/src/widgets/text_bar.dart';
import 'package:example/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      cvWidget = CVWidget(cv: cv);
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
                      constraints: BoxConstraints(maxWidth: 640),
                      child: Container(
                        // color: Colors.grey[300],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20.0),
                          child: ListView(
                            children: [
                              // TextBar('Презентация намерений'),
                              SizedBox(height: h20),
                              cvWidget,
                              SizedBox(height: 2 * h20),
                              Center(
                                child: ElevatedButton(
                                  onPressed: edit,
                                  child: Text('Можно обсудить'),
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
}

// d56iefpams3vsfqpk5k0