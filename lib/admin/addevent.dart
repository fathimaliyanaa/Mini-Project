import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class AddEventPage extends StatefulWidget {
  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDateController = TextEditingController();
  final TextEditingController _eventTimeController = TextEditingController();
  final TextEditingController _eventBookingFeeController =
      TextEditingController();
  final TextEditingController _eventWinningPriceController =
      TextEditingController();
  final TextEditingController _eventCoordinatorController =
      TextEditingController();

  bool _isLoading = false;

  Future<void> _pickEventDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _eventDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _pickEventTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _eventTimeController.text = pickedTime.format(context);
      });
    }
  }

  Future<void> _saveEventDetails() async {
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

      // Add event details to Firestore
      await FirebaseFirestore.instance
          .collection('admins')
          .doc(adminId)
          .collection('events')
          .add({
        'name': _eventNameController.text,
        'date': _eventDateController.text, // Use formatted date
        'time': _eventTimeController.text,
        'bookfee': _eventBookingFeeController.text,
        'winningprice': _eventWinningPriceController.text,
        'coordinator': _eventCoordinatorController.text,
        'adminName': adminName,
      });

      // Show success message and clear form
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Event details saved successfully!'),
        ),
      );

      _eventNameController.clear();
      _eventDateController.clear();
      _eventTimeController.clear();
      _eventBookingFeeController.clear();
      _eventWinningPriceController.clear();
      _eventCoordinatorController.clear();

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
        title: Text('Add Event'),
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
                  icon: Icons.event,
                  child: TextFormField(
                    controller: _eventNameController,
                    decoration: InputDecoration(labelText: 'Event Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an event name';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 10),
                _buildTextFieldContainer(
                  icon: Icons.date_range,
                  child: TextFormField(
                    controller: _eventDateController,
                    decoration: InputDecoration(labelText: 'Event Date'),
                    onTap: () async {
                      FocusScope.of(context).requestFocus(new FocusNode());
                      await _pickEventDate();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter event date';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 10),
                _buildTextFieldContainer(
                  icon: Icons.access_time,
                  child: TextFormField(
                    controller: _eventTimeController,
                    decoration: InputDecoration(labelText: 'Event Time'),
                    onTap: () async {
                      FocusScope.of(context).requestFocus(new FocusNode());
                      await _pickEventTime();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter event time';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 10),
                _buildTextFieldContainer(
                  icon: Icons.attach_money,
                  child: TextFormField(
                    controller: _eventBookingFeeController,
                    decoration: InputDecoration(labelText: 'Booking Fee'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter booking fee';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 10),
                _buildTextFieldContainer(
                  icon: Icons.monetization_on,
                  child: TextFormField(
                    controller: _eventWinningPriceController,
                    decoration: InputDecoration(labelText: 'Winning Price'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter winning price';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 10),
                _buildTextFieldContainer(
                  icon: Icons.person,
                  child: TextFormField(
                    controller: _eventCoordinatorController,
                    decoration: InputDecoration(labelText: 'Coordinator Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter coordinator name';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _saveEventDetails,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.teal,
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 25),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: Text('Save Event Details'),
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
            Icon(icon, color: Colors.teal),
            SizedBox(width: 10),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDateController.dispose();
    _eventTimeController.dispose();
    _eventBookingFeeController.dispose();
    _eventWinningPriceController.dispose();
    _eventCoordinatorController.dispose();
    super.dispose();
  }
}
