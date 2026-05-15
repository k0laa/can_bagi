import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../models/task_model.dart';
import '../models/assembly_point_model.dart';

class TaskService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: AppConstants.connectionTimeoutSec),
    receiveTimeout: const Duration(seconds: AppConstants.connectionTimeoutSec),
  ));

  Future<List<TaskModel>> getNearbyTasks(double? lat, double? lon, String? token) async {
    try {
      final options = Options();
      if (token != null) {
        options.headers = {'Authorization': 'Bearer $token'};
      }

      final queryParams = <String, dynamic>{};
      if (lat != null) queryParams['lat'] = lat;
      if (lon != null) queryParams['lon'] = lon;

      final res = await _dio.get(
        '${AppConstants.apiBaseUrl}/tasks/nearby',
        queryParameters: queryParams,
        options: options,
      );

      final List data = res.data['tasks'] ?? [];
      return data.map((e) => TaskModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException {
      return _getMockTasks();
    } catch (_) {
      return _getMockTasks();
    }
  }

  Future<void> acceptTask(int id, String? token) async {
    try {
      final options = Options();
      if (token != null) {
        options.headers = {'Authorization': 'Bearer $token'};
      }
      await _dio.post('${AppConstants.apiBaseUrl}/tasks/$id/accept', options: options);
    } catch (_) {
      // Ignore in mock setup
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> completeTask(int id, String? token) async {
    try {
      final options = Options();
      if (token != null) {
        options.headers = {'Authorization': 'Bearer $token'};
      }
      await _dio.post('${AppConstants.apiBaseUrl}/tasks/$id/complete', options: options);
    } catch (_) {
      // Ignore in mock setup
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  List<TaskModel> _getMockTasks() {
    return [
      const TaskModel(
        id: 1,
        type: 'FOOD_DISTRIBUTION',
        title: 'Yardım Dağıtımı',
        assemblyPoint: AssemblyPointModel(
          id: 1,
          name: 'Atatürk İlkokulu',
          lat: 39.6484 + 0.005, // Balıkesir center offset
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
