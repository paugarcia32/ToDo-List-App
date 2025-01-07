import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:talker_bloc_logger/talker_bloc_logger_observer.dart';
import 'package:talker_bloc_logger/talker_bloc_logger_settings.dart';
import 'package:todo_app/app/app.dart';
import 'package:todo_app/app/app_bloc_observer.dart';
import 'package:todos_api/todos_api.dart';
import 'package:todos_repository/todos_repository.dart';

void bootstrap({required TodosApi todosApi}) {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    log(error.toString(), stackTrace: stack);
    return true;
  };

  // Bloc.observer = const AppBlocObserver();
  Bloc.observer = TalkerBlocObserver(
    settings: TalkerBlocLoggerSettings(
      enabled: true,
      printEventFullData: false,
      printStateFullData: false,
      printChanges: true,
      printClosings: true,
      printCreations: true,
      printEvents: true,
      printTransitions: true,
      // If you want log only AuthBloc transitions
      // transitionFilter: (bloc, transition) => bloc.runtimeType.toString() == 'AuthBloc',
      // // If you want log only AuthBloc events
      // eventFilter: (bloc, event) => bloc.runtimeType.toString() == 'AuthBloc',
    ),
  );

  final todosRepository = TodosRepository(todosApi: todosApi);

  runApp(App(todosRepository: todosRepository));
}
