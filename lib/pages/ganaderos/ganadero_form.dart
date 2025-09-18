// lib/pages/ganaderos/ganadero_form.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transdovic_erp/main.dart';
import 'package:transdovic_erp/pages/ganaderos/map_picker_page.dart';

class GanaderoForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final void Function(Map<String, dynamic> data) onSave;

  const GanaderoForm({super.key, this.initialData, required this.onSave});

  @override
  State<GanaderoForm> createState() => _GanaderoFormState();
}

class _GanaderoFormState extends State<GanaderoForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _rucController;
  late TextEditingController _observationsController;
  
  List<Map<String, dynamic>> _cities = [];
  bool _isLoadingCities = true;
  String? _selectedCityId;

  final List<Map<String, TextEditingController>> _contacts = [];
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _nameController = TextEditingController(text: data?['commercial_name']);
    _rucController = TextEditingController(text: data?['ruc']);
    _observationsController = TextEditingController(text: data?['observations']);
    _selectedCityId = data?['city_id'];
    
    if (data != null && data['latitude'] != null && data['longitude'] != null) {
      _selectedLocation = LatLng(data['latitude'], data['longitude']);
    }

    _fetchCities();
    if (widget.initialData != null) {
      _fetchInitialContacts();
    } else {
      _addContact();
    }
  }
  
  Future<void> _fetchCities() async {
    try {
      final data = await supabase.from('cities').select();
      if (mounted) {
        setState(() {
          _cities = List<Map<String, dynamic>>.from(data);
          _isLoadingCities = false;
        });
      }
    } catch (e) { /* ... */ }
  }

  Future<void> _fetchInitialContacts() async {
    try {
      final data = await supabase.from('rancher_contacts').select().eq('rancher_id', widget.initialData!['id']);
      if (mounted) {
        for (var contact in data) {
          _contacts.add({
            'name': TextEditingController(text: contact['name']),
            'phone': TextEditingController(text: contact['phone_number']),
          });
        }
        setState(() {});
      }
    } catch (e) { /* ... */ }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rucController.dispose();
    _observationsController.dispose();
    for (var contact in _contacts) {
      contact['name']!.dispose();
      contact['phone']!.dispose();
    }
    super.dispose();
  }
  
  void _addContact() {
    if (_contacts.length < 5) {
      setState(() {
        _contacts.add({
          'name': TextEditingController(),
          'phone': TextEditingController(),
        });
      });
    }
  }

  void _removeContact(int index) {
    _contacts[index]['name']!.dispose();
    _contacts[index]['phone']!.dispose();
    setState(() {
      _contacts.removeAt(index);
    });
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (context) => MapPickerPage(initialLocation: _selectedLocation),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final rancherData = {
        'commercial_name': _nameController.text,
        'ruc': _rucController.text,
        'city_id': _selectedCityId,
        'observations': _observationsController.text.isEmpty ? null : _observationsController.text,
        'latitude': _selectedLocation?.latitude,
        'longitude': _selectedLocation?.longitude,
      };

      final contactsData = _contacts
          .where((c) => c['name']!.text.isNotEmpty && c['phone']!.text.isNotEmpty)
          .map((c) => {'name': c['name']!.text, 'phone_number': c['phone']!.text}).toList();

      widget.onSave({
        'rancherData': rancherData,
        'contactsData': contactsData,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre Comercial'),
              validator: (v) => v!.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _rucController,
              decoration: const InputDecoration(labelText: 'RUC'),
              validator: (v) => v!.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCityId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Ciudad',
                prefixIcon: _isLoadingCities ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3)),
                ) : null,
              ),
              items: _cities.map((city) {
                return DropdownMenuItem<String>(
                  value: city['id'],
                  child: Text(city['name']),
                );
              }).toList(),
              onChanged: _isLoadingCities ? null : (value) => setState(() => _selectedCityId = value),
              validator: (v) => v == null ? 'Seleccione una ciudad' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _observationsController,
              decoration: const InputDecoration(labelText: 'Observaciones'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              readOnly: true,
              key: ValueKey(_selectedLocation),
              initialValue: _selectedLocation == null ? 'No seleccionada' : 'Lat: ${_selectedLocation!.latitude.toStringAsFixed(4)}, Lon: ${_selectedLocation!.longitude.toStringAsFixed(4)}',
              decoration: InputDecoration(
                labelText: 'Ubicación',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.map),
                  onPressed: _openMapPicker,
                ),
              ),
            ),
            const Divider(height: 32),
            Text('Encargados', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_contacts.isEmpty)
              const Text('No hay encargados añadidos.', style: TextStyle(color: Colors.grey)),
            ..._contacts.asMap().entries.map((entry) {
              int index = entry.key;
              var contact = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(child: TextFormField(controller: contact['name'], decoration: const InputDecoration(labelText: 'Nombre'))),
                    const SizedBox(width: 8),
                    Expanded(child: TextFormField(controller: contact['phone'], decoration: const InputDecoration(labelText: 'Teléfono'))),
                    IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: () => _removeContact(index)),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            if (_contacts.length < 5)
              TextButton.icon(
                onPressed: _addContact,
                icon: const Icon(Icons.add),
                label: const Text('Añadir Encargado'),
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _saveForm, child: const Text('Guardar')),
              ],
            )
          ],
        ),
      ),
    );
  }
}