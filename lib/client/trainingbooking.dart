import 'package:Turfease/client/home_screen.dart';
import 'package:Turfease/main/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TrainingBookingListPage extends StatelessWidget {
  final Color backgroundColor = Colors.white;
  final Color primaryColor100 = Colors.blue.shade100;
  final TextStyle normalTextStyle = TextStyle(fontSize: 16);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('hire').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                child: NoTransactionMessage(
                  messageTitle: "No Transactions, yet.",
                  messageDesc:
                      "You have never placed an order. Let's explore the sport venue near you.",
                ),
              ),
            );
          }

          List<FieldOrder> fieldOrderList = snapshot.data!.docs.map((doc) {
            return FieldOrder.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();

          return ListView.builder(
            itemCount: fieldOrderList.length,
            itemBuilder: (BuildContext context, int index) {
              return FutureBuilder<String>(
                future: getAdminName(fieldOrderList[index].adminId),
                builder: (context, adminSnapshot) {
                  if (adminSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (adminSnapshot.hasError) {
                    return Center(
                      child: Text('Error: ${adminSnapshot.error}'),
                    );
                  }

                  String adminName = adminSnapshot.data ?? 'Unknown Admin';

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(),
                        ),
                      );
                    },
                    splashColor: primaryColor100,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade200,
                            ),
                            child: Icon(
                              Icons.sports_soccer,
                              size: 30,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  'Trainer: ${fieldOrderList[index].fieldName}',
                                  style: titleTextStyle,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Turf: $adminName',
                                  style: descTextStyle,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Starting Date: ${DateFormat('yyyy-MM-dd').format(fieldOrderList[index].bookingDate)}',
                                  style: descTextStyle,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Duration: ${fieldOrderList[index].bookingTime} days',
                                  style: descTextStyle,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Order ID: ${fieldOrderList[index].orderId}',
                                  style: descTextStyle,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 0, 98, 85)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: Color.fromARGB(255, 0, 98, 85)),
                                ),
                                child: Text(
                                  "Booked",
                                  style: normalTextStyle.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 0, 98, 85),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                  height: 8), // Space between status and fee
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue),
                                ),
                                child: Text(
                                  "\$${fieldOrderList[index].fee}",
                                  style: normalTextStyle.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<String> getAdminName(String? adminId) async {
    if (adminId == null) return 'Unknown Admin';
    DocumentSnapshot adminDoc = await FirebaseFirestore.instance
        .collection('admins')
        .doc(adminId)
        .get();
    return adminDoc['name'] ?? 'Unknown Admin';
  }
}

class NoTransactionMessage extends StatelessWidget {
  final String messageTitle;
  final String messageDesc;

  const NoTransactionMessage({
    Key? key,
    required this.messageTitle,
    required this.messageDesc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          messageTitle,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Text(
          messageDesc,
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class FieldOrder {
  final String? fieldName;
  final DateTime bookingDate;
  final int bookingTime;
  final String? fieldImageAsset;
  final String? adminId;
  final String orderId;
  final String fee;

  FieldOrder({
    required this.fieldName,
    required this.bookingDate,
    required this.bookingTime,
    this.fieldImageAsset,
    required this.adminId,
    required this.orderId,
    required this.fee,
  });

  factory FieldOrder.fromMap(Map<String, dynamic> data) {
    return FieldOrder(
      fieldName: data['trainerName'] ?? 'Unknown Trainer',
      bookingDate: (data['startingdate'] as Timestamp).toDate(),
      bookingTime: data['Duration'] ?? 0,
      fieldImageAsset: data['fieldImageAsset'],
      adminId: data['adminId'],
      orderId: data['trainerId'],
      fee: (data['trainerFees'] ?? 0.0).toString(),
    );
  }
}
