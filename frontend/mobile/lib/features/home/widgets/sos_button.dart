import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/connection_provider.dart';
import '../../../core/providers/location_provider.dart';
import '../services/sos_service.dart';
import 'countdown_ring.dart';

class SosButton extends StatefulWidget {
  final void Function(SosResponse)  onSuccess;
  final void Function(Exception)    onError;

  const SosButton({
    super.key,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton>
    with SingleTickerProviderStateMixin {
  static const double _buttonSize    = 200;
  static const int    _holdSeconds   = 3;

  late AnimationController _ctrl;
  bool _isPressing  = false;
  bool _isSending   = false;
  int  _countdown   = _holdSeconds;

  final SosService _sosService = SosService();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(seconds: _holdSeconds),
    )..addListener(_onTick)
     ..addStatusListener(_onStatus);
  }

  void _onTick() {
    final newCount = _holdSeconds - (_ctrl.value * _holdSeconds).floor();
    if (newCount != _countdown) {
      setState(() => _countdown = newCount.clamp(1, _holdSeconds));
      HapticFeedback.heavyImpact();
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _triggerSOS();
    }
  }

  void _startPress() {
    if (_isSending) return;
    setState(() {
      _isPressing = true;
      _countdown  = _holdSeconds;
    });
    _ctrl.forward(from: 0);
    HapticFeedback.mediumImpact();
  }

  void _cancelPress() {
    if (!_isPressing) return;
    _ctrl.stop();
    _ctrl.reset();
    setState(() {
      _isPressing = false;
      _countdown  = _holdSeconds;
    });
    // Zil sesini durdur
    _sosService.stopAlertSound();
  }

  Future<void> _triggerSOS() async {
    if (_isSending) return;
    setState(() => _isSending = true);
    _ctrl.stop();

    final connProvider = context.read<ConnectionProvider>();
    final locProvider  = context.read<LocationProvider>();

    double? lat;
    double? lon;

    // Konum izni kontrolü
    if (!locProvider.hasPermission) {
      final granted = await _showLocationDialog();
      if (!mounted) return;
      if (granted) {
        final pos = await locProvider.getCurrentPosition();
        lat = pos?.latitude;
        lon = pos?.longitude;
      }
      // granted == false → lat/lon null kalır (izinsiz gönder)
    } else {
      final pos = await locProvider.getCurrentPosition();
      lat = pos?.latitude;
      lon = pos?.longitude;
    }

    try {
      final response = await _sosService.sendSOS(
        connectionType: connProvider.type,
        lat: lat,
        lon: lon,
      );
      if (mounted) widget.onSuccess(response);
    } on NoConnectionException catch (e) {
      if (mounted) widget.onError(e);
    } catch (e) {
      if (mounted) widget.onError(Exception(e.toString()));
    } finally {
      if (mounted) {
        setState(() {
          _isSending  = false;
          _isPressing = false;
          _countdown  = _holdSeconds;
        });
        _ctrl.reset();
      }
    }
  }

  Future<bool> _showLocationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (localCtx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('📍 Konum İzni', style: AppTextStyles.cardTitle),
        content: Text(
          'Konumunuz olmadan kurtarma ekipleri sizi bulamaz. '
          'İzin vermek ister misiniz?',
          style: AppTextStyles.caption,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(localCtx, false),
            child: Text(
              'İzinsiz Gönder',
              style: AppTextStyles.caption.copyWith(color: AppColors.warning),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final loc = context.read<LocationProvider>();
              await loc.requestPermission();
              final hasPermission = loc.hasPermission;
              if (localCtx.mounted) Navigator.pop(localCtx, hasPermission);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('İzin Ver', style: AppTextStyles.buttonText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  void dispose() {
    _ctrl
      ..removeListener(_onTick)
      ..removeStatusListener(_onStatus)
      ..dispose();
    // Kaynakları temizle
    _sosService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locProvider = context.watch<LocationProvider>();

    return SizedBox(
      width:  _buttonSize * 1.8,
      height: _buttonSize * 1.8,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Halka animasyonu
          if (_isPressing)
            CountdownRing(
              progress:   _ctrl,
              countdown:  _countdown,
              buttonSize: _buttonSize,
            ),

          // Ana SOS butonu
          GestureDetector(
            onLongPressStart: (_) => _startPress(),
            onLongPressEnd:   (_) => _cancelPress(),
            onLongPressCancel:    _cancelPress,
            child: AnimatedScale(
              scale:    _isPressing ? 0.95 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: Container(
                width:  _buttonSize,
                height: _buttonSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isSending ? AppColors.textDisabled : AppColors.danger,
                  boxShadow: [
                    BoxShadow(
                      color:       AppColors.danger.withValues(alpha: 0.45),
                      blurRadius:  _isPressing ? 40 : 25,
                      spreadRadius: _isPressing ? 8 : 3,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: _isSending
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!locProvider.hasPermission)
                            const Text('⚠️', style: TextStyle(fontSize: 18)),
                          Text(
                            'ACİL\nSOS',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.hero.copyWith(
                              fontSize: 44,
                              height:   1.0,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
