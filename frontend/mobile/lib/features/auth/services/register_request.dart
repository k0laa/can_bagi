class RegisterRequest {
  final String name;
  final String surname;
  final String phone;
  final String password;
  final String bloodType;

  const RegisterRequest({
    required this.name,
    required this.surname,
    required this.phone,
    required this.password,
    required this.bloodType,
  });

  Map<String, dynamic> toJson() => {
    'name':       name,
    'surname':    surname,
    'phone':      phone,
    'password':   password,
    'blood_type': bloodType,
  };
}
