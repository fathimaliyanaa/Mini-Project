import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CheckoutScreen extends StatefulWidget {
  final String turfId;
  final String turfName;
  final String price;
  final String adminId;
  final String currentUserId;

  CheckoutScreen({
    required this.turfId,
    required this.turfName,
    required this.price,
    required this.adminId,
    required this.currentUserId,
  });

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  DateTime? _dateTime;
  List<TimeCheckBox> availableBookTime = [];
  bool _enableCreateOrderBtn = false;
  double _totalBill = 0.0;
  Set<String> bookedTimes = Set<String>(); // Track booked times

  List<String> availableTimings = [
    "06.00",
    "07.00",
    "08.00",
    "09.00",
    "10.00",
    "11.00",
    "12.00",
    "13.00",
    "14.00",
    "15.00",
    "16.00",
    "17.00",
    "18.00",
    "19.00",
    "20.00",
    "21.00",
    "22.00",
    "23.00"
  ];

  @override
  void initState() {
    super.initState();
    availableBookTime.addAll(availableTimings
        .map((time) => TimeCheckBox(title: time, selected: false)));

    // Fetch booked times from Firestore initially
    fetchBookedTimes();
  }

  void fetchBookedTimes() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference ordersRef = firestore.collection('orders');

    // Query orders for the current turfId and selected date
    QuerySnapshot snapshot = await ordersRef
        .where('turfId', isEqualTo: widget.turfId)
        .where('bookingDate',
            isEqualTo:
                _dateTime) // Adjust according to your Firestore data structure
        .get();

    // Update bookedTimes set with fetched times
    bookedTimes.clear(); // Clear previous bookings for this date
    snapshot.docs.forEach((doc) {
      bookedTimes.add(doc['bookingTime']);
    });

    // Filter out booked times from available times
    setState(() {
      availableBookTime.forEach((checkbox) {
        checkbox.selected = false; // Reset selection
        if (bookedTimes.contains(checkbox.title)) {
          checkbox.disabled = true; // Disable if booked
        } else {
          checkbox.disabled = false; // Enable if not booked
        }
      });
    });
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dateTime) {
      setState(() {
        _dateTime = picked;
        fetchBookedTimes(); // Fetch booked times for the selected date
        _updateTotalBill();
        _enableCreateOrderBtn = _dateTime != null &&
            availableBookTime
                .any((cb) => cb.selected && !bookedTimes.contains(cb.title));
      });
    }
  }

  void _updateTotalBill() {
    double totalPrice = 0.0;
    availableBookTime.forEach((time) {
      if (time.selected && !bookedTimes.contains(time.title)) {
        totalPrice += double.parse(widget.price);
      }
    });
    setState(() {
      _totalBill = totalPrice;
      _enableCreateOrderBtn = _dateTime != null &&
          availableBookTime
              .any((cb) => cb.selected && !bookedTimes.contains(cb.title));
    });
  }

  Widget buildSingleCheckBox(TimeCheckBox checkBox) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: checkBox.disabled
            ? null // Disable onTap if checkbox is disabled
            : () {
                setState(() {
                  checkBox.selected = !checkBox.selected;
                  _updateTotalBill();
                  _enableCreateOrderBtn = _dateTime != null &&
                      availableBookTime.any((cb) =>
                          cb.selected && !bookedTimes.contains(cb.title));
                });
              },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: checkBox.disabled
                  ? Colors.grey.withOpacity(0.5)
                  : checkBox.selected
                      ? const Color.fromARGB(255, 0, 102, 92)
                      : Colors.grey.shade400,
              width: 2,
            ),
            color: checkBox.disabled
                ? Colors.grey.withOpacity(0.1)
                : checkBox.selected
                    ? Colors.teal
                    : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            checkBox.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: checkBox.disabled
                  ? Colors.grey
                  : checkBox.selected
                      ? Colors.blue
                      : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildTimeCheckBoxes() {
    return availableBookTime.map((time) {
      return buildSingleCheckBox(time);
    }).toList();
  }

  Future<void> createOrder(
      String userId, DateTime bookingDate, List<String> selectedTimes) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference ordersRef = firestore.collection('orders');
    DocumentSnapshot userSnapshot =
        await firestore.collection('users').doc(userId).get();

    if (!userSnapshot.exists) {
      print('User not found');
      return;
    }

    Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
    double totalPrice = 0.0;

    selectedTimes.forEach((selectedTime) {
      if (!bookedTimes.contains(selectedTime)) {
        // Generate a unique order ID
        String orderId = DateTime.now().millisecondsSinceEpoch.toString();

        // Calculate price for this booking
        totalPrice += double.parse(widget.price);

        // Upload order details to Firestore
        ordersRef.doc(orderId).set({
          'orderId': orderId,
          'userId': userId,
          'userName':
              userData['name'], // Assuming the user document has a 'name' field
          'userEmail': userData[
              'email'], // Assuming the user document has an 'email' field
          'turfId': widget.turfId,
          'bookingDate': bookingDate,
          'bookingTime': selectedTime,
          'createdAt': FieldValue.serverTimestamp(),
          'adminId': widget.adminId,
          'totalBill': totalPrice, // Store total bill in Firestore
        }).then((_) {
          // Success message or navigate to the next screen
          print('Order successfully created for $selectedTime!');
          bookedTimes.add(selectedTime); // Mark time as booked
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order successfully created for $selectedTime!'),
              duration: Duration(seconds: 2),
            ),
          );
          // Example: Navigate to a confirmation screen or perform further actions
        }).catchError((error) {
          // Error handling
          print('Failed to create order: $error');
        });
      } else {
        print('Slot $selectedTime has already been booked.');
        // Show a message indicating the slot has already been booked
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Slot $selectedTime has already been booked.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.white,
              statusBarIconBrightness: Brightness.dark,
            ),
            title: Text("Checkout"),
            backgroundColor: Colors.white,
            centerTitle: true,
            foregroundColor: Color.fromARGB(255, 0, 102, 92),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(
              right: 24,
              left: 24,
              bottom: 24,
              top: 8,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Venue Name",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color.fromARGB(255, 0, 102, 92),
                              width: 2),
                          color: Colors.teal.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.turfName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Choose date",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color.fromARGB(255, 0, 102, 92),
                                width: 2),
                            color: Colors.teal.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _dateTime != null
                                ? _dateTime.toString().split(' ')[0]
                                : "Select date",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Choose time slot",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        runSpacing: 8,
                        spacing: 8,
                        children: buildTimeCheckBoxes(),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Total Bill",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color.fromARGB(255, 0, 102, 92),
                              width: 2),
                          color: Colors.teal.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "\$$_totalBill",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _enableCreateOrderBtn
                            ? () {
                                List<String> selectedTimes = availableBookTime
                                    .where((time) =>
                                        time.selected &&
                                        !bookedTimes.contains(time.title))
                                    .map((time) => time.title)
                                    .toList();
                                if (selectedTimes.isNotEmpty &&
                                    _dateTime != null) {
                                  createOrder(
                                    widget.currentUserId,
                                    _dateTime!,
                                    selectedTimes,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Please select a date and at least one time slot.'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              }
                            : null,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color.fromARGB(255, 0, 102, 92)),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Create Order',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimeCheckBox {
  String title;
  bool selected;
  bool disabled; // Add disabled property

  TimeCheckBox(
      {required this.title, this.selected = false, this.disabled = false});
}
