import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:todos_api/json_map.dart';
import 'package:uuid/uuid.dart';


part 'todo.g.dart';

@immutable
@JsonSerializable()
class Todo extends Equatable {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;

  Todo(
      {required this.title,
      String? id,
      this.description = '',
      this.isCompleted = false})
      : assert(id == null || id.isNotEmpty,
            'Id can not be null and should be empty'),
        id = id ?? const Uuid().v4();

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  static Todo fromJson(JsonMap json) => _$TodoFromJson(json);

  JsonMap toJson() => _$TodoToJson(this);

  @override
  List<Object> get props => [id, title, description, isCompleted];
}
