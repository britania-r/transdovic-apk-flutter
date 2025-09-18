// lib/pages/users/user_form.dart
import 'package:flutter/material.dart';

class UserForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final void Function(Map<String, dynamic> data) onSave;

  const UserForm({super.key, this.initialData, required this.onSave});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombresController;
  late TextEditingController _apellidoPaternoController;
  late TextEditingController _apellidoMaternoController;
  late TextEditingController _dniController;
  late TextEditingController _breveteController;
  late TextEditingController _fechaNacimientoController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  String? _selectedCargo;

  final List<String> _cargos = [
    'Gerente', 'Administrador', 'Conductor de Carga',
    'Asistente Administrativo', 'Asistente de Procesos', 'Conductor de Patio'
  ];

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _nombresController = TextEditingController(text: data?['nombres']);
    _apellidoPaternoController = TextEditingController(text: data?['apellido_paterno']);
    _apellidoMaternoController = TextEditingController(text: data?['apellido_materno']);
    _dniController = TextEditingController(text: data?['dni']);
    _breveteController = TextEditingController(text: data?['brevete']);
    _fechaNacimientoController = TextEditingController(text: data?['fecha_nacimiento']);
    _emailController = TextEditingController(text: data?['email']);
    _passwordController = TextEditingController(); // Siempre empieza vacío
    _selectedCargo = data?['cargo'];
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidoPaternoController.dispose();
    _apellidoMaternoController.dispose();
    _dniController.dispose();
    _breveteController.dispose();
    _fechaNacimientoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      // Creamos el mapa base con los datos del perfil
      final profileData = {
        'nombres': _nombresController.text,
        'apellido_paterno': _apellidoPaternoController.text,
        'apellido_materno': _apellidoMaternoController.text,
        'dni': _dniController.text,
        'brevete': _breveteController.text.isEmpty ? null : _breveteController.text,
        'fecha_nacimiento': _fechaNacimientoController.text,
        'cargo': _selectedCargo,
      };

      // Creamos el mapa de datos final a enviar
      final Map<String, dynamic> finalData = {
        'profileData': profileData,
      };

      // Si estamos editando y se escribió una contraseña, la añadimos
      if (widget.initialData != null && _passwordController.text.isNotEmpty) {
        finalData['password'] = _passwordController.text;
      }

      // Si estamos creando, añadimos email y contraseña
      if (widget.initialData == null) {
        finalData['email'] = _emailController.text;
        finalData['password'] = _passwordController.text;
      }
      
      widget.onSave(finalData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 500;
                return isMobile ? _buildMobileFormFields() : _buildDesktopFormFields();
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveForm,
                  child: const Text('Guardar'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopFormFields() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 3.5,
      children: _buildFormFields(),
    );
  }

  Widget _buildMobileFormFields() {
    return Column(
      children: _buildFormFields()
          .map((field) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: field,
              ))
          .toList(),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      if (widget.initialData == null)
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email'),
          validator: (v) => v!.isEmpty ? 'Requerido' : null,
        ),
      if (widget.initialData == null)
        TextFormField(
          controller: _passwordController,
          decoration: const InputDecoration(labelText: 'Contraseña'),
          obscureText: true,
          validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
        )
      else // Si estamos editando, mostramos un campo opcional
        TextFormField(
          controller: _passwordController,
          decoration: const InputDecoration(labelText: 'Nueva Contraseña', hintText: 'Dejar en blanco para no cambiar'),
          obscureText: true,
          validator: (v) => (v!.isNotEmpty && v.length < 6) ? 'Mínimo 6 caracteres' : null,
        ),
      TextFormField(
        controller: _nombresController,
        decoration: const InputDecoration(labelText: 'Nombres'),
        validator: (v) => v!.isEmpty ? 'Requerido' : null,
      ),
      TextFormField(
        controller: _apellidoPaternoController,
        decoration: const InputDecoration(labelText: 'Apellido Paterno'),
        validator: (v) => v!.isEmpty ? 'Requerido' : null,
      ),
      TextFormField(
        controller: _apellidoMaternoController,
        decoration: const InputDecoration(labelText: 'Apellido Materno'),
        validator: (v) => v!.isEmpty ? 'Requerido' : null,
      ),
      TextFormField(
        controller: _dniController,
        decoration: const InputDecoration(labelText: 'DNI'),
        validator: (v) => v!.isEmpty ? 'Requerido' : null,
      ),
      DropdownButtonFormField<String>(
        value: _selectedCargo,
        items: _cargos.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        onChanged: (v) => setState(() => _selectedCargo = v),
        decoration: const InputDecoration(labelText: 'Cargo'),
        validator: (v) => v == null ? 'Requerido' : null,
      ),
      TextFormField(
        controller: _fechaNacimientoController,
        decoration: const InputDecoration(labelText: 'Fecha de Nacimiento'),
        readOnly: true,
        onTap: () async { /* ... */ },
        validator: (v) => v!.isEmpty ? 'Requerido' : null,
      ),
      TextFormField(
        controller: _breveteController,
        decoration: const InputDecoration(labelText: 'Brevete (Opcional)'),
      ),
    ];
  }
}