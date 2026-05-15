class RequestResponse {
  final String status;
  final int    id;
  final String message;
  final String receivedAt;

  const RequestResponse({
    required this.status,
    required this.id,
    required this.message,
    required this.receivedAt,
  });

  factory RequestResponse.fromJson(Map<String, dynamic> json) => RequestResponse(
        status:     json['status']      as String? ?? 'ok',
        id:         json['id']          as int?    ?? 0,
        message:    json['message']     as String? ?? 'Talebiniz alındı.',
        receivedAt: json['received_at'] as String? ?? DateTime.now().toIso8601String(),
      );

  static RequestResponse mock(String category) => RequestResponse(
        status:     'ok',
        id:         1000 + DateTime.now().millisecond,
        message:    '$category talebiniz alındı. Ekipler yönlendiriliyor.',
        receivedAt: DateTime.now().toIso8601String(),
      );
}
