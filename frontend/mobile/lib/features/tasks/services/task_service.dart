import 'dart:async';
import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/connection_provider.dart';
import '../../../core/providers/websocket_provider.dart';
import '../models/task_model.dart';
import '../models/assembly_point_model.dart';

class TaskService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: AppConstants.connectionTimeoutSec),
    receiveTimeout: const Duration(seconds: AppConstants.connectionTimeoutSec),
  ));

  final Dio _esp32Dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: AppConstants.esp32TimeoutSec),
    receiveTimeout: const Duration(seconds: AppConstants.esp32TimeoutSec),
  ));

  // ── Backend metotları ────────────────────────────────────────────────────

  Future<List<TaskModel>> getNearbyTasks(
      double? lat, double? lon, String? token) async {
    try {
      final options = Options();
      if (token != null) {
        options.headers = {'Authorization': 'Bearer $token'};
      }

      final queryParams = <String, dynamic>{};
      if (lat != null) queryParams['lat'] = lat;
      if (lon != null) queryParams['lon'] = lon;

      final res = await _dio.get(
        '${AppConstants.apiBaseUrl}/tasks/',
        queryParameters: queryParams,
        options: options,
      );

      final List data = res.data['tasks'] ?? [];
      return data
          .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException {
      return _getMockTasks();
    } catch (_) {
      return _getMockTasks();
    }
  }

  Future<List<TaskModel>> getMyTasks(String? token,
      {ConnectionType connectionType = ConnectionType.internet}) async {
    if (connectionType == ConnectionType.esp32) {
      return _getMyTasksViaEsp32(token);
    }
    try {
      final options = Options();
      if (token != null) {
        options.headers = {'Authorization': 'Bearer $token'};
      }

      final res = await _dio.get(
        '${AppConstants.apiBaseUrl}/tasks/my',
        options: options,
      );

      final List data = res.data is List
          ? res.data as List
          : (res.data['tasks'] as List? ?? []);
      return data
          .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException {
      return _getMockTasks();
    } catch (_) {
      return _getMockTasks();
    }
  }

  Future<void> acceptTask(int id, String? token,
      {ConnectionType connectionType = ConnectionType.internet}) async {
    if (connectionType == ConnectionType.esp32) {
      return _acceptTaskViaEsp32(id, token);
    }
    try {
      final options = Options();
      if (token != null) {
        options.headers = {'Authorization': 'Bearer $token'};
      }
      await _dio.post('${AppConstants.apiBaseUrl}/tasks/$id/accept',
          options: options);
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> rejectTask(int id, String? token,
      {ConnectionType connectionType = ConnectionType.internet}) async {
    if (connectionType == ConnectionType.esp32) {
      return _rejectTaskViaEsp32(id, token);
    }
    try {
      final options = Options();
      if (token != null) {
        options.headers = {'Authorization': 'Bearer $token'};
      }
      await _dio.post('${AppConstants.apiBaseUrl}/tasks/$id/reject',
          options: options);
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> completeTask(int id, String? token,
      {ConnectionType connectionType = ConnectionType.internet}) async {
    if (connectionType == ConnectionType.esp32) {
      return _completeTaskViaEsp32(id, token);
    }
    try {
      final options = Options();
      if (token != null) {
        options.headers = {'Authorization': 'Bearer $token'};
      }
      await _dio.post('${AppConstants.apiBaseUrl}/tasks/$id/complete',
          options: options);
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  // ── ESP32 metotları ──────────────────────────────────────────────────────

  Future<List<TaskModel>> _getMyTasksViaEsp32(String? token) async {
    final completer = Completer<List<TaskModel>>();
    StreamSubscription? sub;

    sub = WebSocketProvider.esp32Events.listen((data) {
      final event = data['event'] as String?;
      if (event == 'YOUR_TASKS' && !completer.isCompleted) {
        try {
          final raw = data['tasks'] as List? ?? data['data'] as List? ?? [];
          completer.complete(raw
              .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
              .toList());
        } catch (_) {
          completer.complete([]);
        }
        sub?.cancel();
      }
    });

    try {
      await _esp32Dio.post(
        '${AppConstants.esp32BaseUrl}/tasks/my/request',
        data: {'token': token ?? ''},
      );
    } catch (_) {
      sub.cancel();
      return _getMockTasks();
    }

    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        sub?.cancel();
        return _getMockTasks();
      },
    );
  }

  Future<void> _acceptTaskViaEsp32(int id, String? token) async {
    try {
      await _esp32Dio.post(
        '${AppConstants.esp32BaseUrl}/tasks/accept',
        data: {'task_id': id, 'token': token ?? ''},
      );
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  Future<void> _rejectTaskViaEsp32(int id, String? token) async {
    try {
      await _esp32Dio.post(
        '${AppConstants.esp32BaseUrl}/tasks/reject',
        data: {'task_id': id, 'token': token ?? ''},
      );
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  Future<void> _completeTaskViaEsp32(int id, String? token) async {
    try {
      await _esp32Dio.post(
        '${AppConstants.esp32BaseUrl}/tasks/complete',
        data: {'task_id': id, 'token': token ?? ''},
      );
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  // ── Mock ─────────────────────────────────────────────────────────────────

  List<TaskModel> _getMockTasks() {
    return [
      const TaskModel(
        id: 1,
        type: 'FOOD_DISTRIBUTION',
        title: 'Yardım Dağıtımı',
        assemblyPoint: AssemblyPointModel(
          id: 1,
          name: 'Atatürk İlkokulu',
          lat: 39.6484 + 0.005,
          lon: 27.8826 + 0.005,
        ),
        peopleNeeded: 2,
        startTime: '14:00',
        endTime: '16:00',
        description: 'Gıda paketleri dağıtımı',
        status: 'open',
      ),
      const TaskModel(
        id: 2,
        type: 'WATER_CARRY',
        title: 'Su/Malzeme Taşıma',
        assemblyPoint: AssemblyPointModel(
          id: 1,
          name: 'Atatürk İlkokulu',
          lat: 39.6484 + 0.005,
          lon: 27.8826 + 0.005,
        ),
        peopleNeeded: 4,
        startTime: '15:00',
        endTime: '18:00',
        description: 'İçme sularının çadırlara taşınması',
        status: 'open',
      ),
      const TaskModel(
        id: 3,
        type: 'CLEANING',
        title: 'Temizlik',
        assemblyPoint: AssemblyPointModel(
          id: 2,
          name: 'Cumhuriyet Meydanı',
          lat: 39.6484 - 0.008,
          lon: 27.8826 - 0.002,
        ),
        peopleNeeded: 10,
        startTime: '09:00',
        endTime: '12:00',
        description: 'Meydan çadır alanı çevre temizliği',
        status: 'open',
      ),
      const TaskModel(
        id: 4,
        type: 'CARE',
        title: 'Refakat',
        assemblyPoint: AssemblyPointModel(
          id: 2,
          name: 'Cumhuriyet Meydanı',
          lat: 39.6484 - 0.008,
          lon: 27.8826 - 0.002,
        ),
        peopleNeeded: 1,
        startTime: 'Hemen',
        endTime: 'Belirsiz',
        description: 'Yaşlı bir afetzedenin sağlık çadırına nakli',
        status: 'open',
      ),
    ];
  }
}
