import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'cart_screen.dart';
import '../widgets/product_grid.dart';
import '../database/db_helper.dart';

class ProductSelectionScreen extends StatefulWidget {
  @override
  _ProductSelectionScreenState createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  // Lista estática de productos
  final List<Map<String, dynamic>> staticProducts = [
    {
      'id': 1, // ID único para el producto
      'name': 'Proteina WHEY',
      'price': 1199,
      'image': 'assets/whey_protein.jpg',
    },
    {
      'id': 2,
      'name': 'Proteina Vegana',
      'price': 1299,
      'image': 'assets/vegan_protein.jpg',
    },
    {
      'id': 3,
      'name': 'Proteina Hidrolizada',
      'price': 1399,
      'image': 'assets/hidro_protein.jpg',
    },
    {
      'id': 4,
      'name': 'Creatina',
      'price': 499,
      'image': 'assets/creatina.jpg',
    },
    {
      'id': 5,
      'name': 'BCAA',
      'price': 359,
      'image': 'assets/bcaa.jpg',
    },
    {
      'id': 6,
      'name': 'Omega 3',
      'price': 229,
      'image': 'assets/omega3.jpg',
    },
    {
      'id': 7,
      'name': 'Pre-Entreno',
      'price': 569,
      'image': 'assets/preworkout.jpg',
    },
    {
      'id': 8,
      'name': 'Quemador De Grasa',
      'price': 439,
      'image': 'assets/quemador.jpg',
    },
  ];

  // Lista dinámica de productos desde la base de datos
  List<Map<String, dynamic>> databaseProducts = [];

  // Lista de productos en el carrito
  List<Map<String, dynamic>> cart = [];

  @override
  void initState() {
    super.initState();
    _loadCart();
    _fetchProductsFromDatabase();
  }

  // Cargar productos desde la base de datos
  Future<void> _fetchProductsFromDatabase() async {
    final data = await DBHelper.fetchProducts();
    setState(() {
      databaseProducts = data;
    });
  }

  // Cargar el carrito desde SharedPreferences
  Future<void> _loadCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cartData = prefs.getString('cart');
    if (cartData != null) {
      setState(() {
        cart = List<Map<String, dynamic>>.from(jsonDecode(cartData));
      });
    }
  }

  // Guardar el carrito en SharedPreferences
  Future<void> _saveCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('cart', jsonEncode(cart));
  }

  // Agregar producto al carrito
  void _addToCart(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Agregar al carrito'),
          content: Text('¿Quieres agregar ${product['name']} al carrito?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  final index = cart.indexWhere(
                      (item) => item['id'] == product['id']); // Comparar por ID
                  if (index != -1) {
                    cart[index]['quantity']++;
                  } else {
                    cart.add(
                        {...product, 'quantity': 1}); // Incluir `product_id`
                  }
                });
                _saveCart();
                Navigator.pop(context);
              },
              child: Text('Sí, agregar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Combinar productos estáticos con los productos de la base de datos
    final combinedProducts = [...staticProducts, ...databaseProducts];

    return Scaffold(
      appBar: AppBar(
        title: Text('Productos'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CartScreen(cart: cart, onCartUpdated: _saveCart),
                    ),
                  );
                },
              ),
              if (cart.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.red,
                    child: Text(
                      '${cart.length}',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed:
                _fetchProductsFromDatabase, // Refrescar manualmente los productos dinámicos.
          ),
        ],
      ),
      body: combinedProducts.isEmpty
          ? Center(child: Text('No hay productos disponibles.'))
          : ProductGrid(
              products: combinedProducts, onProductSelected: _addToCart),
    );
  }
}
