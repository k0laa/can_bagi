import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/connection_status.dart';
import '../../../shared/widgets/location_permission.dart';
import '../widgets/sos_button.dart';


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
                  SosButton(
                    onSuccess: (response) {
                      // Extra arg ile confirmation'a git
                      context.go('/confirmation', extra: response);
                    },
                    onError: (error) {
                      context.go('/sos-error', extra: error);
                    },
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'Enkaz altındaysanız bu butona\n3 saniye basın',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption,
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
