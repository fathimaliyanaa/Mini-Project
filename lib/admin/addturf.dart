import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FieldFacility {
  final String name;
  final String imageAsset;

  FieldFacility({
    required this.name,
    required this.imageAsset,
  });
}

class AddTurfPage extends StatefulWidget {
  @override
  _AddTurfPageState createState() => _AddTurfPageState();
}

class _AddTurfPageState extends State<AddTurfPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _openingTimeController = TextEditingController();
  final TextEditingController _closingTimeController = TextEditingController();

  final List<FieldFacility> fieldFacilities = [
    FieldFacility(name: "WiFi", imageAsset: "assets/icons/wifi.png"),
    FieldFacility(name: "Toilet", imageAsset: "assets/icons/toilet.png"),
    FieldFacility(
        name: "Changing Room", imageAsset: "assets/icons/changing_room.png"),
    FieldFacility(name: "Canteen", imageAsset: "assets/icons/canteen.png"),
    FieldFacility(name: "Lockers", imageAsset: "assets/icons/lockers.png"),
    FieldFacility(
        name: "Charging Area", imageAsset: "assets/icons/charging.png"),
  ];

  final Map<String, bool> facilities = {
    'WiFi': false,
    'Toilet': false,
    'Changing Room': false,
    'Canteen': false,
    'Lockers': false,
    'Charging Area': false,
  };

  File? _selectedImage;
  Uint8List? _webImageBytes;
  String? _webImageName;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      if (kIsWeb) {
        final bytes = await pickedImage.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
          _webImageName = pickedImage.name;
        });
      } else {
        setState(() {
          _selectedImage = File(pickedImage.path);
        });
      }
    }
  }

  Future<void> _saveTurfDetails() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final adminId = currentUser.uid;

      final turfQuery = await FirebaseFirestore.instance
          .collection('admins')
          .doc(adminId)
          .collection('turfs')
          .get();
      if (turfQuery.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You can only manage one turf at a time!'),
          ),
        );
      } else {
        List<String> selectedFacilities =
            facilities.entries.where((e) => e.value).map((e) => e.key).toList();

        String? imageUrl;
        if (_selectedImage != null) {
          // Upload image to Firebase Storage
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('turfs')
              .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
          await storageRef.putFile(_selectedImage!);
          imageUrl = await storageRef.getDownloadURL();
        } else if (_webImageBytes != null) {
          // Upload web image to Firebase Storage
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('turfs')
              .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
          await storageRef.putData(_webImageBytes!);
          imageUrl = await storageRef.getDownloadURL();
        } else if (_imageUrlController.text.isNotEmpty) {
          // Use provided image URL
          imageUrl = _imageUrlController.text;
        }

        // Add turf details to Firestore
        await FirebaseFirestore.instance
            .collection('admins')
            .doc(adminId)
            .collection('turfs')
            .add({
          'name': _nameController.text,
          'location': _locationController.text,
          'price': _priceController.text,
          'contact': _contactController.text,
          'opening_time': _openingTimeController.text,
          'closing_time': _closingTimeController.text,
          'facilities': selectedFacilities,
          'imageUrl': imageUrl,
        });

        // Show success message and clear form
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Turf details saved successfully!'),
          ),
        );

        _nameController.clear();
        _locationController.clear();
        _priceController.clear();
        _contactController.clear();
        _openingTimeController.clear();
        _closingTimeController.clear();
        _imageUrlController.clear();
        setState(() {
          facilities.forEach((key, _) {
            facilities[key] = false;
          });
          _selectedImage = null;
          _webImageBytes = null;
          _webImageName = null;
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please sign in first!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Turf'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.teal.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildTextFieldContainer(
                  icon: Icons.grass,
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Turf Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a turf name';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 10),
                _buildTextFieldContainer(
                  icon: Icons.location_on,
                  child: TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(labelText: 'Location'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a location';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 10),
                _buildTextFieldContainer(
                  icon: Icons.attach_money,
                  child: TextFormField(
                    controller: _priceController,
                    decoration:
                        InputDecoration(labelText: 'Price (per hour in ₹)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a price';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 10),
                _buildTextFieldContainer(
                  icon: Icons.phone,
                  child: TextFormField(
                    controller: _contactController,
                    decoration: InputDecoration(labelText: 'Contact Number'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a contact number';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 10),
                _buildTextFieldContainer(
                  icon: Icons.access_time,
                  child: TextFormField(
                    controller: _openingTimeController,
                    decoration: InputDecoration(labelText: 'Opening Time'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter opening time';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 10),
                _buildTextFieldContainer(
                  icon: Icons.access_time_filled,
                  child: TextFormField(
                    controller: _closingTimeController,
                    decoration: InputDecoration(labelText: 'Closing Time'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter closing time';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: _selectedImage == null && _webImageBytes == null
                        ? Center(
                            child: Text(
                              'Tap to pick an image',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : _selectedImage != null
                            ? Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              )
                            : Image.memory(
                                _webImageBytes!,
                                fit: BoxFit.cover,
                              ),
                  ),
                ),
                SizedBox(height: 10),
                _buildTextFieldContainer(
                  icon: Icons.image,
                  child: TextFormField(
                    controller: _imageUrlController,
                    decoration: InputDecoration(labelText: 'Image URL'),
                  ),
                ),
                SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: fieldFacilities.map((facility) {
                    bool isSelected = facilities[facility.name]!;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          facilities[facility.name] = !isSelected;
                        });
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              facility.imageAsset,
                              width: 40,
                              height: 40,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _saveTurfDetails,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.teal,
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                          shadowColor: Colors.black45,
                        ),
                        child: Text(
                          'Save',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldContainer({
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _contactController.dispose();
    _openingTimeController.dispose();
    _closingTimeController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}
