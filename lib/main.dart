import 'package:flutter/material.dart';
import 'package:flutter_application_1/application/core/app_details.dart';
import 'package:flutter_application_1/application/core/route/app_route.dart';
import 'package:flutter_application_1/application/core/theme/app_theme.dart';
import 'package:flutter_application_1/application/core/theme/theme/theme_cubit.dart';
import 'package:flutter_application_1/application/core/utils/enums.dart';
import 'package:flutter_application_1/domain/core/di/injection.dart';
import 'package:flutter_application_1/presentation/core/app_root.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dropdown_alert/dropdown_alert.dart';
import 'package:injectable/injectable.dart';
import 'application/application.dart';
import 'domain/domain.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependency(env: Environment.test);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    AppDetails.screenSize = MediaQuery.sizeOf(context);
    return MultiBlocProvider(
      providers: [],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            navigatorKey: AppDetails.globalNavigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Fliq',
            onGenerateRoute: AppRoute.onGenerateRoute,
            initialRoute: AppRoot.routeName,
            theme: AppTheme.getTheme(AppThemeMode.light),
            builder: (context, child) => Stack(
              children: [
                child!,
                const DropdownAlert(),
              ],
            ),
          );
        },
      ),
    );
  }
}
