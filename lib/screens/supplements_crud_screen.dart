import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../database/db_helper.dart';
import 'dart:io';

class SupplementsCrudScreen extends StatefulWidget {
  @override
  _SupplementsCrudScreenState createState() => _SupplementsCrudScreenState();
}

class _SupplementsCrudScreenState extends State<SupplementsCrudScreen> {
  List<Map<String, dynamic>> supplements = [];

  @override
  void initState() {
    super.initState();
    _fetchSupplements();
  }

  Future<void> _fetchSupplements() async {
    final data = await DBHelper.fetchProducts();
    setState(() {
      supplements = data;
    });
  }

  Future<void> _addOrUpdateSupplement(
      {int? id,
      String? name,
      double? price,
      String? image,
      String? reminder}) async {
    final supplement = {
      'name': name,
      'price': price,
      'image': image,
      'reminder': reminder,
    };

    if (id == null) {
      await DBHelper.insertProduct(supplement);
    } else {
      await DBHelper.updateProduct(id, supplement);
    }

    _fetchSupplements();
  }

  Future<void> _deleteSupplement(int id) async {
    await DBHelper.deleteProduct(id);
    _fetchSupplements();
  }

  void _showSupplementForm({Map<String, dynamic>? supplement}) async {
    final nameController = TextEditingController(
        text: supplement != null ? supplement['name'] : '');
    final priceController = TextEditingController(
        text: supplement != null ? supplement['price'].toString() : '');
    String? selectedImage = supplement != null ? supplement['image'] : null;

    Future<void> _pickImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          selectedImage = pickedFile.path;
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              supplement == null ? 'Agregar Suplemento' : 'Editar Suplemento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Precio'),
                ),
                SizedBox(height: 16),
                selectedImage != null
                    ? Image.file(
                        File(selectedImage!),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    : Text('No se ha seleccionado ninguna imagen'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Seleccionar Imagen'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                _addOrUpdateSupplement(
                  id: supplement?['id'],
                  name: nameController.text,
                  price: double.parse(priceController.text),
                  image: selectedImage,
                );
                Navigator.pop(context);
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inventario')),
      body: supplements.isEmpty
          ? Center(child: Text('No hay suplementos registrados.'))
          : ListView.builder(
              itemCount: supplements.length,
              itemBuilder: (context, index) {
                final supplement = supplements[index];
                return ListTile(
                  leading: supplement['image'] != null
                      ? Image.file(File(supplement['image']), width: 50)
                      : Icon(Icons.image, size: 50),
                  title: Text(supplement['name']),
                  subtitle: Text('Precio: \$${supplement['price']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showSupplementForm(supplement: supplement);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteSupplement(supplement['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSupplementForm(),
        child: Icon(Icons.add),
      ),
    );
  }
}
