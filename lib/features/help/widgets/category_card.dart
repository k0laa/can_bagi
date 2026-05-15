import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CategoryCard extends StatefulWidget {
  final String emoji;
  final String title;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.onTap,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_)  => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2E45), // AppColors.card matches this usually
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? AppColors.accent : Colors.transparent,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.emoji,
                style: const TextStyle(fontSize: 40),
              ),
              const Spacer(),
              Text(
                widget.title,
                style: const TextStyle(
                  fontFamily: 'Bebas Neue',
                  fontSize: 18,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
