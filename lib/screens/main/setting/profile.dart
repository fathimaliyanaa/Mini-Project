import 'package:Turfease/main/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Stream<DocumentSnapshot> _stream;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    final currentUserUid = _auth.currentUser!.uid;
    _stream = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            color: colorWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.poppins()
                .fontFamily, // Use Google Fonts from theme.dart
          ),
        ),
        backgroundColor: primaryColor500, // Use primary color from theme.dart
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: StreamBuilder<DocumentSnapshot>(
          stream: _stream,
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final name = userData['name'] ?? '';
            final email = userData['email'] ?? '';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Center(
                  child: Container(
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor:
                          primaryColor500, // Use primary color from theme.dart
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: colorWhite, // Use colorWhite from theme.dart
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ListTile(
                  title: Text(
                    'Name:',
                    style: titleTextStyle, // Use titleTextStyle from theme.dart
                  ),
                  subtitle: Text(
                    name,
                    style:
                        normalTextStyle, // Use normalTextStyle from theme.dart
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text(
                    'Email:',
                    style: titleTextStyle, // Use titleTextStyle from theme.dart
                  ),
                  subtitle: Text(
                    email,
                    style:
                        normalTextStyle, // Use normalTextStyle from theme.dart
                  ),
                ),
                SizedBox(height: 20),
                // Add more sections here such as bio, contact info, etc.
              ],
            );
          },
        ),
      ),
    );
  }
}
