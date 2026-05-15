class AssemblyPointModel {
  final int id;
  final String name;
  final double lat;
  final double lon;

  const AssemblyPointModel({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
  });

  factory AssemblyPointModel.fromJson(Map<String, dynamic> json) => AssemblyPointModel(
    id: json['id'] as int? ?? 0,
    name: json['name'] as String? ?? 'Bilinmeyen Nokta',
    lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
    lon: (json['lon'] as num?)?.toDouble() ?? 0.0,
  );
}
