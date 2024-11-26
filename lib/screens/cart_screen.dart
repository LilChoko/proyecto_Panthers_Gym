import 'package:flutter/material.dart';
import 'dart:io'; // Para manejar archivos locales.
import '../database/db_helper.dart';

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final Future<void> Function() onCartUpdated;

  CartScreen({required this.cart, required this.onCartUpdated});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double _calculateTotal() {
    double total = 0.0;
    for (var product in widget.cart) {
      total += product['quantity'] * product['price'];
    }
    return total;
  }

  void _updateQuantity(int index, int change) {
    setState(() {
      widget.cart[index]['quantity'] += change;
      if (widget.cart[index]['quantity'] <= 0) {
        widget.cart.removeAt(index);
      }
    });
    widget.onCartUpdated();
  }

  Widget _buildProductImage(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(imagePath, width: 50, height: 50, fit: BoxFit.cover);
    } else {
      return Image.file(File(imagePath),
          width: 50, height: 50, fit: BoxFit.cover);
    }
  }

  Future<void> _processPayment() async {
    if (widget.cart.isEmpty) {
      _showAlert('Carrito Vacío',
          'Agrega productos al carrito antes de realizar el pago.');
      return;
    }

    final total = _calculateTotal();
    final date = DateTime.now();

    try {
      // Registrar la venta.
      final saleId = await DBHelper.insertSale({
        'total': total,
        'date': date.toIso8601String(),
        'status': 'por cumplir',
      });

      if (saleId == null || saleId <= 0) {
        throw Exception('Error al registrar la venta.');
      }

      // Registrar los detalles de la venta.
      for (var product in widget.cart) {
        // Registrar productos estáticos en la base de datos si no existen.
        if (product.containsKey('static') && product['static'] == true) {
          await DBHelper.insertProduct({
            'name': product['name'],
            'price': product['price'],
            'image': product['image'],
          });
        }

        // Registrar el detalle de la venta.
        await DBHelper.insertSaleDetail({
          'sale_id': saleId,
          'product_id': product['id'],
          'quantity': product['quantity'],
        });
      }

      // Limpiar el carrito.
      setState(() {
        widget.cart.clear();
      });
      await widget.onCartUpdated();

      // Mostrar mensaje de confirmación.
      _showAlert('Pago Realizado', 'Gracias por tu compra.');
    } catch (e, stackTrace) {
      print('Error al procesar el pago: $e');
      print('StackTrace: $stackTrace');

      // Mostrar mensaje de error.
      _showAlert('Error',
          'No se pudo completar el pago. Por favor, intenta nuevamente.');
    }
  }

  Future<void> _cancelPurchase() async {
    if (widget.cart.isEmpty) {
      _showAlert(
          'Carrito Vacío', 'No hay productos en el carrito para cancelar.');
      return;
    }

    final total = _calculateTotal();
    final date = DateTime.now();

    try {
      await DBHelper.insertSale({
        'total': total,
        'date': date.toIso8601String(),
        'status': 'cancelada',
      });

      setState(() {
        widget.cart.clear();
      });
      await widget.onCartUpdated();

      _showAlert('Compra Cancelada',
          'La compra ha sido cancelada y el carrito se ha vaciado.');
    } catch (e, stackTrace) {
      print('Error al cancelar la compra: $e');
      print('StackTrace: $stackTrace');

      _showAlert('Error', 'No se pudo cancelar la compra.');
    }
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Carrito'),
            IconButton(
              icon: Icon(Icons.cancel, color: Colors.red),
              onPressed: _cancelPurchase, // Botón para cancelar compra.
              tooltip: 'Cancelar Compra',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.cart.length,
              itemBuilder: (context, index) {
                final product = widget.cart[index];
                return ListTile(
                  leading: product['image'] != null
                      ? _buildProductImage(product['image'])
                      : Icon(Icons.image, size: 50),
                  title: Text(product['name']),
                  subtitle: Text('Cantidad: ${product['quantity']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () => _updateQuantity(index, -1),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => _updateQuantity(index, 1),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Total: \$${_calculateTotal().toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Regresar a Productos'),
                    ),
                    ElevatedButton(
                      onPressed: _processPayment,
                      child: Text('Pagar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
