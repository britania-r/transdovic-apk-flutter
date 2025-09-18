// lib/pages/users_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transdovic_erp/main.dart';
import 'package:transdovic_erp/pages/users/user_form.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});
  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {

  late final Future<List<Map<String, dynamic>>> _initialUsersFuture;

  @override
  void initState() {
    super.initState();
    // Realizamos una carga inicial de los datos para evitar que la pantalla
    // esté vacía mientras se establece la conexión en tiempo real.
    _initialUsersFuture = supabase.from('profiles').select();
  }

  void _showUserFormDialog({Map<String, dynamic>? userData}) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(userData == null ? 'Crear Nuevo Usuario' : 'Editar Usuario'),
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            width: 600,
            child: UserForm(
              initialData: userData,
              onSave: (data) {
                Navigator.of(dialogContext).pop();
                _handleSave(data, userData?['id']);
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSave(Map<String, dynamic> data, String? userId) async {
    try {
      if (userId == null) {
        await supabase.functions.invoke('create-user', body: {
          'email': data['email'],
          'password': data['password'],
          'profileData': data['profileData'],
        });
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario creado con éxito.'), backgroundColor: Colors.green)
        );
      } else {
        await supabase.functions.invoke('update-user', body: {
          'userId': userId,
          'profileData': data['profileData'],
          if (data.containsKey('password')) 'password': data['password'],
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario actualizado con éxito.'), backgroundColor: Colors.green)
        );
      }
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString().contains('"error":"') 
          ? e.toString().split('"error":"')[1].split('"').first
          : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $errorMessage'), backgroundColor: Theme.of(context).colorScheme.error)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _initialUsersFuture,
        builder: (context, futureSnapshot) {
          if (futureSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (futureSnapshot.hasError) {
            return Center(child: Text('Error al cargar datos: ${futureSnapshot.error}'));
          }

          // Una vez cargados los datos iniciales, usamos un Stream para las actualizaciones en tiempo real.
          return StreamBuilder<List<Map<String, dynamic>>>(
            initialData: futureSnapshot.data,
            stream: supabase.from('profiles').stream(primaryKey: ['id']),
            builder: (context, streamSnapshot) {
              final users = streamSnapshot.data ?? [];
              
              return LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 800) { // Breakpoint ajustado
                    return _buildDesktopLayout(users);
                  } else {
                    return _buildMobileLayout(users);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(List<Map<String, dynamic>> users) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Usuarios', style: Theme.of(context).textTheme.headlineSmall),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showUserFormDialog(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Crear Usuario'),
              )
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: double.infinity, // Ocupa todo el ancho disponible
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 24.0,
                    columns: const [
                      DataColumn(label: Text('Nombre Completo')),
                      DataColumn(label: Text('DNI')),
                      DataColumn(label: Text('Cargo')),
                      DataColumn(label: Text('Fecha Nacimiento')),
                      DataColumn(label: Text('Brevete')),
                      DataColumn(label: Text('Acciones')),
                    ],
                    rows: users.map((user) {
                      final fechaNacimiento = user['fecha_nacimiento'] != null
                          ? DateFormat('dd/MM/yyyy').format(DateTime.parse(user['fecha_nacimiento']))
                          : 'N/A';

                      return DataRow(cells: [
                        DataCell(Text('${user['nombres'] ?? ''} ${user['apellido_paterno'] ?? ''}'.trim())),
                        DataCell(Text(user['dni'] ?? 'N/A')),
                        DataCell(Text(user['cargo'] ?? 'N/A')),
                        DataCell(Text(fechaNacimiento)),
                        DataCell(Text(user['brevete'] ?? 'N/A')),
                        DataCell(Row(
                          children: [
                            HoverIconButton(
                              icon: Icons.edit,
                              onPressed: () => _showUserFormDialog(userData: user),
                            ),
                            const SizedBox(width: 8),
                            HoverIconButton(
                              icon: Icons.delete,
                              color: Colors.red.shade400,
                              onPressed: () { /* TODO: Implementar lógica de eliminar */ },
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

  Widget _buildMobileLayout(List<Map<String, dynamic>> users) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserFormDialog(),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              title: Text('${user['nombres'] ?? ''} ${user['apellido_paterno'] ?? ''}'.trim()),
              subtitle: Text(user['cargo'] ?? ''),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                ],
                onSelected: (value) {
                  if (value == 'edit') _showUserFormDialog(userData: user);
                  if (value == 'delete') { /* TODO: Implementar lógica de eliminar */ }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class HoverIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  const HoverIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
  });

  @override
  State<HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<HoverIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = widget.color ?? theme.iconTheme.color;
    final primaryColor = widget.color ?? theme.colorScheme.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _isHovered ? 1.2 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Icon(
            widget.icon,
            color: _isHovered ? primaryColor : iconColor?.withAlpha(178),
            size: 20,
          ),
        ),
      ),
    );
  }
}