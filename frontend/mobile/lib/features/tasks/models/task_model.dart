import 'assembly_point_model.dart';

class TaskModel {
  final int id;
  final String type;
  final String title;
  final AssemblyPointModel assemblyPoint;
  final int peopleNeeded;
  final String startTime;
  final String endTime;
  final String description;
  final String status; // open | accepted | completed

  const TaskModel({
    required this.id,
    required this.type,
    required this.title,
    required this.assemblyPoint,
    required this.peopleNeeded,
    required this.startTime,
    required this.endTime,
    required this.description,
    required this.status,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
    id: json['id'] as int? ?? 0,
    type: json['type'] as String? ?? 'UNKNOWN',
    title: json['title'] as String? ?? 'Görev',
    assemblyPoint: AssemblyPointModel.fromJson(json['assembly_point'] as Map<String, dynamic>? ?? {}),
    peopleNeeded: json['people_needed'] as int? ?? 1,
    startTime: json['start_time'] as String? ?? 'Bilinmiyor',
    endTime: json['end_time'] as String? ?? 'Bilinmiyor',
    description: json['description'] as String? ?? '',
    status: json['status'] as String? ?? 'open',
  );

  TaskModel copyWith({
    int? id,
    String? type,
    String? title,
    AssemblyPointModel? assemblyPoint,
    int? peopleNeeded,
    String? startTime,
    String? endTime,
    String? description,
    String? status,
  }) {
    return TaskModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      assemblyPoint: assemblyPoint ?? this.assemblyPoint,
      peopleNeeded: peopleNeeded ?? this.peopleNeeded,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }
}
