import 'package:flutter/material.dart';
import 'package:farmer_procurement_app/core/constants/app_colors.dart';
import 'package:farmer_procurement_app/data/procurement_repository.dart';

class LanguageToggleButton extends StatelessWidget {
  final bool isLight;
  const LanguageToggleButton({super.key, this.isLight = true});

  @override
  Widget build(BuildContext context) {
    final repo = ProcurementRepository();
    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        final isTamil = repo.isTamil;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => repo.toggleLanguage(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isLight
                    ? Colors.white.withValues(alpha: 0.18)
                    : AppColors.primaryLight.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isLight
                      ? Colors.white.withValues(alpha: 0.5)
                      : AppColors.primary,
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.translate_rounded,
                    size: 18,
                    color: isLight ? Colors.white : AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isTamil ? 'தமிழ்' : 'English',
                    style: TextStyle(
                      color: isLight ? Colors.white : AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
