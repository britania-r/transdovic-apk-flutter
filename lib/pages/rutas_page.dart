// lib/pages/rutas/rutas_page.dart
import 'package:flutter/material.dart';
import 'package:transdovic_erp/main.dart';
import 'package:transdovic_erp/pages/rutas/ruta_detail_page.dart';
import 'package:transdovic_erp/pages/rutas/ruta_form.dart';

class RutasPage extends StatefulWidget {
  const RutasPage({super.key});

  @override
  State<RutasPage> createState() => _RutasPageState();
}

class _RutasPageState extends State<RutasPage> {
  final _stream = supabase.from('routes').stream(primaryKey: ['id']).order('route_date', ascending: false);

  // La función de guardado ahora se maneja directamente en el diálogo
  void _showFormDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Nueva Ruta'),
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: 600,
          child: RutaForm(
            onSave: (data) async {
              Navigator.of(context).pop(); // Cerramos el diálogo primero
              try {
                // La lógica de guardado se ejecuta aquí
                await supabase.rpc('create_route_with_stops', params: {
                  'route_data': data['routeData'],
                  'stops_data': data['stopsData'],
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ruta guardada con éxito'), backgroundColor: Colors.green));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar la ruta: ${e.toString()}'), backgroundColor: Colors.red));
                }
              }
            },
          ),
        ),
      ),
    );
  }

  void _navigateToRouteDetail(String routeId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RutaDetailPage(routeId: routeId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final routes = snapshot.data ?? [];
        
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              return _buildDesktopLayout(routes);
            } else {
              return _buildMobileLayout(routes);
            }
          },
        );
      },
    );
  }

  Widget _buildDesktopLayout(List<Map<String, dynamic>> routes) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Gestión de Rutas', style: Theme.of(context).textTheme.headlineSmall),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showFormDialog,
                icon: const Icon(Icons.add),
                label: const Text('Crear Ruta'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: routes.length,
              itemBuilder: (context, index) {
                final route = routes[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.route),
                    title: Text('Ruta del ${route['route_date']}'),
                    subtitle: Text('Estado: ${route['status']}'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _navigateToRouteDetail(route['id']),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMobileLayout(List<Map<String, dynamic>> routes) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Rutas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showFormDialog,
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: routes.length,
        itemBuilder: (context, index) {
          final route = routes[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.route),
              title: Text('Ruta del ${route['route_date']}'),
              subtitle: Text('Estado: ${route['status']}'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _navigateToRouteDetail(route['id']),
            ),
          );
        },
      ),
    );
  }
}