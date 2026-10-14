import 'package:dio/dio.dart';
import 'package:flutter_application_1/application/core/utils/logger.dart';
import 'package:flutter_application_1/domain/core/di/local_notification_serveice.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class AppInjectionModule {
  @preResolve
  Future<SharedPreferences> pref() => SharedPreferences.getInstance();

  @preResolve
  Future<PermissionHandler> reqPermission() => PermissionHandler.initial();

  @preResolve
  Future<LocalNotification> initLocalNotification() => LocalNotification.init();

  @lazySingleton
  Dio get dio => Dio();
}

class PermissionHandler {
  static Future<PermissionHandler> initial() async {
    await Permission.notification.request();

    return PermissionHandler();
  }
}
