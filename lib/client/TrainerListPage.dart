import 'package:Turfease/client/trainingdetails.dart';
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

class TrainerListPage extends StatelessWidget {
  final String currentUserId;
  final String? adminId;

  const TrainerListPage({
    Key? key,
    required this.currentUserId,
    this.adminId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trainers List'),
        backgroundColor: Colors.teal,
      ),
      body: adminId != null
          ? _buildTrainersList(context, adminId!)
          : _buildAllAdminsTrainersList(context),
    );
  }

  Widget _buildTrainersList(BuildContext context, String adminId) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('admins')
          .doc(adminId)
          .collection('trainers')
          .snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot> trainersSnapshot) {
        if (trainersSnapshot.hasError) {
          return Center(child: Text('Error: ${trainersSnapshot.error}'));
        }

        if (trainersSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final trainersDocs = trainersSnapshot.data?.docs;

        if (trainersDocs == null || trainersDocs.isEmpty) {
          return Center(
              child: Text('No trainers found for admin ID: $adminId'));
        }

        return ListView(
          children: trainersDocs.map((trainerDoc) {
            return _buildTrainerCard(context, trainerDoc, adminId);
          }).toList(),
        );
      },
    );
  }

  Widget _buildAllAdminsTrainersList(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('admins').snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<QuerySnapshot> adminsSnapshot) {
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
                  .collection('trainers')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> trainersSnapshot) {
                if (trainersSnapshot.hasError) {
                  return Center(
                      child: Text('Error: ${trainersSnapshot.error}'));
                }

                if (trainersSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final trainersDocs = trainersSnapshot.data?.docs;

                if (trainersDocs == null || trainersDocs.isEmpty) {
                  return Center();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: trainersDocs.map((trainerDoc) {
                    return _buildTrainerCard(context, trainerDoc, adminId);
                  }).toList(),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTrainerCard(
      BuildContext context, DocumentSnapshot trainerDoc, String adminId) {
    String trainerId = trainerDoc.id;
    String trainerName = trainerDoc['trainerName'];
    String adminName = trainerDoc['adminName'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigate to trainer details page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrainerDetailsPage(
                currentUserId: currentUserId,
                trainerId: trainerId,
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
                width: 48, // Adjust the size of the container as needed
                height: 48, // Adjust the size of the container as needed
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.teal.withOpacity(0.3), // Example color
                ),
                child: Icon(Icons.model_training, color: Colors.teal, size: 28),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trainerName,
                      style: titleTextStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_pin, color: Colors.teal, size: 16),
                        SizedBox(width: 4),
                        Text(
                          adminName,
                          style: subtitleTextStyle,
                        ),
                      ],
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
