class UserModel {
  final int    id;
  final String name;
  final String surname;
  final String phone;
  final String bloodType;
  final String? skills;
  final int? activeTaskId;

  const UserModel({
    required this.id,
    required this.name,
    required this.surname,
    required this.phone,
    required this.bloodType,
    this.skills,
    this.activeTaskId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id:           json['id']          as int,
    name:         json['name']        as String,
    surname:      json['surname']     as String,
    phone:        json['phone']       as String,
    bloodType:    json['blood_type']  as String? ?? '',
    skills:       json['skills']      as String?,
    activeTaskId: json['active_task_id'] as int?,
  );

  Map<String, dynamic> toJson() => {
    'id':             id,
    'name':           name,
    'surname':        surname,
    'phone':          phone,
    'blood_type':     bloodType,
    'skills':         skills,
    'active_task_id': activeTaskId,
  };

  UserModel copyWith({
    String? name,
    String? surname,
    String? bloodType,
    String? skills,
    int? activeTaskId,
  }) =>
      UserModel(
        id:           id,
        name:         name      ?? this.name,
        surname:      surname   ?? this.surname,
        phone:        phone,
        bloodType:    bloodType ?? this.bloodType,
        skills:       skills    ?? this.skills,
        activeTaskId: activeTaskId ?? this.activeTaskId,
      );

  bool get hasActiveTask => activeTaskId != null;
}
