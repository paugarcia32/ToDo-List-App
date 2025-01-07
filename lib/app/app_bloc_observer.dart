// import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:todo_app/utils/logging/logger.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  // @override
  // void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
  //   super.onChange(bloc, change);
  //   log('onChange(${bloc.runtimeType}, $change)');
  // }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    // log('onChange(${bloc.runtimeType}, $change)');
    Logger.log.t('onChange (${bloc.runtimeType}, $change)');
  }

  // @override
  // void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
  //   log('onError(${bloc.runtimeType}, $error, $stackTrace)');
  //   super.onError(bloc, error, stackTrace);
  // }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    Logger.log.e("Error in bloc [$bloc]", error: error, stackTrace: stackTrace);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    Logger.log.i('BLoC: $bloc | Transition: $transition');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    Logger.log.t(event);
  }
}
