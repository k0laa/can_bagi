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
  final String status; // open | assigned | completed
  final int priorityScore;
  final int maxAssignees;
  final int currentAssignees;
  final String? assignedTo;

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
    this.priorityScore = 0,
    this.maxAssignees = 1,
    this.currentAssignees = 0,
    this.assignedTo,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    AssemblyPointModel assemblyPoint;
    if (json['assembly_point'] != null) {
      assemblyPoint = AssemblyPointModel.fromJson(
          json['assembly_point'] as Map<String, dynamic>);
    } else {
      assemblyPoint = AssemblyPointModel(
        id: 0,
        name: json['title'] as String? ?? 'Görev Noktası',
        lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
        lon: (json['lon'] as num?)?.toDouble() ?? 0.0,
      );
    }

    return TaskModel(
      id: json['id'] as int? ?? 0,
      type: json['type'] as String? ?? 'UNKNOWN',
      title: json['title'] as String? ?? 'Görev',
      assemblyPoint: assemblyPoint,
      peopleNeeded: json['people_needed'] as int? ??
          (json['max_assignees'] as int? ?? 1),
      startTime: json['start_time'] as String? ?? 'Bilinmiyor',
      endTime: json['end_time'] as String? ?? 'Bilinmiyor',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'open',
      priorityScore: json['priority_score'] as int? ?? 0,
      maxAssignees: json['max_assignees'] as int? ?? 1,
      currentAssignees: json['current_assignees'] as int? ?? 0,
      assignedTo: json['assigned_to']?.toString(),
    );
  }

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
    int? priorityScore,
    int? maxAssignees,
    int? currentAssignees,
    String? assignedTo,
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
      priorityScore: priorityScore ?? this.priorityScore,
      maxAssignees: maxAssignees ?? this.maxAssignees,
      currentAssignees: currentAssignees ?? this.currentAssignees,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }
}
