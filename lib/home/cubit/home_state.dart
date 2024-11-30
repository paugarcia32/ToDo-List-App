part of 'home_cubit.dart';

enum HomeTab { todos, stats, explore }

final class HomeState extends Equatable {
  const HomeState({
    this.tab = HomeTab.todos,
  });

  final HomeTab tab;

  @override
  List<Object> get props => [tab];
}
