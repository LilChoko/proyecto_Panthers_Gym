import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/product_selection_screen.dart';
import 'screens/pending_sales_screen.dart';
import 'screens/supplements_crud_screen.dart';
import 'screens/history_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestión de Suplementos',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(),
        '/crud': (context) => SupplementsCrudScreen(),
        '/product_selection': (context) => ProductSelectionScreen(),
        '/calendar': (context) => PendingSalesScreen(),
        '/history': (context) =>
            HistoryScreen(), // Ruta para el historial de ventas
      },
    );
  }
}
