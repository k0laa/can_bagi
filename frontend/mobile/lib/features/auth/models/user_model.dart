class UserModel {
  final int    id;
  final String name;
  final String surname;
  final String phone;
  final String bloodType;

  const UserModel({
    required this.id,
    required this.name,
    required this.surname,
    required this.phone,
    required this.bloodType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id:        json['id']         as int,
    name:      json['name']       as String,
    surname:   json['surname']    as String,
    phone:     json['phone']      as String,
    bloodType: json['blood_type'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id':         id,
    'name':       name,
    'surname':    surname,
    'phone':      phone,
    'blood_type': bloodType,
  };

  UserModel copyWith({String? name, String? surname, String? bloodType}) =>
      UserModel(
        id:        id,
        name:      name      ?? this.name,
        surname:   surname   ?? this.surname,
        phone:     phone,
        bloodType: bloodType ?? this.bloodType,
      );
}
