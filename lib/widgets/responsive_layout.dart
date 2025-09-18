// lib/widgets/responsive_layout.dart
import 'package:flutter/material.dart';
import 'package:transdovic_erp/main.dart';
import 'package:transdovic_erp/pages/dashboard_page.dart';
import 'package:transdovic_erp/pages/providers_page.dart';
import 'package:transdovic_erp/pages/settings_page.dart';
import 'package:transdovic_erp/pages/users_page.dart';
import 'package:transdovic_erp/pages/rutas_page.dart';
import 'package:transdovic_erp/pages/ganaderos_page.dart';
import 'package:transdovic_erp/theme/app_theme.dart';
import 'package:transdovic_erp/widgets/sidebar/custom_sidebar.dart';

class ResponsiveLayout extends StatefulWidget {
  final Function(bool) toggleTheme;
  const ResponsiveLayout({super.key, required this.toggleTheme});

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

// Clase auxiliar para definir los items de navegación y evitar código duplicado
class NavigationItem {
  final Widget page;
  final IconData icon;
  final String label;

  NavigationItem({required this.page, required this.icon, required this.label});
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  int _selectedIndex = 0;
  bool _isExtended = true;
  String? _userRole;

  // Usamos un `late final` para asegurar que se inicialice una sola vez.
  late final List<NavigationItem> _navigationItems;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _userRole = supabase.auth.currentUser?.appMetadata?['user_role'];
    _buildNavigation();
  }

  void _buildNavigation() {
    final bool isAdmin = _userRole == 'Gerente' || _userRole == 'Administrador';

    _navigationItems = [
      NavigationItem(page: const DashboardPage(), icon: Icons.dashboard_rounded, label: 'Dashboard'),
      if (isAdmin)
        NavigationItem(page: const UsersPage(), icon: Icons.people_rounded, label: 'Usuarios'),
      NavigationItem(page: const GanaderosPage(), icon: Icons.agriculture_rounded, label: 'Ganaderos'),
      NavigationItem(page: const RutasPage(), icon: Icons.route, label: 'Rutas'),
      NavigationItem(page: const ProvidersPage(), icon: Icons.store_rounded, label: 'Proveedores'),
      NavigationItem(page: const SettingsPage(), icon: Icons.settings_rounded, label: 'Configuraciones'),
    ];

    _pages = _navigationItems.map((item) => item.page).toList();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return buildWebLayout();
          } else {
            return buildMobileLayout();
          }
        },
      ),
    );
  }

  Widget buildWebLayout() {
    final theme = Theme.of(context);
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: _isExtended ? 220 : 80,
          child: CustomSidebar(
            isExtended: _isExtended,
            selectedIndex: _selectedIndex,
            navigationItems: _navigationItems,
            onDestinationSelected: _onItemTapped,
            onToggle: () => setState(() => _isExtended = !_isExtended),
            toggleTheme: widget.toggleTheme,
          ),
        ),
        VerticalDivider(
          thickness: 1,
          width: 1,
          color: theme.brightness == Brightness.dark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        Expanded(
          child: _pages.elementAt(_selectedIndex),
        ),
      ],
    );
  }

  Widget buildMobileLayout() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transdovic ERP'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 1,
        actions: [
          Switch(value: isDarkMode, onChanged: widget.toggleTheme),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => supabase.auth.signOut()),
        ],
      ),
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: _navigationItems.map((item) => BottomNavigationBarItem(
          icon: Icon(item.icon),
          label: item.label,
        )).toList(),
      ),
    );
  }
}