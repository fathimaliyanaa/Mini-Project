import 'package:Turfease/login/signin.dart';
import 'package:Turfease/client/EventListPage.dart';
import 'package:Turfease/client/TrainerListPage.dart';
import 'package:Turfease/client/offerlistpage.dart';
import 'package:Turfease/main/theme.dart';
import 'package:Turfease/client/turffield.dart';
import 'package:Turfease/utils/turf_details.dart';
import 'package:flutter/material.dart';

class CategoryListView extends StatelessWidget {
  final String currentUserId;

  const CategoryListView({required this.currentUserId});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: sportCategories.map((category) {
            return CategoryCard(
              title: category.name,
              imageAsset: category.image,
              onTap: () {
                // Here you can navigate to different pages based on category
                if (category.name == "Nearby Turf") {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return Turflist(currentUserId: currentUserId);
                  }));
                } else if (category.name == "Events") {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EventListPage(currentUserId: currentUserId),
                      ));
                } else if (category.name == "Trainer") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            TrainerListPage(currentUserId: currentUserId)),
                  );
                } else if (category.name == "Offers") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OfferListPage()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Signin()),
                  );
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String imageAsset;
  final VoidCallback onTap;

  const CategoryCard({
    required this.title,
    required this.imageAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
      child: Material(
        color: colorWhite,
        shadowColor: primaryColor500.withOpacity(0.1),
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          highlightColor: primaryColor500.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          splashColor: primaryColor500.withOpacity(0.5),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: primaryColor100,
                    child: Image.asset(
                      imageAsset,
                      color: primaryColor500,
                      width: 50,
                      height: 50,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Text(
                  title,
                  style: descTextStyle,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
