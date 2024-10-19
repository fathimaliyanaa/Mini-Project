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

class OfferListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offers List'),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        itemCount: offers.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> offerData = offers[index];

          // Extracting specific fields
          String offerTitle = offerData['offerTitle'];
          String offerDetails = offerData['offerDetails'];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                // Navigate to offer details page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OfferDetailsPage(
                      offerTitle: offerTitle,
                      offerDetails: offerDetails,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 2), // changes position of shadow
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.teal.withOpacity(0.3),
                      ),
                      child:
                          Icon(Icons.local_offer, color: Colors.teal, size: 28),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offerTitle,
                            style: titleTextStyle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            offerDetails,
                            style: subtitleTextStyle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class OfferDetailsPage extends StatelessWidget {
  final String offerTitle;
  final String offerDetails;

  OfferDetailsPage({
    required this.offerTitle,
    required this.offerDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offer Details'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              offerTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              offerDetails,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Static data for demonstration purposes
List<Map<String, dynamic>> offers = [
  {
    'offerTitle': 'Discount on First Booking',
    'offerDetails': 'Get 20% off on your first booking with us.',
  },
  {
    'offerTitle': 'Weekend Special',
    'offerDetails': 'Special rates for bookings made on weekends.',
  },
  {
    'offerTitle': 'Family Package',
    'offerDetails': 'Book for your family and get special discounts.',
  },
  {
    'offerTitle': 'Holiday Season Offer',
    'offerDetails': 'Exciting offers for holiday season bookings.',
  },
];
