import 'package:flutter/material.dart';

class EventListPage extends StatelessWidget {
  final String currentUserId;

  EventListPage({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event List'),
      ),
      body: Center(
        child: Text('Event List Page'),
      ),
    );
  }
}
