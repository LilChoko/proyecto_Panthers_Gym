import 'package:flutter/material.dart';
import 'dart:io';
import '../database/db_helper.dart';

// Lista de productos estáticos
final List<Map<String, dynamic>> staticProducts = [
  {
    'id': 1,
    'name': 'Proteina WHEY',
    'price': 1199,
    'image': 'assets/whey_protein.jpg'
  },
  {
    'id': 2,
    'name': 'Proteina Vegana',
    'price': 1299,
    'image': 'assets/vegan_protein.jpg'
  },
  {
    'id': 3,
    'name': 'Proteina Hidrolizada',
    'price': 1399,
    'image': 'assets/hidro_protein.jpg'
  },
  {'id': 4, 'name': 'Creatina', 'price': 499, 'image': 'assets/creatina.jpg'},
  {'id': 5, 'name': 'BCAA', 'price': 359, 'image': 'assets/bcaa.jpg'},
  {'id': 6, 'name': 'Omega 3', 'price': 229, 'image': 'assets/omega3.jpg'},
  {
    'id': 7,
    'name': 'Pre-Entreno',
    'price': 569,
    'image': 'assets/preworkout.jpg'
  },
  {
    'id': 8,
    'name': 'Quemador De Grasa',
    'price': 439,
    'image': 'assets/quemador.jpg'
  },
];

void showSalesModal(BuildContext context, List<Map<String, dynamic>> events,
    Function onUpdate) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) {
          return ListView.builder(
            controller: scrollController,
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ExpansionTile(
                leading: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _getDotColor(event['status']),
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(
                  event['title'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('\$${event['total'].toStringAsFixed(2)}'),
                trailing: event['status'] == 'por cumplir'
                    ? IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        tooltip: 'Marcar como completada',
                        onPressed: () async {
                          await DBHelper.updateSaleStatus(
                              event['id'], 'completada');
                          onUpdate();
                          Navigator.pop(context);
                        },
                      )
                    : null,
                children: event['status'] != 'cancelada'
                    ? [
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: _fetchCombinedSaleDetails(event['id']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                    'Error al cargar los detalles de la venta.'),
                              );
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('No hay detalles para esta venta.'),
                              );
                            } else {
                              final saleDetails = snapshot.data!;
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: saleDetails.length,
                                itemBuilder: (context, detailIndex) {
                                  final detail = saleDetails[detailIndex];
                                  return ListTile(
                                    leading: detail['image'] != null
                                        ? _buildProductImage(detail['image'])
                                        : Icon(Icons.image, size: 50),
                                    title: Text(detail['name']),
                                    subtitle:
                                        Text('Cantidad: ${detail['quantity']}'),
                                    trailing: Text(
                                      '\$${(detail['price'] * detail['quantity']).toStringAsFixed(2)}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ]
                    : [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Esta venta fue cancelada.',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
              );
            },
          );
        },
      );
    },
  );
}

/// Función para obtener y combinar los detalles de la venta
Future<List<Map<String, dynamic>>> _fetchCombinedSaleDetails(int saleId) async {
  // Detalles dinámicos de la base de datos
  final dynamicDetails = await DBHelper.fetchSaleDetails(saleId);

  // Combinación con productos estáticos
  final combinedDetails = dynamicDetails.map((detail) {
    // Buscar si el producto estático existe en la lista local
    final staticProduct = staticProducts.firstWhere(
      (product) => product['id'] == detail['product_id'],
      orElse: () => {}, // Si no existe, devolver null
    );

    return {
      'product_id': detail['product_id'],
      'name': staticProduct?['name'] ?? detail['name'], // Preferir estático
      'image': staticProduct?['image'] ?? detail['image'],
      'price': staticProduct?['price'] ?? detail['price'],
      'quantity': detail['quantity'],
    };
  }).toList();

  return combinedDetails;
}

Color _getDotColor(String status) {
  switch (status) {
    case 'por cumplir':
      return Colors.green;
    case 'cancelada':
      return Colors.red;
    case 'completada':
      return Colors.grey;
    default:
      return Colors.grey;
  }
}

Widget _buildProductImage(String imagePath) {
  try {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.broken_image, size: 50);
        },
      );
    } else {
      return Image.file(
        File(imagePath),
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.broken_image, size: 50);
        },
      );
    }
  } catch (e) {
    return Icon(Icons.broken_image, size: 50);
  }
}
