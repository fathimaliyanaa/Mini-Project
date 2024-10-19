import 'package:Turfease/client/details.dart'; // Ensure DetailScreen is imported
import 'package:Turfease/main/theme.dart'; // Import your theme and styles from theme.dart
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

class Turflist extends StatelessWidget {
  final String currentUserId;

  const Turflist({
    Key? key,
    required this.currentUserId,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Turf Details'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: TurfSearchDelegate());
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('admins').snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> adminsSnapshot) {
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

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: adminsDocs.map((adminDoc) {
              String adminId = adminDoc.id;

              return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('admins')
                    .doc(adminId)
                    .collection('turfs')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> turfsSnapshot) {
                  if (turfsSnapshot.hasError) {
                    return Center(child: Text('Error: ${turfsSnapshot.error}'));
                  }

                  if (turfsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final turfsDocs = turfsSnapshot.data?.docs;

                  if (turfsDocs == null || turfsDocs.isEmpty) {
                    return Center(
                        child: Text('No turfs found for admin ID: $adminId'));
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: turfsDocs.map((turfsDoc) {
                          Map<String, dynamic> data =
                              turfsDoc.data() as Map<String, dynamic>;
                          String turfName = data['name'];

                          // Build the image path
                          String imagePath = 'assets/images/$turfName.jpg';

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailScreen(
                                        turfId: turfsDoc.id,
                                        currentUserId: currentUserId,
                                        adminId: adminId),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.0),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          borderRadiusSize),
                                      child: Image.asset(
                                        imagePath,
                                        height: 65,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data['name'].toUpperCase(),
                                            style: titleTextStyle,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                color: primaryColor500,
                                                size: 20,
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  data['location'],
                                                  style: subtitleTextStyle,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
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
                        }).toList(),
                      ),
                    ],
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class TurfSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    // Actions for search bar
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Leading icon on the left of the search bar
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Build search results based on query
    // For example, filter the turfs based on the query and display them
    return Center(
      child: Text('Search results for: $query'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Suggestions when the user types in the search bar
    // For now, just return an empty container as an example
    return Container();
  }
}
