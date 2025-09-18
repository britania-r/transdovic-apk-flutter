// lib/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:transdovic_erp/theme/app_theme.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Overview',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create New'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: const [
              _SummaryCard(
                title: 'Running',
                value: '10',
                icon: Icons.play_circle_fill,
                iconColor: AppColors.statusActive,
              ),
              _SummaryCard(
                title: 'Paused',
                value: '2',
                icon: Icons.pause_circle_filled,
                iconColor: AppColors.statusPaused,
              ),
              _SummaryCard(
                title: 'Stopped',
                value: '0',
                icon: Icons.stop_circle,
                iconColor: AppColors.darkTextSecondary,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Active Services',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Card(
            clipBehavior: Clip.antiAlias, // Asegura que el contenido respete los bordes redondeados
            child: SingleChildScrollView(
              // SOLUCIÓN AL OVERFLOW: Envolvemos la tabla en un SingleChildScrollView horizontal.
              // Esto añade una barra de scroll si la tabla es demasiado ancha.
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('No.')),
                  DataColumn(label: Text('Service Name')),
                  DataColumn(label: Text('Location')),
                  DataColumn(label: Text('Status')),
                ],
                rows: [
                  DataRow(cells: [
                    const DataCell(Text('01')),
                    const DataCell(Text('VPS-2 (Windows)')),
                    const DataCell(Text('Frankfurt, Germany')),
                    DataCell(Text('Active', style: const TextStyle(color: AppColors.statusActive))),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('02')),
                    const DataCell(Text('Storage Server')),
                    const DataCell(Text('Yokohama, Japan')),
                    DataCell(Text('Paused', style: const TextStyle(color: AppColors.statusPaused))),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('03')),
                    const DataCell(Text('VPS-1 (Linux)')),
                    const DataCell(Text('Paris, France')),
                    DataCell(Text('Active', style: const TextStyle(color: AppColors.statusActive))),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.darkTextSecondary)),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(width: 40),
            Icon(icon, color: iconColor, size: 32),
          ],
        ),
      ),
    );
  }
}