import 'package:Turfease/client/EventListPage.dart';
import 'package:Turfease/client/TrainerListPage.dart';
import 'package:Turfease/main/checkbox.dart';
import 'package:Turfease/model/field_facility.dart';
import 'package:Turfease/main/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final TextStyle titleTextStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: Colors.black,
);

class DetailScreen extends StatelessWidget {
  final String turfId;
  final String currentUserId;
  final String adminId;

  DetailScreen({
    Key? key,
    required this.turfId,
    required this.currentUserId,
    required this.adminId,
  }) : super(key: key);

  Future<Map<String, dynamic>?> _fetchTurfDetails() async {
    try {
      final turfDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(adminId)
          .collection('turfs')
          .doc(turfId)
          .get();

      if (turfDoc.exists) {
        final turfData = turfDoc.data();
        if (turfData != null) {
          // Fetch facilities if available
          List<FieldFacility> facilities = [];
          final fetchedFacilities = turfData['facilities'] as List<dynamic>?;

          if (fetchedFacilities != null) {
            var _wifi = FieldFacility(
                name: "WiFi", imageAsset: "assets/icons/wifi.png");
            var _toilet = FieldFacility(
                name: "Toilet", imageAsset: "assets/icons/toilet.png");
            var _changingRoom = FieldFacility(
                name: "Changing Room",
                imageAsset: "assets/icons/changing_room.png");
            var _canteen = FieldFacility(
                name: "Canteen", imageAsset: "assets/icons/canteen.png");
            var _locker = FieldFacility(
                name: "Lockers", imageAsset: "assets/icons/lockers.png");
            var _chargingArea = FieldFacility(
                name: "Charging Area", imageAsset: "assets/icons/charging.png");

            if (fetchedFacilities.contains('WiFi')) {
              facilities.add(_wifi);
            }
            if (fetchedFacilities.contains('Toilet')) {
              facilities.add(_toilet);
            }
            if (fetchedFacilities.contains('Changing Room')) {
              facilities.add(_changingRoom);
            }
            if (fetchedFacilities.contains('Canteen')) {
              facilities.add(_canteen);
            }
            if (fetchedFacilities.contains('Lockers')) {
              facilities.add(_locker);
            }
            if (fetchedFacilities.contains('Charging Area')) {
              facilities.add(_chargingArea);
            }
          }

          turfData['facilities'] = facilities;

          return turfData;
        }
      }
    } catch (e) {
      print('Error fetching turf details: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
            color: lightBlue300,
            offset: Offset(0, 0),
            blurRadius: 10,
          ),
        ]),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(100, 45),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadiusSize))),
          onPressed: () async {
            Map<String, dynamic>? turfDetails = await _fetchTurfDetails();
            if (turfDetails != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CheckoutScreen(
                    turfId: turfId,
                    turfName: turfDetails['name'] ?? 'Turf Name',
                    price: '${turfDetails['price'] ?? 'N/A'}',
                    adminId: adminId,
                    currentUserId: currentUserId,
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: Turf details not found.'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: const Text("Book Now"),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchTurfDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching turf details'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Turf details not found'));
          }

          final turfDetails = snapshot.data!;
          final turfName = turfDetails['name'];
          final String imagePath = 'assets/images/$turfName.jpg';

          return CustomScrollView(
            slivers: [
              customSliverAppBar(context, turfDetails),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 200,
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                      child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildElevatedButton(
                                    context,
                                    label: 'Events',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EventListPage(
                                            currentUserId: currentUserId,
                                            adminId: adminId,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  _buildElevatedButton(
                                    context,
                                    label: 'Coach',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TrainerListPage(
                                            currentUserId: currentUserId,
                                            adminId: adminId,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                            _buildDetailRow(
                              icon: Icons.location_on,
                              text:
                                  turfDetails['location'] ?? 'Unknown Location',
                            ),
                            SizedBox(height: 8),
                            _buildDetailRow(
                              icon: Icons.attach_money,
                              text: '${turfDetails['price'] ?? 'N/A'} / hour',
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Contact:',
                              style: subTitleTextStyle,
                            ),
                            SizedBox(height: 8),
                            _buildDetailRow(
                              icon: Icons.phone,
                              text: turfDetails['contact'] ?? 'No Contact Info',
                            ),
                            SizedBox(height: 8),
                            _buildDetailRow(
                              icon: Icons.person,
                              text: turfDetails['adminName'] ?? 'Admin',
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Availability:',
                              style: subTitleTextStyle,
                            ),
                            SizedBox(height: 8),
                            _buildDetailRow(
                              icon: Icons.calendar_today,
                              text:
                                  'Open Days', // Replace with actual open days if available
                            ),
                            SizedBox(height: 8),
                            _buildDetailRow(
                              icon: Icons.access_time,
                              text:
                                  '${turfDetails['opening_time'] ?? 'N/A'} - ${turfDetails['closing_time'] ?? 'N/A'}',
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Facilities:',
                              style: subTitleTextStyle,
                            ),
                            SizedBox(height: 8),
                            _buildFacilitiesGrid(turfDetails['facilities']),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget customSliverAppBar(context, field) {
    return SliverAppBar(
      shadowColor: primaryColor500.withOpacity(.2),
      backgroundColor: colorWhite,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.black.withOpacity(0.4),
        statusBarIconBrightness: Brightness.light,
      ),
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        expandedTitleScale: 1,
        titlePadding: EdgeInsets.zero,
        title: Container(
          width: MediaQuery.of(context).size.width,
          height: kToolbarHeight,
          decoration: const BoxDecoration(
              color: colorWhite,
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(borderRadiusSize))),
          child: Center(
            child: Text(
              field['name'] ?? 'Turf Name',
              style: titleTextStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        background:
            Container(), // or you can provide background image here if required
      ),
      expandedHeight: 0,
    );
  }

  Widget _buildDetailRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(fontSize: 14, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildElevatedButton(BuildContext context,
      {required String label, required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFacilitiesGrid(List<FieldFacility>? facilities) {
    if (facilities == null || facilities.isEmpty) {
      return Text('No facilities available.');
    }

    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: facilities.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[200],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                facilities[index].imageAsset,
                width: 40,
                height: 40,
              ),
              SizedBox(height: 8),
              Text(
                facilities[index].name,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}
