import 'dart:ui';

import 'package:example/profile.dart';
import 'package:example/services/navigation.dart';
import 'package:example/show.dart';
import 'package:example/src/app_bar_with_menu.dart';
import 'package:example/src/widgets/login_dialog.dart';
import 'package:example/users.dart';
import 'login.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'services/api_service.dart';

import 'package:flutter/material.dart';
import 'example.dart';

import 'package:example/register.dart';
import 'package:example/styles.dart';
import 'dart:html' as html;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

final NavigationService navigationService = NavigationService();

void main() {
  setUrlStrategy(PathUrlStrategy());

  final currentPath = html.window.location.pathname;
  print(
      '================ Current path: $currentPath --Base Url =${navigationService.baseUrl}----------');

  const htmlUrl = String.fromEnvironment('HTML_URL', defaultValue: '/html/index.html');
  print('-html=${htmlUrl}---');
  if (currentPath == navigationService.baseUrl) {
    print('================ htmlUrl: $htmlUrl ----------');

    html.window.location.href = htmlUrl;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Route<dynamic>? generateRoute(RouteSettings settings) {
    final String? path = settings.name;
    print('------------- $path');

    // Роут /page/:id
    if (path != null && path.startsWith('/review/')) {
      final idStr = path.substring('/review/'.length);
      print('-------- review - $idStr');
      return MaterialPageRoute(
        builder: (context) => ShowPage(idStr),
      );
    }

    switch (path) {
      case '/login':
        return MaterialPageRoute(builder: (context) => LoginPage());
      // Главная страница (home)
      case '/profile':
        return MaterialPageRoute(builder: (context) => ProfilePage());
      case '/register':
        return MaterialPageRoute(builder: (context) => ProviderExamplePage.provider());
      case '/users':
        return MaterialPageRoute(builder: (context) => userPage());

      case '':
      case '/':
        return MaterialPageRoute(builder: (context) => HomePage());
    }

    // Роут не найден
    return MaterialPageRoute(
      builder: (context) => NotFoundPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        ChangeNotifierProxyProvider<ApiService, AuthProvider>(
          create: (context) => AuthProvider(apiService: ApiService()),
          update: (context, apiService, authProvider) => AuthProvider(apiService: apiService),
        ),
        // Провайдер для навигации
        Provider<NavigationService>(
          create: (_) => navigationService,
        ),
      ],
      child: MaterialApp(
        onGenerateRoute: (settings) {
          // settings.name содержит путь, например: '/page/123'
          return generateRoute(settings);
        },
        initialRoute: '/',
        navigatorKey: navigationService.navigatorKey,
        title: 'HR',
        theme: ThemeData(
            primarySwatch: Colors.blue,
            colorScheme: ColorScheme(
              brightness: Brightness.light,
              primary: Colors.white,
              onPrimary: Colors.black54,
              secondary: secondaryColor,
              onSecondary: Colors.black54,
              surface: Colors.grey.shade100,
              onSurface: Colors.grey.shade700,
              background: Colors.white,
              onBackground: Colors.grey.shade700,
              error: Colors.redAccent,
              onError: Colors.white,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Color(0xFFF9FAFB),
              // You can also set other properties
              elevation: 0, // Removes shadow
              foregroundColor: Colors.black, // Text/icon color
            ),
            progressIndicatorTheme: ProgressIndicatorThemeData(
              linearTrackColor: Colors.orange.shade100,
              color: Colors.orange,
            ),
            popupMenuTheme: PopupMenuThemeData(
              textStyle: TextStyle(color: Colors.black87, fontSize: 16),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: Colors.black, // Global cursor color for all TextFields
              selectionColor: Colors.grey.shade400,
              selectionHandleColor: Colors.grey.shade400,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true, // Обязательно включите filled
              fillColor: Colors.white, // Цвет фона для всех TextField
              floatingLabelStyle:
                  TextStyle(color: Colors.grey[800]), // labelText color in focus for TextFormField
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0.5,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 19,
                ),
                // backgroundColor: Colors.green,

                foregroundColor: Colors.black54,
              ),
            )),
      ),
    );
  }
}

class NotFoundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: Text('Page not found'));
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: true);

    double h20 = 20; // vertical indent
    return Scaffold(
      appBar: AntAppBar(
        title: "/",
      ),
      body: CustomScrollView(
        slivers: [
          // Buttons
          SliverToBoxAdapter(
            child: Container(
              color: Colors.blueGrey,
              child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: authProvider.isAuth
                        ? SizedBox(height: 40)
                        : ElevatedButton(
                            onPressed: () => showLoginDialog(context),
                            child: Text('Авторизуйтесь'),
                            style: grayButtonStyle,
                          ),
                  )),
            ),
          ),

          // Средний элемент - растягивается или скроллится
          SliverFillRemaining(
            hasScrollBody: false,
            fillOverscroll: true,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: SingleChildScrollView(
                        physics: NeverScrollableScrollPhysics(),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLongContent(context), // Много контента
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Нижний фиксированный элемент
                Container(
                  height: 50,
                  color: Colors.blueGrey /* Theme.of(context).colorScheme.primary */,
                  child: Center(child: Text(' ', style: TextStyle(color: Colors.white))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildLongContent(context) {
    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, '/register'),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text('Создать презентацию'),
      ),
      style: redButtonStyle,
    );
  }
}
