import 'package:Turfease/main/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EventDetailsPage extends StatelessWidget {
  final String eventId;
  final String currentUserId;
  final String adminId;

  EventDetailsPage({
    Key? key,
    required this.eventId,
    required this.currentUserId,
    required this.adminId,
  }) : super(key: key);

  Future<Map<String, dynamic>?> _fetchEventDetails() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final eventDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(adminId)
          .collection('events')
          .doc(eventId)
          .get();

      if (eventDoc.exists) {
        var event = eventDoc.data();
        event!['eventId'] =
            eventDoc.id; // Include the document ID in the event data
        return event;
      }
    }
    return null;
  }

  Future<void> _registerForEvent(
      BuildContext context, Map<String, dynamic> event) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;
      final eventId = event['eventId'];

      // Check if the user has already registered for this event
      final existingRegistrationQuery = await FirebaseFirestore.instance
          .collection('registrations')
          .where('eventId', isEqualTo: eventId)
          .where('bookedBy', isEqualTo: userId)
          .get();

      if (existingRegistrationQuery.docs.isNotEmpty) {
        // User has already registered for this event
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("You have already registered for this event"),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId) // Assuming 'users' collection stores user details
          .get();

      final userName = userDoc.data()?['name'];

      if (userName == null) {
        throw Exception('User name not found');
      }

      // Add registration details to 'registrations' collection
      await FirebaseFirestore.instance.collection('registrations').add({
        'eventName': event['name'],
        'eventDate': event['date'],
        'eventTime': event['time'],
        'bookedBy': userId, // Add user ID who registered
        'adminId': adminId, // Link to the admin who created the event
        'eventId': eventId, // Add event ID for reference
        'userId': currentUserId,
        'bookingfee': event['bookfee'],
        // Add more details as needed
      });

      // Show registration success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Registered for event: ${event['name']}"),
          duration: Duration(seconds: 2),
        ),
      );

      // Additional logic after registration if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
        backgroundColor: primaryColor500,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchEventDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching event details'));
          }

          final event = snapshot.data;
          if (event == null) {
            return Center(child: Text('Event not found'));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: Colors.white,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (event.containsKey('imageUrl'))
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16.0)),
                          image: DecorationImage(
                            image: NetworkImage(event['imageUrl']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event['name'] ?? 'Event Name',
                            style: titleTextStyle.copyWith(fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          _buildDetailRow(
                            icon: Icons.date_range,
                            text: event['date'] ?? 'N/A',
                          ),
                          SizedBox(height: 8),
                          _buildDetailRow(
                            icon: Icons.access_time,
                            text: event['time'] ?? 'N/A',
                          ),
                          SizedBox(height: 8),
                          _buildDetailRow(
                            icon: Icons.money,
                            text: 'Booking Fee: ${event['bookfee'] ?? 'N/A'}',
                          ),
                          SizedBox(height: 8),
                          _buildDetailRow(
                            icon: Icons.monetization_on,
                            text:
                                'Winning Price: ${event['winningprice'] ?? 'N/A'}',
                          ),
                          SizedBox(height: 8),
                          _buildDetailRow(
                            icon: Icons.person,
                            text:
                                'Coordinator: ${event['coordinator'] ?? 'N/A'}',
                          ),
                          SizedBox(height: 16),
                          if (event.containsKey('facilities'))
                            _buildFacilitiesSection(event['facilities']),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _registerForEvent(context, event),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: primaryColor500,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                            ),
                            child: Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: primaryColor500,
        ),
        SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: addressTextStyle.copyWith(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildFacilitiesSection(List<dynamic> facilities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Facilities:',
          style: titleTextStyle.copyWith(fontSize: 16),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: facilities.map((facility) {
            return Chip(
              label: Text(facility['name']),
              avatar: facility['iconPath'] != null
                  ? Image.asset(
                      facility['iconPath'],
                      width: 24,
                      height: 24,
                    )
                  : Icon(Icons.star),
            );
          }).toList(),
        ),
      ],
    );
  }
}
