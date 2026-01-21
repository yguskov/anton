import 'package:example/profile.dart';
import 'package:example/show.dart';
import 'package:example/src/app_bar_with_menu.dart';
import 'login.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'services/api_service.dart';

import 'package:flutter/material.dart';
import 'example.dart';

import 'package:example/register.dart';
import 'package:example/styles.dart';

GlobalKey<StepFinishState>? stepFinishKey = GlobalKey<StepFinishState>();

void main() {
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
      ],
      child: MaterialApp(
        onGenerateRoute: (settings) {
          // settings.name содержит путь, например: '/page/123'
          return generateRoute(settings);
        },
        title: 'HR',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFF5801fd),
            onPrimary: Colors.white,
            secondary: Colors.orange,
            onSecondary: Colors.white,
            surface: Colors.grey.shade100,
            onSurface: Colors.grey.shade700,
            background: Colors.white,
            onBackground: Colors.grey.shade700,
            error: Colors.redAccent,
            onError: Colors.white,
          ),
          progressIndicatorTheme: ProgressIndicatorThemeData(
            linearTrackColor: Colors.orange.shade100,
            color: Colors.orange,
          ),
          popupMenuTheme: PopupMenuThemeData(
            textStyle: TextStyle(color: Colors.white, fontSize: 16),
            color: Color(0xFF5801fd),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
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
    double h20 = 20; // vertical indent
    return Scaffold(
      appBar: AntAppBar(
        title: "Начало",
      ),
      body: CustomScrollView(
        slivers: [
          // Верхний фиксированный элемент
          SliverToBoxAdapter(
            child: Container(
              color: Color.fromARGB(255, 2, 83, 36),
              child: Center(
                  child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  textAlign: TextAlign.center,
                  'Тут должно быть красиво расписано, про что все это',
                  style: TextStyle(color: Colors.white),
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
                  color: Theme.of(context).colorScheme.primary,
                  child: Center(child: Text('ССылки')),
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
