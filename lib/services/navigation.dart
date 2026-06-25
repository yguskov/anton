// navigation_service.dart
import 'package:flutter/material.dart';
import 'dart:html' as html;

class NavigationService {
  // Приватный конструктор для Singleton
  NavigationService._internal();
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;

  // Единственный ключ
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void navigateTo(String route, {Object? arguments}) {
    print('url updated to $route');
    _updateUrl(route);
    navigatorKey.currentState?.pushNamed(route, arguments: arguments);
  }

  void replaceWith(String route, {Object? arguments}) {
    _updateUrl(route);
    navigatorKey.currentState?.pushReplacementNamed(route, arguments: arguments);
  }

  void goBack() {
    navigatorKey.currentState?.pop();
  }

  void _updateUrl(String route) {
    final currentUrl = html.window.location.href;
    // final baseUrl = currentUrl.split('/').first;
    print('base-url=$baseUrl / route=$route');
    final newUrl = '${baseUrl}${route.substring(1)}';
    html.window.history.pushState(null, '', newUrl);
  }

  get baseUrl => _getBaseHref();

  _getBaseHref() {
    // Способ 1: Из HTML тега <base>
    final baseElement = html.document.querySelector('base');
    if (baseElement != null) {
      return baseElement.getAttribute('href') ?? '/';
    }

    // Способ 2: Из window.location
    final location = html.window.location;
    final pathname = location.pathname;

    // Если путь заканчивается на /, то это base href
    if (pathname!.endsWith('/')) {
      return pathname;
    }

    return '/';
    // Способ 3: Из параметров сборки (только для release)
    // const String baseHref = String.fromEnvironment('FLUTTER_BASE_HREF', defaultValue: '/');
    // return baseHref;
  }
}
