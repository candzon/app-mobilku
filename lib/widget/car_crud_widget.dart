import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/car.dart';

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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cars').snapshots(),
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
              );

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Brand: ${car.brand}'),
                      Text('Model: ${car.model}'),
                      Text('Color: ${car.color}'),
                      Text('Year: ${car.year}'),
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

  void _saveCar() {
    if (_formKey.currentState!.validate()) {
      final brand = _brandController.text;
      final model = _modelController.text;
      final color = _colorController.text;
      final year = int.parse(_yearController.text);

      final carData = {
        'brand': brand,
        'model': model,
        'color': color,
        'year': year,
      };

      if (widget.car == null) {
        FirebaseFirestore.instance.collection('cars').add(carData);
      } else {
        FirebaseFirestore.instance
            .collection('cars')
            .doc(widget.car!.id)
            .update(carData);
      }

      Navigator.of(context).pop();
    }
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
                TextFormField(
                  controller: _brandController,
                  decoration: const InputDecoration(labelText: 'Brand'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the car brand';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _modelController,
                  decoration: const InputDecoration(labelText: 'Model'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the car model';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _colorController,
                  decoration: const InputDecoration(labelText: 'Color'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the car color';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _yearController,
                  decoration: const InputDecoration(labelText: 'Year'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the car year';
                    }
                    return null;
                  },
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
}
