import 'package:Turfease/main/theme.dart'; // Adjust path as per your project structure
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TrainerDetailsPage extends StatelessWidget {
  final String trainerId;
  final String currentUserId;
  final String adminId;

  TrainerDetailsPage({
    Key? key,
    required this.trainerId,
    required this.currentUserId,
    required this.adminId,
  }) : super(key: key);

  Future<Map<String, dynamic>?> _fetchTrainerDetails() async {
    try {
      // Fetch admin details to get admin name
      final adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(adminId)
          .get();

      final adminName = adminDoc.data()?['adminName'];

      // Fetch trainer details using trainerId
      final trainerDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(adminId)
          .collection('trainers')
          .doc(trainerId)
          .get();

      if (trainerDoc.exists) {
        var trainer = trainerDoc.data();
        trainer?['trainerId'] = trainerDoc.id; // Include the document ID
        trainer?['adminName'] = adminName; // Add admin name to trainer
        return trainer;
      } else {
        print('Trainer not found');
      }
    } catch (e) {
      print('Error fetching trainer details: $e');
    }
    return null;
  }

  Future<void> _registerForEvent(
      BuildContext context, Map<String, dynamic> trainer) async {
    try {
      // Fetch current user's name
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId) // Assuming 'users' collection stores user details
          .get();

      final userName = userDoc.data()?['name'];

      if (userName == null) {
        throw Exception('User name not found');
      }

      // Check if the user has already registered for this trainer
      final existingRegistrationQuery = await FirebaseFirestore.instance
          .collection('hire')
          .where('trainerId', isEqualTo: trainer['trainerId'])
          .where('bookedBy', isEqualTo: userName) // Use userName as bookedBy
          .get();

      if (existingRegistrationQuery.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("You have already registered for this trainer"),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Add registration details to 'hire' collection
      await FirebaseFirestore.instance.collection('hire').add({
        'trainerName': trainer['trainerName'],
        'trainerContact': trainer['trainerContact'],
        'trainerSpecialty': trainer['trainerSpecialty'],
        'trainerExperience': trainer['trainerExperience'],
        'trainerFees': trainer['trainerFees'],
        'adminName': trainer['adminName'],
        'bookedBy': userName, // Use userName as bookedBy
        'adminId': adminId,
        'trainerId': trainer['trainerId'],
        'userId': currentUserId,
        'startingdate': trainer['trainingStartDate'],
        'Duration': trainer['trainingDuration'],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Registered for trainer: ${trainer['trainerName']}"),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error registering for event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to register for trainer"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trainer Details'),
        backgroundColor: primaryColor500,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchTrainerDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching trainer details'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No trainer details found'));
          }

          final trainer = snapshot.data!;
          return Padding(
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trainer['trainerName'] ?? 'Trainer Name',
                          style: titleTextStyle.copyWith(fontSize: 18),
                        ),
                        SizedBox(height: 8),
                        _buildDetailRow(
                          icon: Icons.phone,
                          text:
                              'Contact: ${trainer['trainerContact'] ?? 'N/A'}',
                        ),
                        SizedBox(height: 8),
                        _buildDetailRow(
                          icon: Icons.school,
                          text:
                              'Specialty: ${trainer['trainerSpecialty'] ?? 'N/A'}',
                        ),
                        SizedBox(height: 8),
                        _buildDetailRow(
                          icon: Icons.school,
                          text:
                              'Experience: ${trainer['trainerExperience'] ?? 'N/A'} years',
                        ),
                        SizedBox(height: 8),
                        _buildDetailRow(
                          icon: Icons.attach_money,
                          text: 'Fees: ${trainer['trainerFees'] ?? 'N/A'}',
                        ),
                        SizedBox(height: 8),
                        _buildDetailRow(
                          icon: Icons.person,
                          text: 'Admin: ${trainer['adminName'] ?? 'N/A'}',
                        ),
                        SizedBox(height: 8),
                        _buildDetailRow(
                          icon: Icons.person,
                          text:
                              'Starting Date: ${_formatDate(trainer['trainingStartDate']) ?? 'N/A'}',
                        ),
                        SizedBox(height: 8),
                        _buildDetailRow(
                          icon: Icons.person,
                          text:
                              'Duration: ${trainer['trainingDuration'] ?? 'N/A'}',
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _registerForEvent(context, trainer),
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
                            'Hire',
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
          );
        },
      ),
    );
  }

  String? _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000)
        .toString();
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
}
