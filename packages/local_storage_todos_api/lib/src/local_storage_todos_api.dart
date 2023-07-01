import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todos_api/todos_api.dart';
/// {@template local_storage_todos_api}
/// A Flutter implementation of the TodosApi that uses local storage.
/// {@endtemplate}
class LocalStorageTodosApi extends TodosApi {
  /// {@macro local_storage_todos_api}
  LocalStorageTodosApi({required SharedPreferences plugin}) : _plugin = plugin {
    _init();
  }

  final SharedPreferences _plugin;
  final _todoStreamController = BehaviorSubject<List<Todo>>.seeded(const []);

  @visibleForTesting
  static const kTodosCollectionKey = '__todos_collection_key__';

  String? _getValue(String key) => _plugin.getString(key);
  Future<void> _setValue(String key, String value) =>
      _plugin.setString(key, value);
  void _init() {
    final todoJson = _getValue(kTodosCollectionKey);
    if (todoJson != null) {
      final todos =
          List<Map<dynamic, dynamic>>.from(jsonDecode(todoJson) as List)
              .map(
                (e) => Todo.fromJson(
                  Map<String, dynamic>.from(
                    e,
                  ),
                ),
              )
              .toList();
      _todoStreamController.add(todos);
    } else {
      _todoStreamController.add(const []);
    }
  }

  @override
  Stream<List<Todo>> getTodos() => _todoStreamController.asBroadcastStream();

  @override
  Future<int> clearCompleted() async {
    final todos = [..._todoStreamController.value];
    final completedTodoAmounts =
        todos.where((element) => element.isCompleted == true).length;
    todos.removeWhere((element) => element.isCompleted == true);
    _todoStreamController.add(todos);
    await _setValue(kTodosCollectionKey, jsonEncode(todos));
    return completedTodoAmounts;
  }

  @override
  Future<int> completedAll({required bool isCompleted}) async {
    final todos = [..._todoStreamController.value];
    final changedTodoAmounts =
        todos.where((element) => element.isCompleted != isCompleted).length;
    final newTodos = [
      for (final todo in todos)
        todo.copyWith(
          isCompleted: isCompleted,
        ),
    ];
    _todoStreamController.add(newTodos);
    await _setValue(kTodosCollectionKey, jsonEncode(newTodos));
    return changedTodoAmounts;
  }

  @override
  Future<void> deleteTodo(String id) async {
    final todos = [..._todoStreamController.value];
    final todoIndex = todos.indexWhere((element) => element.id == id);
    if (todoIndex == -1) {
      throw TodoNotFoundException();
    } else {
      todos.removeAt(todoIndex);
      _todoStreamController.add(todos);
      return _setValue(kTodosCollectionKey, jsonEncode(todos));
    }
  }

  @override
  Future<void> saveTodo(Todo todo) {
    final todos = [..._todoStreamController.value];
    final todoIndex = todos.indexWhere((element) => element.id == todo.id);
    if (todoIndex >= 0) {
      todos[todoIndex] = todo;
    } else {
      todos.add(todo);
    }
    _todoStreamController.add(todos);
    return _setValue(kTodosCollectionKey, jsonEncode(todos));
  }
}
