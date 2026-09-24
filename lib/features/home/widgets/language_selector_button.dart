import 'package:flutter/material.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/theme/app_colors.dart';

class LanguageSelectorButton extends StatelessWidget {
  const LanguageSelectorButton({super.key});

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.language_rounded, color: AppColors.warmBeige, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        tr('language_select'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...AppLocale.supportedLanguages.map((lang) {
                final isSelected = lang.code == AppLocale.instance.currentCode;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      AppLocale.instance.setLanguage(lang.code);
                      Navigator.of(ctx).pop();
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.warmBeige.withValues(alpha: 0.15)
                            : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.warmBeige : AppColors.borderSubtle,
                          width: isSelected ? 1.5 : 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(lang.flag, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 12),
                              Text(
                                lang.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                  color: isSelected ? AppColors.warmBeige : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.warmBeige,
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppLocale.instance,
      builder: (context, _) {
        final current = AppLocale.instance.currentLanguage;
        return InkWell(
          onTap: () => _showLanguageSheet(context),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight, width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(current.flag, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                Text(
                  current.name,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.warmBeige,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 16,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
