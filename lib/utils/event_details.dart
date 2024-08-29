import 'package:Turfease/model/event_category.dart';
import 'package:Turfease/model/event_field.dart';

var KICKOFF = EventCategory(
  name: "KICKOFF",
  id: '01',
);

var ZaroSportz = EventCategory(
  name: "ZaroSportz",
  id: '02',
);

var OLDTRAFFORD = EventCategory(
  name: "OLDTRAFFORD",
  id: '03',
);

var OrionSports = EventCategory(
  name: "OrionSports",
  id: '04',
);

var AimSports = EventCategory(
  name: "AimSports",
  id: '05',
);

List<EventCategory> eventcategory = [
  KICKOFF,
  ZaroSportz,
  OLDTRAFFORD,
  OrionSports,
  AimSports,
];

eventfield one = eventfield(
  id: "101",
  name: "5'sTournament",
  turf: KICKOFF,
  time: '16:00',
  date: '15-06-2024',
  bookfee: 1000,
  winningprice: 6000,
  author: 'Vijayan',
);

eventfield two = eventfield(
  id: "102",
  name: "7'sTournament",
  turf: ZaroSportz,
  time: '07:00',
  date: '13-05-2024',
  bookfee: 500,
  winningprice: 5000,
  author: 'Sachin',
);

eventfield three = eventfield(
  id: "103",
  name: "5'sTournament",
  turf: OLDTRAFFORD,
  time: '06:00',
  date: '15-05-2024',
  bookfee: 1000,
  winningprice: 10000,
  author: 'Messi',
);

eventfield four = eventfield(
  id: "104",
  name: "9'sTournament",
  turf: OrionSports,
  time: '16:00',
  date: '25-05-2024',
  bookfee: 2000,
  winningprice: 25000,
  author: 'Vijayan',
);

eventfield five = eventfield(
  id: "105",
  name: "5'sTournament",
  turf: AimSports,
  time: '06:00',
  date: '15-12-2024',
  bookfee: 1000,
  winningprice: 5000,
  author: 'Amal',
);

List<eventfield> eventfieldList = [
  one,
  two,
  three,
  four,
  five,
];
