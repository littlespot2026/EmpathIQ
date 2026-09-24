import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class RelationshipChipGroup extends StatelessWidget {
  final String selectedRelationship;
  final ValueChanged<String> onSelected;

  const RelationshipChipGroup({
    super.key,
    required this.selectedRelationship,
    required this.onSelected,
  });

  static const List<Map<String, dynamic>> relationships = [
    {'label': '伴侣', 'icon': Icons.favorite_rounded},
    {'label': '职场/主管', 'icon': Icons.business_center_rounded},
    {'label': '朋友', 'icon': Icons.people_alt_rounded},
    {'label': '长辈/父母', 'icon': Icons.home_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: relationships.map((rel) {
        final label = rel['label'] as String;
        final icon = rel['icon'] as IconData;
        final isSelected = selectedRelationship == label;

        return InkWell(
          onTap: () => onSelected(label),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.warmBeige : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.warmBeige : AppColors.borderSubtle,
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.warmBeige.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 15,
                  color: isSelected ? AppColors.background : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.background : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
