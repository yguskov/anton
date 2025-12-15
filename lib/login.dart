import 'package:example/providers/auth_provider.dart';
import 'package:example/src/app_bar_with_menu.dart';
import 'package:example/src/widgets/text_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {

    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: true);

                Column(
                  children:  [
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 1024),
                          child: Container(
                            color: Colors.grey[300], 
                            child: authProvider.isLoading
                              ? CircularProgressIndicator(backgroundColor: Colors.white,)
                              : ListView(children: [
                              SizedBox(height: 10,),
                              Text('id: ${authProvider.currentUser?.id}', textAlign: TextAlign.center,),
                              SizedBox(height: 10,),
                              Text('Создан: ${authProvider.currentUser?.createdAt}', textAlign: TextAlign.center,), 
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Нижняя панель
                    Container(height: 90, color: Colors.white, child: Center(child: ElevatedButton(onPressed: () {  },
                    child: Text('Сохранить ')))),
                  ],
                );


    return Scaffold(
            appBar: AntAppBar(
              title: "Авторизация пользователя",
            ),
            body: LayoutBuilder(builder: (context, constraints) {
              List<Widget> textFields = [];
              if (authProvider.isAuth) {
                textFields = [
                  TextBar('Вы уже авторизованы как ${authProvider.currentUser!.email}')
                ];
              } else {
                textFields = [
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Почта',
                      hintText: 'user@mail.com',
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
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Укажите почту';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Пароль',
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
                    ),
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
                  // TextFormField(
                  //   controller: _nameController,
                  //   decoration: InputDecoration(labelText: 'Name'),
                  // ),
                  SizedBox(height: 20),
                  if (authProvider.error != null)
                    Text(
                      authProvider.error!,
                      style: TextStyle(color: Colors.red),
                    ),
                  SizedBox(height: 20),
                  authProvider.isLoading
                      ? CircularProgressIndicator()
                      : SizedBox(height: 20),
                ];
              }

              ;

              return Column(
                  children:  [
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 1024),
                          child: Container(
                            color: Colors.grey[300], 
                            child: authProvider.isLoading
                              ? CircularProgressIndicator(backgroundColor: Colors.white,)
                              : ListView(
                                padding: EdgeInsets.all(100),
                                  controller: _scrollController,
                                  children: [
                                    Form(
                                        key: _formKey,
                                        child: Column(
                                          children: textFields,
                                        )),
                                        
                                  ],
                                )
                          ),
                        ),
                      ),
                    ),

                    // Нижняя панель
                    Container(height: 190, color: Colors.white, child: Center(child: ElevatedButton(onPressed: login,
                    child: Text('Авторизоваться ')))),
                  ],
                );
            }),
          ); 
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void login() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_formKey.currentState!.validate()) {
      final success = await authProvider.login(
        _emailController.text,
        _passwordController.text,
      );

      if (success) {
        print(
            '---- email : ${authProvider.currentUser?.email}');
        Navigator.pushReplacementNamed(context, '/profile');
        Navigator.pushNamed(context, '/profile');
      } else {
        print('Ошибка авторизации');
      }
    }
  }  
}