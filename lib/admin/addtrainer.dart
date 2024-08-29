import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddtrainerPage extends StatefulWidget {
  @override
  _AddtrainerPageState createState() => _AddtrainerPageState();
}

class _AddtrainerPageState extends State<AddtrainerPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _trainerNameController = TextEditingController();
  final TextEditingController _trainerContactController =
      TextEditingController();
  final TextEditingController _trainerSpecialtyController =
      TextEditingController();
  final TextEditingController _trainerExperienceController =
      TextEditingController();
  final TextEditingController _trainerFeesController = TextEditingController();
  final TextEditingController _trainingStartDateController =
      TextEditingController();
  final TextEditingController _trainingDurationController =
      TextEditingController();

  bool _isLoading = false;

  Future<void> _saveTrainerDetails() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final adminId = currentUser.uid;

      // Retrieve admin name
      final adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(adminId)
          .get();

      final adminName =
          adminDoc.get('name'); // Assuming 'name' is the field for admin name

      // Parse training start date
      DateTime? trainingStartDate = _trainingStartDateController.text.isNotEmpty
          ? DateTime.parse(_trainingStartDateController.text)
          : null;

      // Parse training duration
      int? trainingDuration = _trainingDurationController.text.isNotEmpty
          ? int.tryParse(_trainingDurationController.text)
          : null;

      // Add trainer details to Firestore
      await FirebaseFirestore.instance
          .collection('admins')
          .doc(adminId)
          .collection('trainers')
          .add({
        'trainerName': _trainerNameController.text,
        'trainerContact': _trainerContactController.text,
        'trainerSpecialty': _trainerSpecialtyController.text,
        'trainerExperience': _trainerExperienceController.text,
        'trainerFees': _trainerFeesController.text,
        'trainingStartDate': trainingStartDate,
        'trainingDuration': trainingDuration,
        'adminName': adminName, // Add admin's name here if needed
      });

      // Show success message and clear form
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Trainer details saved successfully!'),
        ),
      );

      _trainerNameController.clear();
      _trainerContactController.clear();
      _trainerSpecialtyController.clear();
      _trainerExperienceController.clear();
      _trainerFeesController.clear();
      _trainingStartDateController.clear();
      _trainingDurationController.clear();

      setState(() {
        _isLoading = false;
      });
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
        title: Text('Add Trainer'),
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
                  icon: Icons.person,
                  child: TextFormField(
                    controller: _trainerNameController,
                    decoration: InputDecoration(labelText: 'Trainer Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter trainer name';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 10),
                _buildTextFieldContainer(
                  icon: Icons.phone,
                  child: TextFormField(
                    controller: _trainerContactController,
                    decoration: InputDecoration(labelText: 'Contact Number'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter contact number';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 10),
                _buildTextFieldContainer(
                  icon: Icons.star,
                  child: TextFormField(
                    controller: _trainerSpecialtyController,
                    decoration: InputDecoration(labelText: 'Trainer Specialty'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter trainer specialty';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 10),
                _buildTextFieldContainer(
                  icon: Icons.timeline,
                  child: TextFormField(
                    controller: _trainerExperienceController,
                    decoration: InputDecoration(labelText: 'Experience'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter experience';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 10),
                _buildTextFieldContainer(
                  icon: Icons.attach_money,
                  child: TextFormField(
                    controller: _trainerFeesController,
                    decoration: InputDecoration(labelText: 'Fees'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter fees';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 10),
                _buildTextFieldContainer(
                  icon: Icons.calendar_today,
                  child: TextFormField(
                    controller: _trainingStartDateController,
                    decoration:
                        InputDecoration(labelText: 'Training Start Date'),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(DateTime.now().year + 5),
                      );
                      if (pickedDate != null) {
                        _trainingStartDateController.text =
                            pickedDate.toString();
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select training start date';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 10),
                _buildTextFieldContainer(
                  icon: Icons.today,
                  child: TextFormField(
                    controller: _trainingDurationController,
                    decoration:
                        InputDecoration(labelText: 'Training Duration (days)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter training duration';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _saveTrainerDetails,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.teal,
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 25),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: Text('Save Trainer Details'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldContainer(
      {required IconData icon, required Widget child}) {
    return Container(
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
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.teal,
            ),
            SizedBox(width: 10),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _trainerNameController.dispose();
    _trainerContactController.dispose();
    _trainerSpecialtyController.dispose();
    _trainerExperienceController.dispose();
    _trainerFeesController.dispose();
    _trainingStartDateController.dispose();
    _trainingDurationController.dispose();
    super.dispose();
  }
}
