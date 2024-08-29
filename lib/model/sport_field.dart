import 'package:Turfease/model/field_facility.dart';
import 'package:Turfease/model/sport_category.dart';

class SportField {
  String id;
  String name;
  SportCategory category;
  List<FieldFacility> facilities;
  String eventname;
  String eventdetails;
  String address;
  String phoneNumber;
  String openDay;
  String openTime;
  String closeTime;
  String imageAsset;
  int price;
  String author;
  String authorUrl;
  String imageUrl;

  SportField(
      {required this.id,
      required this.name,
      required this.category,
      required this.facilities,
      required this.eventname,
      required this.eventdetails,
      required this.address,
      required this.phoneNumber,
      required this.openDay,
      required this.openTime,
      required this.closeTime,
      required this.imageAsset,
      required this.price,
      required this.author,
      required this.authorUrl,
      required this.imageUrl});

  get event => null;
}
