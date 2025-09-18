// lib/pages/ganaderos/ganaderos_page.dart
import 'package:flutter/material.dart';
import 'package:transdovic_erp/main.dart';
import 'package:transdovic_erp/pages/ganaderos/ganadero_form.dart';
import 'package:transdovic_erp/pages/users_page.dart';

class GanaderosPage extends StatefulWidget {
  const GanaderosPage({super.key});
  @override
  State<GanaderosPage> createState() => _GanaderosPageState();
}

class _GanaderosPageState extends State<GanaderosPage> {
  // SOLUCIÓN: Los streams no soportan JOINS con 'select'.
  // Escuchamos directamente la tabla 'ranchers'.
  final _stream = supabase.from('ranchers').stream(primaryKey: ['id']).order('commercial_name');
  
  void _showFormDialog({Map<String, dynamic>? ganaderoData}) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(ganaderoData == null ? 'Crear Ganadero' : 'Editar Ganadero'),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
          content: SizedBox(
            width: 700,
            child: GanaderoForm(
              initialData: ganaderoData,
              onSave: (data) {
                Navigator.of(dialogContext).pop();
                _handleSave(data, ganaderoData?['id']);
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSave(Map<String, dynamic> data, String? ganaderoId) async {
    final rancherData = data['rancherData'];
    final contactsData = data['contactsData'] as List;

    try {
      if (ganaderoId == null) {
        final newRancher = await supabase.from('ranchers').insert(rancherData).select().single();
        final newRancherId = newRancher['id'];
        
        if (contactsData.isNotEmpty) {
          final contactsWithId = contactsData.map((contact) => {...contact, 'rancher_id': newRancherId}).toList();
          await supabase.from('rancher_contacts').insert(contactsWithId);
        }
      } else {
        await supabase.from('ranchers').update(rancherData).eq('id', ganaderoId);
        await supabase.from('rancher_contacts').delete().eq('rancher_id', ganaderoId);
        if (contactsData.isNotEmpty) {
          final contactsWithId = contactsData.map((contact) => {...contact, 'rancher_id': ganaderoId}).toList();
          await supabase.from('rancher_contacts').insert(contactsWithId);
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guardado con éxito'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar: ${e.toString()}'), backgroundColor: Colors.red));
      }
    }
  }
  
  Future<void> _handleDelete(String ganaderoId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text('¿Estás seguro de que quieres eliminar este ganadero? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await supabase.from('ranchers').delete().eq('id', ganaderoId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ganadero eliminado'), backgroundColor: Colors.orange));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar: ${e.toString()}'), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final ganaderos = snapshot.data ?? [];
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return _buildDesktopLayout(ganaderos);
              } else {
                return _buildMobileLayout(ganaderos);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(List<Map<String, dynamic>> ganaderos) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Ganaderos', style: Theme.of(context).textTheme.headlineSmall),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showFormDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Crear Ganadero'),
              )
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: double.infinity,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Nombre Comercial')),
                      DataColumn(label: Text('RUC')),
                      DataColumn(label: Text('Observaciones')),
                      DataColumn(label: Text('Acciones')),
                    ],
                    rows: ganaderos.map((ganadero) {
                      return DataRow(cells: [
                        DataCell(Text(ganadero['commercial_name'] ?? '')),
                        DataCell(Text(ganadero['ruc'] ?? '')),
                        // Mostramos las observaciones en lugar de la ciudad, ya que el JOIN no está disponible en el stream.
                        DataCell(Text(ganadero['observations'] ?? 'N/A')), 
                        DataCell(Row(
                          children: [
                            HoverIconButton(
                              icon: Icons.edit,
                              onPressed: () => _showFormDialog(ganaderoData: ganadero),
                            ),
                            const SizedBox(width: 8),
                            HoverIconButton(
                              icon: Icons.delete,
                              color: Colors.red.shade400,
                              onPressed: () => _handleDelete(ganadero['id']),
                            ),
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMobileLayout(List<Map<String, dynamic>> ganaderos) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showFormDialog,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: ganaderos.length,
        itemBuilder: (context, index) {
          final ganadero = ganaderos[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              title: Text(ganadero['commercial_name'] ?? ''),
              subtitle: Text("RUC: ${ganadero['ruc'] ?? 'N/A'}"),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                ],
                onSelected: (value) {
                  if (value == 'edit') _showFormDialog(ganaderoData: ganadero);
                  if (value == 'delete') _handleDelete(ganadero['id']);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}