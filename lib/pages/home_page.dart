// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú Principal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Cierra la sesión del usuario
              await Supabase.instance.client.auth.signOut();
              // El StreamBuilder en main.dart nos llevará de vuelta al login
            },
          )
        ],
      ),
      body: const Center(
        child: Text('¡Has iniciado sesión! Aquí irán los módulos del ERP.'),
      ),
    );
  }
}