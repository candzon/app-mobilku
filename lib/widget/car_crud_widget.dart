import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/car.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class CarCrudWidget extends StatelessWidget {
  const CarCrudWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
            child: Text(
              'Data Mobil',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: CarList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCarForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToCarForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CarForm(),
      ),
    );
  }
}

class CarList extends StatelessWidget {
  const CarList({super.key});

  ImageProvider _getImageProvider(Car car) {
    if (car.imageUrl != null && car.imageUrl!.isNotEmpty) {
      return NetworkImage(car.imageUrl!);
    } else {
      return const AssetImage('assets/img/image_not_available.jpg');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cars')
            .orderBy('brand', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          final carDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: carDocs.length,
            itemBuilder: (context, index) {
              final carData = carDocs[index].data() as Map<String, dynamic>;
              final car = Car(
                id: carDocs[index].id,
                brand: carData['brand'] ?? '',
                model: carData['model'] ?? '',
                color: carData['color'] ?? '',
                year: carData['year'] ?? 0,
                imageUrl:
                    carData['imageUrl'] ?? '', // Fetch imageUrl from Firestore
              );

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Brand: ${car.brand}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Model: ${car.model}'),
                            Text('Color: ${car.color}'),
                            Text('Year: ${car.year}'),
                          ],
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(12),
                          image: car.imageUrl!.isNotEmpty
                              ? DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(car.imageUrl ?? ''),
                                )
                              : DecorationImage(
                                  fit: BoxFit.cover,
                                  image: _getImageProvider(car)),
                        ),
                      ),
                    ],
                  ),
                  onTap: () => _navigateToCarForm(context, car),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToCarForm(BuildContext context, [Car? car]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CarForm(car: car),
      ),
    );
  }
}

class CarForm extends StatefulWidget {
  final Car? car;

  const CarForm({Key? key, this.car}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CarFormState createState() => _CarFormState();
}

class _CarFormState extends State<CarForm> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  final _yearController = TextEditingController();

  File? _imageFile;

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.car != null) {
      _brandController.text = widget.car!.brand;
      _modelController.text = widget.car!.model;
      _colorController.text = widget.car!.color;
      _yearController.text = widget.car!.year.toString();
    }
  }

  void _removeCar() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Yakin ingin menghapus?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Tidak'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                if (widget.car != null) {
                  FirebaseFirestore.instance
                      .collection('cars')
                      .doc(widget.car!.id)
                      .delete();

                  // Show a snackbar when data is successfully removed
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Data berhasil dihapus"),
                    backgroundColor: Colors.red,
                  ));

                  Navigator.of(context).pop();
                }

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveCar() async {
    if (_formKey.currentState!.validate()) {
      final brand = _brandController.text;
      final model = _modelController.text;
      final color = _colorController.text;
      final year = int.parse(_yearController.text);

      // Upload image to Firebase Storage
      String imageUrl = '';
      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('car_images')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        final uploadTask = storageRef.putFile(_imageFile!);
        final taskSnapshot = await uploadTask;
        imageUrl = await taskSnapshot.ref.getDownloadURL();
      }

      final carData = {
        'brand': brand,
        'model': model,
        'color': color,
        'year': year,
        'imageUrl': imageUrl,
      };

      if (widget.car == null) {
        FirebaseFirestore.instance.collection('cars').add(carData);
      } else {
        FirebaseFirestore.instance
            .collection('cars')
            .doc(widget.car!.id)
            .update(carData);
      }

      // Show a snackbar when data is saved
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Data berhasil disimpan"),
        backgroundColor: Colors.green,
      ));

      Navigator.of(context).pop();
    }
  }

  TextStyle _textStyling() {
    return TextField.materialMisspelledTextStyle.copyWith(
      color: Colors.black,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.5,
      letterSpacing: 0.15,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.car == null ? 'Add Car' : 'Edit Car'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCircularTextFormField(
                  controller: _brandController,
                  labelText: 'Brand',
                  autoFocus: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the car brand';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16), // Jarak ke bawah
                _buildCircularTextFormField(
                  controller: _modelController,
                  labelText: 'Model',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the car model';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16), // Jarak ke bawah
                _buildCircularTextFormField(
                  controller: _colorController,
                  labelText: 'Color',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the car color';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16), // Jarak ke bawah
                _buildCircularTextFormField(
                  controller: _yearController,
                  labelText: 'Year',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the car year';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                if (_imageFile != null)
                  Image.file(
                    _imageFile!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _uploadImage,
                  child: Text('Choose Image'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (widget.car != null)
            FloatingActionButton(
              heroTag: 'deleteCarButton',
              onPressed: _removeCar,
              tooltip: 'Delete Car',
              backgroundColor: Colors.red,
              child: const Icon(Icons.delete),
            ),
          const Padding(padding: EdgeInsets.only(bottom: 10)),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'saveCarButton',
            onPressed: _saveCar,
            tooltip: 'Save Car',
            child: const Icon(Icons.save),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularTextFormField({
    required TextEditingController controller,
    required String labelText,
    bool autoFocus = false,
    TextInputType? keyboardType,
    FormFieldValidator<String>? validator,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        autofocus: autoFocus,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }
}
