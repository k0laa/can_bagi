import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/location_provider.dart';
import '../../../core/providers/websocket_provider.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../auth/widgets/soft_gate_sheet.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import '../widgets/task_card.dart';
import '../widgets/active_task_banner.dart';
import '../widgets/task_detail_sheet.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _taskService = TaskService();
  bool _isLoading = true;
  List<TaskModel> _tasks = [];
  TaskModel? _activeTask;
  String? _error;

  double? _userLat;
  double? _userLon;

  late WebSocketProvider _wsProvider;

  @override
  void initState() {
    super.initState();
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _wsProvider = context.read<WebSocketProvider>();
      _wsProvider.addListener(_onWsUpdate);
    });
  }

  @override
  void dispose() {
    _wsProvider.removeListener(_onWsUpdate);
    super.dispose();
  }

  void _onWsUpdate() {
    if (!_isLoading && mounted) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final auth = context.read<AuthProvider>();

    try {
      final tasks = await _taskService.getMyTasks(auth.token);

      TaskModel? active;
      final openTasks = <TaskModel>[];

      for (final t in tasks) {
        if (t.status == 'assigned' || t.status == 'accepted') {
          active = t;
        } else if (t.status == 'open' || t.status == 'pending') {
          openTasks.add(t);
        }
      }

      if (mounted) {
        setState(() {
          _tasks = openTasks;
          _activeTask = active;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Görevler yüklenemedi';
          _isLoading = false;
        });
      }
    }
  }

  void _onTaskTap(TaskModel task) {
    TaskDetailSheet.show(
      context: context,
      task: task,
      userLat: _userLat,
      userLon: _userLon,
      isTaskActive: _activeTask?.id == task.id,
      hasAnyActiveTask: _activeTask != null && _activeTask?.id != task.id,
      onAccept: () => _acceptTask(task),
      onReject: () => _rejectTask(task),
      onComplete: () => _completeTask(task),
    );
  }

  Future<void> _rejectTask(TaskModel task) async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      SoftGateSheet.show(context);
      return;
    }

    try {
      await _taskService.rejectTask(task.id, auth.token);
      if (!mounted) return;
      AppToast.show(context, 'Görev reddedildi', type: AppToastType.success);

      setState(() {
        _tasks.removeWhere((t) => t.id == task.id);
      });
    } catch (_) {
      if (!mounted) return;
      AppToast.show(context, 'Görev reddedilemedi', type: AppToastType.error);
    }
  }

  Future<void> _acceptTask(TaskModel task) async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      SoftGateSheet.show(context);
      return;
    }

    try {
      await _taskService.acceptTask(task.id, auth.token);
      if (!mounted) return;
      AppToast.show(context, 'Görev kabul edildi', type: AppToastType.success);

      setState(() {
        final accepted = task.copyWith(status: 'assigned');
        _activeTask = accepted;
        _tasks.removeWhere((t) => t.id == task.id);
      });
    } catch (_) {
      if (!mounted) return;
      AppToast.show(context, 'Görev kabul edilemedi', type: AppToastType.error);
    }
  }

  Future<void> _completeTask(TaskModel task) async {
    final auth = context.read<AuthProvider>();
    try {
      await _taskService.completeTask(task.id, auth.token);
      if (!mounted) return;
      AppToast.show(context, 'Görev tamamlandı, teşekkürler!',
          type: AppToastType.success);

      setState(() {
        _activeTask = null;
      });
    } catch (_) {
      if (!mounted) return;
      AppToast.show(context, 'Görev tamamlanamadı', type: AppToastType.error);
    }
  }

  Map<String, List<TaskModel>> _groupTasksByAssemblyPoint() {
    final grouped = <String, List<TaskModel>>{};
    for (final task in _tasks) {
      final name = task.assemblyPoint.name;
      if (!grouped.containsKey(name)) {
        grouped[name] = [];
      }
      grouped[name]!.add(task);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'GÖREVLER'),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.accent));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!,
                style: AppTextStyles.body.copyWith(color: AppColors.danger)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
              child: const Text('Tekrar Dene',
                  style:
                      TextStyle(color: Colors.white, fontFamily: 'Bebas Neue')),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.accent,
      backgroundColor: AppColors.card,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: Text(
              'Yakınındaki toplanma noktalarındaki görevleri görüyorsunuz',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: AppColors.textDisabled,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          if (_activeTask != null)
            ActiveTaskBanner(
              task: _activeTask!,
              onTap: () => _onTaskTap(_activeTask!),
            ),
          if (_tasks.isEmpty && _activeTask == null)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 48),
                child: Text(
                  'Yakında görev bulunamadı',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      color: AppColors.textDisabled),
                ),
              ),
            )
          else
            ..._buildGroupedTasks(),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedTasks() {
    final grouped = _groupTasksByAssemblyPoint();
    final widgets = <Widget>[];

    grouped.forEach((pointName, tasks) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 8),
          child: Text(
            pointName.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Bebas Neue',
              fontSize: 20,
              color: AppColors.accent,
              letterSpacing: 1,
            ),
          ),
        ),
      );

      for (final task in tasks) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TaskCard(
              task: task,
              userLat: _userLat,
              userLon: _userLon,
              onTap: () => _onTaskTap(task),
            ),
          ),
        );
      }
    });

    return widgets;
  }
}
