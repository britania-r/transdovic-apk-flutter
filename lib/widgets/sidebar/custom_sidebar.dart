// lib/widgets/sidebar/custom_sidebar.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:transdovic_erp/main.dart';
import 'package:transdovic_erp/theme/app_theme.dart';
import 'package:transdovic_erp/widgets/responsive_layout.dart'; // Importamos la clase NavigationItem
import 'package:transdovic_erp/widgets/sidebar/sidebar_menu_item.dart';

class CustomSidebar extends StatelessWidget {
  final bool isExtended;
  final int selectedIndex;
  final List<NavigationItem> navigationItems; // Modificado para aceptar la nueva clase
  final Function(int) onDestinationSelected;
  final VoidCallback onToggle;
  final Function(bool) toggleTheme;

  const CustomSidebar({
    super.key,
    required this.isExtended,
    required this.selectedIndex,
    required this.navigationItems,
    required this.onDestinationSelected,
    required this.onToggle,
    required this.toggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          decoration: BoxDecoration(color: theme.colorScheme.surface.withAlpha(200)),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    if (isExtended)
                      const Expanded(
                        child: Text(
                          'Transdovic ERP',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      ),
                    IconButton(
                      icon: Icon(Icons.menu, color: isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      onPressed: onToggle,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Construimos los items del menú a partir de la lista
              ...List.generate(navigationItems.length, (index) {
                final item = navigationItems[index];
                return SidebarMenuItem(
                  icon: item.icon,
                  text: item.label,
                  isExtended: isExtended,
                  isSelected: selectedIndex == index,
                  onTap: () => onDestinationSelected(index),
                );
              }),
              const Spacer(),
              Switch(
                value: isDarkMode,
                onChanged: toggleTheme,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: isExtended
                    ? TextButton.icon(
                        icon: Icon(Icons.logout, color: isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        label: Text('Cerrar Sesión', style: TextStyle(color: isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                        onPressed: () => supabase.auth.signOut(),
                        style: TextButton.styleFrom(padding: const EdgeInsets.all(12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      )
                    : IconButton(
                        icon: Icon(Icons.logout, color: isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        onPressed: () => supabase.auth.signOut(),
                      ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}