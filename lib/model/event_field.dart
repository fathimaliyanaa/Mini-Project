import 'package:Turfease/model/event_category.dart';

class eventfield {
  String id;
  String name;
  EventCategory turf;
  String date;
  String time;
  int bookfee;
  int winningprice;
  String author;

  eventfield({
    required this.id,
    required this.name,
    required this.turf,
    required this.date,
    required this.time,
    required this.bookfee,
    required this.winningprice,
    required this.author,
  });
}
