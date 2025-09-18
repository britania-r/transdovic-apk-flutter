// lib/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:transdovic_erp/pages/settings/configurable_list_manager.dart';
import 'package:transdovic_erp/theme/app_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // SOLUCIÓN: Ya no usamos un Padding principal. Construimos la UI a ancho completo.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // MEJORA: Añadimos padding solo a la cabecera para que no esté pegada al borde.
        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
          child: Text(
            'Configuraciones Generales',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),

        // MEJORA: TabBar más compacto y estilizado.
        // Usamos LayoutBuilder para decidir si debe ser scrollable.
        LayoutBuilder(
          builder: (context, constraints) {
            // Si la pantalla es estrecha (típico de un móvil), hacemos el TabBar scrollable.
            final isMobile = constraints.maxWidth < 600;

            return TabBar(
              controller: _tabController,
              isScrollable: isMobile, // SOLUCIÓN AL OVERFLOW MÓVIL
              indicatorColor: AppColors.primaryBlue,
              labelColor: AppColors.primaryBlue,
              unselectedLabelColor: isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              indicatorSize: TabBarIndicatorSize.tab,
              // Añadimos padding a las pestañas para que no se sientan apretadas
              labelPadding: const EdgeInsets.symmetric(horizontal: 24.0),
              tabs: const [
                Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.category_outlined, size: 15), SizedBox(width: 8), Text('Categorías')])),
                Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.location_city_outlined, size: 15), SizedBox(width: 8), Text('Ciudades')])),
                Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.straighten_outlined, size: 15), SizedBox(width: 8), Text('U. de Medida')])),
              ],
            );
          },
        ),
        
        const Divider(height: 1),

        // El TabBarView ahora ocupa todo el espacio restante.
        // El padding interno lo controla el widget ConfigurableListManager.
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              ConfigurableListManager(
                title: 'Categoría',
                tableName: 'categories',
                formHintText: 'Nombre de la categoría',
                icon: Icons.category,
              ),
              ConfigurableListManager(
                title: 'Ciudad',
                tableName: 'cities',
                formHintText: 'Nombre de la ciudad',
                icon: Icons.location_city,
              ),
              ConfigurableListManager(
                title: 'Unidad de Medida',
                tableName: 'units',
                formHintText: 'Nombre de la unidad (ej. KG, LT, M3)',
                icon: Icons.straighten,
              ),
            ],
          ),
        ),
      ],
    );
  }
}