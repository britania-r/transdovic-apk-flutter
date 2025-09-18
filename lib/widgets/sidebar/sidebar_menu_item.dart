// lib/widgets/sidebar/sidebar_menu_item.dart
import 'package:flutter/material.dart';
import 'package:transdovic_erp/theme/app_theme.dart';

class SidebarMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isExtended;
  final bool isSelected;
  final VoidCallback onTap;

  const SidebarMenuItem({
    super.key,
    required this.icon,
    required this.text,
    required this.isExtended,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final color = isSelected
        ? AppColors.primaryBlue
        : (isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Material(
        color: isSelected ? AppColors.primaryBlue.withAlpha(50) : Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.0),
          hoverColor: AppColors.primaryBlue.withAlpha(30),
          splashColor: AppColors.primaryBlue.withAlpha(40),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                Icon(icon, color: color),
                if (isExtended) ...[
                  const SizedBox(width: 16),
                  Flexible(
                    child: Text(
                      text,
                      style: TextStyle(color: color, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}