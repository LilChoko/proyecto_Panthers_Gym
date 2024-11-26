import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Base De Datos'),
        backgroundColor: Colors.grey.shade300, // Fondo neutro para el AppBar
        elevation: 0, // Quitar sombra
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.grey.shade200
            ], // Degradado blanco a gris claro
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Gestión Del Inventario',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Texto en negro
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            _buildOptionCard(
              context,
              icon: Icons.inventory_2,
              text: 'Gestión de Suplementos',
              route: '/crud',
            ),
            SizedBox(height: 12),
            _buildOptionCard(
              context,
              icon: Icons.shopping_cart,
              text: 'Realizar una Venta',
              route: '/product_selection',
            ),
            SizedBox(height: 12),
            _buildOptionCard(
              context,
              icon: Icons.calendar_today,
              text: 'Calendario de Ventas',
              route: '/calendar',
            ),
            SizedBox(height: 12),
            _buildOptionCard(
              context,
              icon: Icons.history,
              text: 'Historial de Ventas',
              route: '/history',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String text,
    required String route,
  }) {
    return Card(
      elevation: 3, // Sombra leve
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.black), // Icono negro
        title: Text(
          text,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          Navigator.pushNamed(context, route);
        },
      ),
    );
  }
}
