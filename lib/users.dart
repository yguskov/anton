import 'package:example/providers/auth_provider.dart';
import 'package:example/src/app_bar_with_menu.dart';
import 'package:example/src/widgets/user_grid.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class userPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: true);

    return Scaffold(
      appBar: AntAppBar(
        title: "Список юзеров",
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
                    child: Container(
                      // color: Colors.grey[300],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20.0),
                        child: UserGridWidget(),
                      ),
                    ),
                  ),
                ),

                // Нижняя панель
                // Container(
                //   height: 10,
                //   color: Colors.white,
                // ),
              ],
            );
          },
        ),
      ),
    );
  }
}
