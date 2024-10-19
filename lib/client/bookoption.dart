import 'package:Turfease/client/eventbooking.dart';
import 'package:Turfease/main/theme.dart';
import 'package:Turfease/client/trainingbooking.dart';
import 'package:Turfease/client/turfbooking.dart';
import 'package:flutter/material.dart';

class TransactionHistoryScreen extends StatefulWidget {
  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 3, vsync: this); // Changed length to 3
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        toolbarHeight: kTextTabBarHeight,
        title: Text(
          "Transaction",
          style: titleTextStyle,
        ),
        backgroundColor: backgroundColor,
        elevation: 0.0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: tabBarTextStyle,
          labelColor: primaryColor500,
          unselectedLabelColor: darkBlue300,
          indicatorColor: primaryColor500,
          tabs: const [
            Tab(
              text: "Turf", // Changed tab name to Turf
            ),
            Tab(
              text: "Events", // Added Events tab
            ),
            Tab(
              text: "Trainers", // Added Trainers tab
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TurfBookingListPage(), // Contents for Turf tab
          EventBookingListPage(), // Contents for Events tab
          TrainingBookingListPage()
        ],
      ),
    );
  }
}
