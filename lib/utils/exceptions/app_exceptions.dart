sealed class AppException implements Exception {
  AppException(
    this.code,
    this.message,
  );
  final String code;
  final String message;

  @override
  String toString() => message;
}

class TodoNotFoundException extends AppException {
  TodoNotFoundException() : super('todo-not-found', 'todo not found');
}
