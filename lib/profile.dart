import 'package:example/providers/auth_provider.dart';
import 'package:example/src/app_bar_with_menu.dart';
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
      final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    
      if(authProvider.currentUser == null) {
          authProvider.fetchCurrentUser();
      }
      // final sccess = await authProvider.register();
      //       dynamic response = await _apiService.login(request);
      // _currentUser = response.User;
      // _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {

    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: true);

    return Scaffold(
            appBar: AntAppBar(
              title: "Профиль пользователя ${authProvider.currentUser?.email}",
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
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
              },
            ),
          ); 
  }
}