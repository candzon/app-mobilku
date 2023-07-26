import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/car.dart';

class CarCrudWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: CarList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCarForm(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _navigateToCarForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CarForm(),
      ),
    );
  }
}

class CarList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cars').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          final carDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: carDocs.length,
            itemBuilder: (context, index) {
              final carData = carDocs[index].data() as Map<String, dynamic>;
              final car = Car(
                id: carDocs[index].id,
                color: carData['color'] ?? '',
                brand: carData['brand'] ?? '',
                model: carData['model'] ?? '',
                year: carData['year'] ?? 0,
              );

              return ListTile(
                title: Text(
                    'Color: ${car.color}, Brand: ${car.brand}, Model: ${car.model},  Year: (${car.year})'),
                onTap: () => _navigateToCarForm(context, car),
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
  _CarFormState createState() => _CarFormState();
}

class _CarFormState extends State<CarForm> {
  final _formKey = GlobalKey<FormState>();
  final _colorController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.car != null) {
      _colorController.text = widget.car!.color;
      _brandController.text = widget.car!.brand;
      _modelController.text = widget.car!.model;
      _yearController.text = widget.car!.year.toString();
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
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _colorController,
                  decoration: InputDecoration(labelText: 'Color'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the car color';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _brandController,
                  decoration: InputDecoration(labelText: 'Brand'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the car brand';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _modelController,
                  decoration: InputDecoration(labelText: 'Model'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the car model';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _yearController,
                  decoration: InputDecoration(labelText: 'Year'),
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
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.car !=
                  null) // Only show the Remove button if editing an existing car
                ElevatedButton(
                  onPressed: _removeCar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text('Remove'),
                ),
              ElevatedButton(
                onPressed: _saveCar,
                child: Text(widget.car == null ? 'Add Car' : 'Update Car'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeCar() {
    if (widget.car != null) {
      FirebaseFirestore.instance
          .collection('cars')
          .doc(widget.car!.id)
          .delete();
      Navigator.of(context).pop();
    }
  }

  void _saveCar() {
    if (_formKey.currentState!.validate()) {
      final color = _colorController.text;
      final brand = _brandController.text;
      final model = _modelController.text;
      final year = int.parse(_yearController.text);

      final carData = {
        'color': color,
        'brand': brand,
        'model': model,
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
}
