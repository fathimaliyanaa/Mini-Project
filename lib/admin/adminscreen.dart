import 'package:Turfease/login/admin_client.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../main/theme.dart';
import '../screens/main/setting/profile.dart';
import 'addevent.dart';
import 'addtrainer.dart';
import 'addturf.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;
  Map<String, dynamic>? adminDetails;
  List<String>? turfIds;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchCurrentUserDetails().then((_) {
      if (currentUserId != null) {
        fetchAdminDetailsAndTurfIds(currentUserId!).then((details) {
          setState(() {
            adminDetails = details['adminDetails'];
            turfIds = details['turfIds'];
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchCurrentUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid;
    } else {
      print('No user is currently signed in');
    }
  }

  Future<Map<String, dynamic>> fetchAdminDetailsAndTurfIds(
      String adminId) async {
    Map<String, dynamic> result = {};

    try {
      DocumentSnapshot<Map<String, dynamic>> adminSnapshot =
          await FirebaseFirestore.instance
              .collection('admins')
              .doc(adminId)
              .get();

      if (adminSnapshot.exists) {
        result['adminDetails'] = adminSnapshot.data();

        QuerySnapshot<Map<String, dynamic>> turfSnapshot =
            await FirebaseFirestore.instance
                .collection('admins')
                .doc(adminId)
                .collection('turf')
                .get();

        result['turfIds'] = turfSnapshot.docs.map((doc) => doc.id).toList();
      } else {
        print('Admin document does not exist');
      }
    } catch (e) {
      print('Error fetching admin details and turf IDs: $e');
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return AdminScreen();
                      }));
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 55,
                          height: 55,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: AssetImage(
                                  "assets/images/user_profile_example.png"),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Welcome back,"),
                            const SizedBox(height: 4),
                            adminDetails != null
                                ? Text(
                                    adminDetails!['name'],
                                    style: titleTextStyle,
                                  )
                                : Text(
                                    'Admin',
                                    style: titleTextStyle,
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: primaryColor500,
                      borderRadius: BorderRadius.circular(borderRadiusSize),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return ProfilePage();
                        }));
                      },
                      icon: const Icon(Icons.search, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildAdminBox(
                              Icons.grass, "Add Turf", AddTurfPage()),
                          SizedBox(width: 10),
                          _buildAdminBox(
                              Icons.event, "Add Events", AddEventPage()),
                          SizedBox(width: 10),
                          _buildAdminBox(
                              Icons.person_add, "Add Coach", AddtrainerPage()),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(minHeight: 0),
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Booking Details",
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        TabBar(
                          controller: _tabController,
                          tabs: [
                            Tab(text: 'Turf'),
                            Tab(text: 'Event'),
                            Tab(text: 'Coach'),
                          ],
                        ),
                        SizedBox(height: 10),
                        Container(
                          height: 300,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildTurfBookingDetailsList("Turf"),
                              _buildEventBookingDetailsList("Event"),
                              _buildCoachDetailsList("Coach"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            // Assuming index 1 corresponds to logout
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => OptionPage()));
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
          // Add more BottomNavigationBarItem as needed
        ],
      ),
    );
  }

  Widget _buildAdminBox(IconData icon, String label, Widget pageToNavigate) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => pageToNavigate),
        );
      },
      child: Container(
        width: 120,
        height: 120,
        margin: EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            SizedBox(height: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTurfBookingDetailsList(String category) {
    CollectionReference ordersRef =
        FirebaseFirestore.instance.collection('orders');

    Query ordersQuery = ordersRef.where('adminId', isEqualTo: currentUserId);

    if (category == 'Turf') {
      return _buildTurfBookingList(ordersQuery);
    } else {
      return Center(child: Text('Invalid category'));
    }
  }

  Widget _buildTurfBookingList(Query query) {
    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No turf bookings found.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var booking =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;

            String userName = booking['userName'] ?? '';
            Timestamp bookingDate = booking['bookingDate'];
            String bookingTime = booking['bookingTime'] ?? '';
            String orderId = booking['orderId'] ?? '';
            String userId = booking['userId'] ?? '';

            DateTime date =
                bookingDate.toDate(); // Convert Timestamp to DateTime

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 8),
                        Text('User Name: $userName',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 8),
                        Text(
                            'Booking Date: ${DateFormat('yyyy-MM-dd').format(date)}'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time),
                        SizedBox(width: 8),
                        Text('Booking Time: $bookingTime'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.confirmation_num),
                        SizedBox(width: 8),
                        Text('Order ID: $orderId'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.account_box),
                        SizedBox(width: 8),
                        Text('User ID: $userId'),
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
  }

  Widget _buildEventBookingDetailsList(String category) {
    CollectionReference ordersRef =
        FirebaseFirestore.instance.collection('orders');

    Query ordersQuery = ordersRef.where('adminId', isEqualTo: currentUserId);

    if (category == 'Event') {
      return _buildEventBookingList(ordersQuery);
    } else {
      return Center(child: Text('Invalid category'));
    }
  }

  Widget _buildEventBookingList(Query query) {
    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No event bookings found.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var booking =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;

            String userName = booking['userName'] ?? '';
            Timestamp bookingDate = booking['bookingDate'];
            String bookingTime = booking['bookingTime'] ?? '';
            String orderId = booking['orderId'] ?? '';
            String userId = booking['userId'] ?? '';

            DateTime date =
                bookingDate.toDate(); // Convert Timestamp to DateTime

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 8),
                        Text('User Name: $userName',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 8),
                        Text(
                            'Booking Date: ${DateFormat('yyyy-MM-dd').format(date)}'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time),
                        SizedBox(width: 8),
                        Text('Booking Time: $bookingTime'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.confirmation_num),
                        SizedBox(width: 8),
                        Text('Order ID: $orderId'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.account_box),
                        SizedBox(width: 8),
                        Text('User ID: $userId'),
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
  }

  Widget _buildCoachDetailsList(String category) {
    CollectionReference ordersRef =
        FirebaseFirestore.instance.collection('orders');

    Query ordersQuery = ordersRef.where('adminId', isEqualTo: currentUserId);

    if (category == 'Coach') {
      return _buildCoachList(ordersQuery);
    } else {
      return Center(child: Text('Invalid category'));
    }
  }

  Widget _buildCoachList(Query query) {
    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No coach bookings found.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var booking =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;

            String userName = booking['userName'] ?? '';
            Timestamp bookingDate = booking['bookingDate'];
            String bookingTime = booking['bookingTime'] ?? '';
            String orderId = booking['orderId'] ?? '';
            String userId = booking['userId'] ?? '';

            DateTime date =
                bookingDate.toDate(); // Convert Timestamp to DateTime

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 8),
                        Text('User Name: $userName',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 8),
                        Text(
                            'Booking Date: ${DateFormat('yyyy-MM-dd').format(date)}'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time),
                        SizedBox(width: 8),
                        Text('Booking Time: $bookingTime'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.confirmation_num),
                        SizedBox(width: 8),
                        Text('Order ID: $orderId'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.account_box),
                        SizedBox(width: 8),
                        Text('User ID: $userId'),
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
  }
}
