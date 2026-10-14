import 'package:flutter_application_1/application/core/utils/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    Logger.logInfo('--> [BLOC EVENT] ${bloc.runtimeType} | $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    Logger.logSuccess('[BLOC STATE] ${bloc.runtimeType} | ${change.currentState} -> ${change.nextState}');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    Logger.logInfo('[BLOC TRANSITION] ${bloc.runtimeType} | ${transition.event} => ${transition.nextState}');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    Logger.logError('[BLOC ERROR] ${bloc.runtimeType} | $error');
    super.onError(bloc, error, stackTrace);
  }
}
