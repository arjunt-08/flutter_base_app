import 'package:flutter_application_1/domain/core/di/env.dart';

class Urls {
  static String get baseURL => Env.instance.domainUrl;
  static String get apiVersionUrl => '$baseURL/api/';

  // Auth Endpoints
  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String tokenRefresh = 'auth/token-refresh';

  // User Endpoints
  static const String users = 'users';
  static String userById(String id) => 'users/$id';
  static const String userProfile = 'users/profile';
  static const String updateProfile = 'users/update-profile';

  static String isPhoneNoAvailableKey = 'isPhoneNoAvailable';
}
