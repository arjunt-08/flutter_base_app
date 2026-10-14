import 'package:flutter/material.dart';
import 'package:flutter_application_1/application/core/utils/logger.dart';
import 'package:flutter_application_1/presentation/core/app_root.dart';
import 'package:page_transition/page_transition.dart';

class AppRoute {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    Logger.logWarning(
      'Route Name: ${settings.name},  Arguments: ${settings.arguments}, ArgumentType: ${settings.arguments.runtimeType}',
    );
    final arguments = (settings.arguments as Map<String, dynamic>?);

    switch (settings.name) {
      case AppRoot.routeName:
      default:
        return pushRoute(settings, const AppRoot());
    }
  }

  static Route<dynamic> pushRoute(RouteSettings settings, Widget screen) {
    return PageTransition(
      settings: settings,
      child: screen,
      curve: Curves.easeIn,
      duration: const Duration(milliseconds: 400),
      type: PageTransitionType.rightToLeft,
    );
  }
}
