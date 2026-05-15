import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/connection_status.dart';
import '../../../shared/widgets/location_permission.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'ACİL YARDIM'),
      body: Column(
        children: [
          const ConnectionStatus(),
          const LocationPermissionWidget(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SOS placeholder — Faz 2'de gerçek buton gelecek
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.danger,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.danger.withValues(alpha: 0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'ACİL\nSOS',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.hero.copyWith(
                        fontSize: 42,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Enkaz altındaysanız bu butona\n3 saniye basın',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'FAZ 2\'de aktif olacak',
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
