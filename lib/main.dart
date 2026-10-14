import 'package:flutter/material.dart';
import 'package:flutter_application_1/application/core/app_details.dart';
import 'package:flutter_application_1/application/core/bloc/app_bloc_observer.dart';
import 'package:flutter_application_1/application/core/route/app_route.dart';
import 'package:flutter_application_1/application/core/theme/app_theme.dart';
import 'package:flutter_application_1/application/core/theme/theme/theme_cubit.dart';
import 'package:flutter_application_1/domain/core/di/injection.dart';
import 'package:flutter_application_1/presentation/core/app_root.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dropdown_alert/dropdown_alert.dart';
import 'package:injectable/injectable.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependency(env: Environment.dev);

  // Initialize global BLoC observer for complete event/state tracing
  Bloc.observer = sl<AppBlocObserver>();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppDetails.screenSize = MediaQuery.sizeOf(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => sl<ThemeCubit>(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            navigatorKey: AppDetails.globalNavigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Flutter Base App',
            onGenerateRoute: AppRoute.onGenerateRoute,
            initialRoute: AppRoot.routeName,
            theme: AppTheme.getTheme(state.themeMode),
            builder: (context, child) => Stack(
              children: [
                child ?? const SizedBox.shrink(),
                const DropdownAlert(),
              ],
            ),
          );
        },
      ),
    );
  }
}
