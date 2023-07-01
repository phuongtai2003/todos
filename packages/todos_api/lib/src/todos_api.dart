import 'package:todos_api/todos_api.dart';

/// {@template todos_api}
/// The interface and models for an API providing access to todos.
/// {@endtemplate}
abstract class TodosApi {
  /// {@macro todos_api}
  const TodosApi();
  /// Provides a stream of all todos
  Stream<List<Todo>> getTodos();

  /// Saves a todo.
  Future<void> saveTodo(Todo todo);

  /// Deletes the `todo` with the given id.
  Future<void> deleteTodo(String id);

  /// Deletes all completed todos.
  Future<int> clearCompleted();

  /// Sets the `isCompleted` state of all todos to the given value.
  Future<int> completedAll({required bool isCompleted});
}

class TodoNotFoundException implements Exception {}
