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
      appBar: AppBar(
        title: Text('Inventario'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: supplements.isEmpty
            ? Center(
                child: Text(
                  'No hay suplementos registrados.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: supplements.length,
                itemBuilder: (context, index) {
                  final supplement = supplements[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: supplement['image'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(12)),
                                  child: Image.file(
                                    File(supplement['image']),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(Icons.image, size: 50, color: Colors.grey),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                supplement['name'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Precio: \$${supplement['price']}',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _showSupplementForm(supplement: supplement);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _deleteSupplement(supplement['id']),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSupplementForm(),
        child: Icon(Icons.add),
      ),
    );
  }
}
