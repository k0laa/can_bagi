import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String       title;
  final bool         showBack;
  final Widget?      action;
  final Color        backgroundColor;

  const AppTopBar({
    super.key,
    required this.title,
    this.showBack       = false,
    this.action,
    this.backgroundColor = AppColors.background,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary, size: 20),
              onPressed: () => Navigator.of(context).maybePop(),
            )
          : null,
      title: Text(title, style: AppTextStyles.cardTitle),
      actions: action != null ? [action!, const SizedBox(width: 8)] : null,
    );
  }
}
