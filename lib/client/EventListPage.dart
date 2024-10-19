import 'package:Turfease/client/eventdetails.dart'; // Import your event details screen
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final TextStyle titleTextStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: Colors.black,
);

final TextStyle subtitleTextStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: Colors.black54,
);

class EventListPage extends StatelessWidget {
  final String currentUserId;
  final String? adminId;

  const EventListPage({
    Key? key,
    required this.currentUserId,
    this.adminId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events List'),
        backgroundColor: Colors.teal,
      ),
      body: adminId != null
          ? _buildEventsList(context, adminId!)
          : _buildAllAdminsEventsList(context),
    );
  }

  Widget _buildEventsList(BuildContext context, String adminId) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('admins')
          .doc(adminId)
          .collection('events') // Change to 'events' collection
          .snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> eventsSnapshot) {
        if (eventsSnapshot.hasError) {
          return Center(child: Text('Error: ${eventsSnapshot.error}'));
        }

        if (eventsSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final eventsDocs = eventsSnapshot.data?.docs;

        if (eventsDocs == null || eventsDocs.isEmpty) {
          return Center(child: Text('No events found for admin ID: $adminId'));
        }

        return ListView(
          children: eventsDocs.map((eventDoc) {
            return _buildEventCard(context, eventDoc, adminId);
          }).toList(),
        );
      },
    );
  }

  Widget _buildAllAdminsEventsList(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('admins').snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> adminsSnapshot) {
        if (adminsSnapshot.hasError) {
          return Center(child: Text('Error: ${adminsSnapshot.error}'));
        }

        if (adminsSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final adminsDocs = adminsSnapshot.data?.docs;

        if (adminsDocs == null || adminsDocs.isEmpty) {
          return Center(child: Text('No admin IDs found.'));
        }

        return ListView(
          children: adminsDocs.map((adminDoc) {
            String adminId = adminDoc.id;

            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('admins')
                  .doc(adminId)
                  .collection('events') // Change to 'events' collection
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                      eventsSnapshot) {
                if (eventsSnapshot.hasError) {
                  return Center(child: Text('Error: ${eventsSnapshot.error}'));
                }

                if (eventsSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final eventsDocs = eventsSnapshot.data?.docs;

                if (eventsDocs == null || eventsDocs.isEmpty) {
                  return Center();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: eventsDocs.map((eventDoc) {
                    return _buildEventCard(context, eventDoc, adminId);
                  }).toList(),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildEventCard(
      BuildContext context, DocumentSnapshot eventDoc, String adminId) {
    String eventId = eventDoc.id;
    String eventName = eventDoc['name'];
    String eventDate = eventDoc['date'];
    String eventTime = eventDoc['time'];
    String adminName = eventDoc['adminName'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigate to event details page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailsPage(
                currentUserId: currentUserId,
                eventId: eventId,
                adminId: adminId,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 2), // changes position of shadow
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.teal.withOpacity(0.3),
                ),
                child: Icon(Icons.event, color: Colors.teal, size: 28),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eventName,
                      style: titleTextStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            color: Colors.teal, size: 16),
                        SizedBox(width: 4),
                        Text(
                          '$eventDate - $eventTime',
                          style: subtitleTextStyle,
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Admin: $adminName',
                      style: subtitleTextStyle.copyWith(
                        fontWeight: FontWeight.normal,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Event ID: $eventId',
                      style: subtitleTextStyle.copyWith(
                        fontWeight: FontWeight.normal,
                        color: Colors.grey,
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
  }
}
