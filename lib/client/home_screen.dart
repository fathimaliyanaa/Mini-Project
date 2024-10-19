import 'package:Turfease/client/bookoption.dart';
import 'package:Turfease/client/details.dart';
import 'package:Turfease/client/turffield.dart';
import 'package:Turfease/login/admin_client.dart';
import 'package:Turfease/main/bottombar.dart';
import 'package:Turfease/main/theme.dart';
import 'package:Turfease/screens/main/setting/profile.dart';
import 'package:Turfease/widget/category_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<DocumentSnapshot> _userStream;
  late Stream<QuerySnapshot> _adminStream;
  String currentUserId = '';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initStreams();
  }

  void _initStreams() {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      setState(() {
        currentUserId = currentUser.uid;
      });
      _userStream = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .snapshots();

      _adminStream =
          FirebaseFirestore.instance.collection('admins').snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: _userStream,
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.data() == null) {
                return Center(child: Text('No user data available.'));
              }

              final userData = snapshot.data!.data() as Map<String, dynamic>;
              final name = userData['name'] ?? '';
              return _header(context, name);
            },
          ),
          Expanded(
            child: ScrollConfiguration(
              behavior: CustomScrollBehavior(),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildGreeting(),
                  CategoryListView(currentUserId: currentUserId),
                  _buildNearbyTurfSection(context),
                  _buildRecommendedTurfs(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _header(BuildContext context, String name) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ProfilePage();
                }));
              },
              child: Row(
                children: [
                  _buildProfileImage(),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Welcome back,", style: descTextStyle),
                      const SizedBox(height: 4),
                      Text(name, style: subTitleTextStyle),
                    ],
                  ),
                ],
              ),
            ),
            _buildNotificationIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      width: 55,
      height: 55,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        image: DecorationImage(
          fit: BoxFit.fill,
          image: AssetImage("assets/images/user_profile_example.png"),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Container(
      decoration: BoxDecoration(
        color: primaryColor500,
        borderRadius: BorderRadius.circular(borderRadiusSize),
      ),
      child: IconButton(
        onPressed: () {},
        icon: const Icon(Icons.notifications, color: Colors.white),
      ),
    );
  }

  Widget _buildGreeting() {
    return Container(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
      child: Text("Let's Have Fun and \nBe Healthy!", style: greetingTextStyle),
    );
  }

  Widget _buildNearbyTurfSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Nearby Turf", style: subTitleTextStyle),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return Turflist(currentUserId: currentUserId);
                }),
              );
            },
            child: const Text("Show All"),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedTurfs() {
    return StreamBuilder<QuerySnapshot>(
      stream: _adminStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No admin IDs found.'));
        }

        List<Widget> recommendedTurfWidgets =
            snapshot.data!.docs.map((adminDoc) {
          String adminId = adminDoc.id;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('admins')
                .doc(adminId)
                .collection('turfs')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                    child: Text('No turfs found for admin ID: $adminId'));
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: snapshot.data!.docs.map((turfDoc) {
                  Map<String, dynamic> data =
                      turfDoc.data() as Map<String, dynamic>;
                  String turfName = data['name'];
                  String turfImage =
                      data['image'] ?? 'assets/images/$turfName.jpg';
                  String turfLocation =
                      data['location'] ?? 'Location not available';

                  return RecommendedTurfCard(
                    turfName: turfName,
                    turfImage: turfImage,
                    turfLocation: turfLocation,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return DetailScreen(
                              turfId: turfDoc.id,
                              adminId: adminId,
                              currentUserId: currentUserId);
                        }),
                      );
                    },
                  );
                }).toList(),
              );
            },
          );
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: recommendedTurfWidgets,
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return SalomonBottomBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TransactionHistoryScreen()),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OptionPage()),
          );
        } else {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      items: [
        SalomonBottomBarItem(
          icon: Icon(Icons.home),
          title: Text('Home'),
        ),
        SalomonBottomBarItem(
          icon: Icon(Icons.book_online),
          title: Text('Bookings'),
        ),
        SalomonBottomBarItem(
          icon: Icon(Icons.logout),
          title: Text('Logout'),
        ),
      ],
    );
  }
}

class RecommendedTurfCard extends StatelessWidget {
  final String turfName;
  final String turfImage;
  final String turfLocation;
  final VoidCallback onTap;

  const RecommendedTurfCard({
    Key? key,
    required this.turfName,
    required this.turfImage,
    required this.turfLocation,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(right: 16, left: 16, top: 4.0, bottom: 16.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: colorWhite,
            boxShadow: [
              BoxShadow(
                color: primaryColor500.withOpacity(0.1),
                blurRadius: 20,
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(
                  turfImage,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      turfName,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      turfLocation,
                      style: TextStyle(color: Colors.grey[600]),
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

class CustomScrollBehavior extends ScrollBehavior {
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
