import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Map<String, dynamic>>> _sales;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  void _loadSales() {
    setState(() {
      _sales = DBHelper.fetchSales();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'por cumplir':
        return Colors.green;
      case 'completada':
        return Colors.grey;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'por cumplir':
        return Icons.pending_actions;
      case 'completada':
        return Icons.check_circle;
      case 'cancelada':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Historial de Ventas')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _sales,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error al cargar el historial de ventas.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay ventas registradas.'));
          } else {
            final sales = snapshot.data!;
            return ListView.builder(
              itemCount: sales.length,
              itemBuilder: (context, index) {
                final sale = sales[index];
                return ListTile(
                  leading: Icon(
                    _getStatusIcon(sale['status']),
                    color: _getStatusColor(sale['status']),
                  ),
                  title: Text(
                    'Venta ${sale['id']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total: \$${sale['total'].toStringAsFixed(2)}'),
                      Text('Fecha: ${sale['date']}'),
                    ],
                  ),
                  trailing: Text(
                    sale['status'],
                    style: TextStyle(
                      color: _getStatusColor(sale['status']),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
