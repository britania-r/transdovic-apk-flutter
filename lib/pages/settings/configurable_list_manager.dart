// lib/pages/settings/configurable_list_manager.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:transdovic_erp/main.dart';

// MEJORA: Convertido a StatefulWidget para una mejor gestión del ciclo de vida del stream
class ConfigurableListManager extends StatefulWidget {
  final String title;
  final String tableName;
  final String formHintText;
  final IconData icon;

  const ConfigurableListManager({
    super.key,
    required this.title,
    required this.tableName,
    required this.formHintText,
    required this.icon,
  });

  @override
  State<ConfigurableListManager> createState() => _ConfigurableListManagerState();
}

class _ConfigurableListManagerState extends State<ConfigurableListManager> {
  late final Stream<List<Map<String, dynamic>>> _stream;

  @override
  void initState() {
    super.initState();
    // Definimos el stream una sola vez en el initState
    _stream = supabase
        .from(widget.tableName)
        .stream(primaryKey: ['id'])
        .order('name', ascending: true);
  }

  void _showFormDialog({Map<String, dynamic>? initialData}) {
    final nameController = TextEditingController(text: initialData?['name']);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(initialData == null ? 'Añadir ${widget.title}' : 'Editar ${widget.title}'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              decoration: InputDecoration(hintText: widget.formHintText),
              validator: (value) => (value == null || value.isEmpty) ? 'Este campo es requerido' : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop();
                  _handleSave(nameController.text, initialData?['id']);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  // Las funciones de guardado y eliminado ahora son métodos de la clase State
  Future<void> _handleSave(String name, String? id) async {
    try {
      if (id == null) {
        await supabase.from(widget.tableName).insert({'name': name});
      } else {
        await supabase.from(widget.tableName).update({'name': name}).eq('id', id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleDelete(String id) async {
    try {
      await supabase.from(widget.tableName).delete().eq('id', id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El FAB se integra mejor sin un Scaffold dentro de otro
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _stream, // Usamos el stream definido en el initState
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final items = snapshot.data ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8.0),
                child: ListTile(
                  leading: CircleAvatar(child: Icon(widget.icon, size: 20)),
                  title: Text(item['name']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _showFormDialog(initialData: item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                        onPressed: () => _handleDelete(item['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}