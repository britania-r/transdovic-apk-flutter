// lib/pages/rutas/ruta_form.dart
import 'package:flutter/material.dart';
import 'package:transdovic_erp/main.dart';

class RutaForm extends StatefulWidget {
  final void Function(Map<String, dynamic> data) onSave;

  const RutaForm({super.key, required this.onSave});

  @override
  State<RutaForm> createState() => _RutaFormState();
}

class _RutaFormState extends State<RutaForm> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedDriverId;
  DateTime? _selectedDate;
  final TextEditingController _dateController = TextEditingController();
  
  List<Map<String, dynamic>> _drivers = [];
  List<Map<String, dynamic>> _ranchers = [];
  bool _isLoading = true;
  
  final List<Map<String, dynamic>> _stops = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    try {
      // CORRECCIÓN: El método correcto es 'inFilter' en lugar de 'in_'
      final driverRes = await supabase
          .from('profiles')
          .select('id, nombres, apellido_paterno')
          .inFilter('cargo', ['Conductor de Carga', 'Conductor de Patio']);
      
      final rancherRes = await supabase.from('ranchers').select('id, commercial_name');

      if (mounted) {
        setState(() {
          _drivers = List<Map<String, dynamic>>.from(driverRes);
          _ranchers = List<Map<String, dynamic>>.from(rancherRes);
          _isLoading = false;
        });
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: ${e.toString()}'), backgroundColor: Colors.red)
        );
      }
    }
  }

  void _addStop() {
    showDialog(
      context: context,
      builder: (context) {
        String? selectedRancherId;
        return AlertDialog(
          title: const Text('Seleccionar Parada'),
          content: DropdownButtonFormField<String>(
            hint: const Text('Seleccione un ganadero'),
            items: _ranchers.map<DropdownMenuItem<String>>((r) => DropdownMenuItem(
              value: r['id'],
              child: Text(r['commercial_name']),
            )).toList(),
            onChanged: (value) => selectedRancherId = value,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (selectedRancherId != null) {
                  final rancher = _ranchers.firstWhere((r) => r['id'] == selectedRancherId);
                  setState(() {
                    _stops.add(rancher);
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Añadir'),
            ),
          ],
        );
      },
    );
  }
  
  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final routeData = {
        'driver_id': _selectedDriverId,
        'route_date': _selectedDate!.toIso8601String(),
      };

      final stopsData = _stops.asMap().entries.map((entry) {
        return {
          'rancher_id': entry.value['id'],
          'stop_order': entry.key + 1,
        };
      }).toList();

      widget.onSave({
        'routeData': routeData,
        'stopsData': stopsData,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedDriverId,
              decoration: const InputDecoration(labelText: 'Conductor'),
              items: _drivers.map<DropdownMenuItem<String>>((d) => DropdownMenuItem(
                value: d['id'],
                child: Text('${d['nombres']} ${d['apellido_paterno']}'.trim()),
              )).toList(),
              onChanged: (value) => setState(() => _selectedDriverId = value),
              validator: (v) => v == null ? 'Seleccione un conductor' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Fecha de la Ruta'),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                if (date != null) {
                  setState(() => _selectedDate = date);
                  _dateController.text = date.toIso8601String().substring(0, 10);
                }
              },
              validator: (v) => v!.isEmpty ? 'Seleccione una fecha' : null,
            ),
            const Divider(height: 32),
            Text('Paradas de la Ruta', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_stops.isEmpty)
              const Text('No hay paradas añadidas.'),
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: _stops.asMap().entries.map((entry) {
                return ListTile(
                  key: ValueKey(entry.key),
                  leading: CircleAvatar(child: Text('${entry.key + 1}')),
                  title: Text(entry.value['commercial_name']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => setState(() => _stops.removeAt(entry.key)),
                  ),
                );
              }).toList(),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = _stops.removeAt(oldIndex);
                  _stops.insert(newIndex, item);
                });
              },
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _addStop,
              icon: const Icon(Icons.add),
              label: const Text('Añadir Parada'),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
                ElevatedButton(onPressed: _saveForm, child: const Text('Guardar Ruta')),
              ],
            )
          ],
        ),
      ),
    );
  }
}