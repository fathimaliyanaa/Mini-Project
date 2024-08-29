import 'package:Turfease/model/field_facility.dart';
import 'package:Turfease/model/field_order.dart';
import 'package:Turfease/model/sport_category.dart';
import 'package:Turfease/model/sport_field.dart';
import 'package:Turfease/model/user.dart';

var sampleUser = User(
    name: "Sample User",
    email: "sample@mail.com",
    imageProfile: "assets/images/user_profile_example.png");

var All = SportCategory(
  name: "Nearby Turf",
  image: "assets/icons/basketball.png",
);
var _futsal = SportCategory(
  name: "Trainer",
  image: "assets/icons/soccer.png",
);
var _volley = SportCategory(
  name: "Offers",
  image: "assets/icons/volley.png",
);

var _tennis = SportCategory(
  name: "Events",
  image: "assets/icons/tennis.png",
);

List<SportCategory> sportCategories = [
  All,
  _tennis,
  _futsal,
  _volley,
];

var _wifi = FieldFacility(name: "WiFi", imageAsset: "assets/icons/wifi.png");
var _toilet =
    FieldFacility(name: "Toilet", imageAsset: "assets/icons/toilet.png");
var _changingRoom = FieldFacility(
    name: "Changing Room", imageAsset: "assets/icons/changing_room.png");
var _canteen =
    FieldFacility(name: "Canteen", imageAsset: "assets/icons/canteen.png");
var _locker =
    FieldFacility(name: "Lockers", imageAsset: "assets/icons/lockers.png");
var _chargingArea = FieldFacility(
    name: "Charging Area", imageAsset: "assets/icons/charging.png");

SportField ZaroSportz = SportField(
  id: "01",
  name: "ZaroSportz",
  address: "Navodaya Road, Kurunthodi",
  category: All,
  facilities: [_wifi, _toilet],
  eventname: 'FIVES TOURNAMENT',
  eventdetails: 'Time: 16:00\t\tDate:15-06-2024\nVenue: Zarosportz',
  phoneNumber: "099619 83956",
  openDay: "Monday to Sunday",
  openTime: "06.00",
  closeTime: "22.00",
  imageAsset: "assets/images/pringsewu_futsal.jpg",
  price: 800,
  author: "Daniel larionov",
  authorUrl: "https://unsplash.com/@foxysnaps",
  imageUrl: "https://unsplash.com/photos/oXCgQRsb2ug",
);

SportField KICKOFF = SportField(
    id: "02",
    name: "KICKOFF",
    address: "GJ9H+H47, Payyoli",
    category: All,
    facilities: [_wifi, _toilet, _changingRoom, _canteen],
    eventname: 'SEVENS TOURNAMENT',
    eventdetails: 'Time: 07:00\t\tDate:13-05-2024\nVenue: KICKOFF',
    author: "Fulvio ambrosanio",
    authorUrl: "https://unsplash.com/@fiercelupus",
    imageUrl: "https://unsplash.com/photos/zygvOSND4rI",
    phoneNumber: "081378 22777",
    openDay: "All Day",
    openTime: "07.00",
    closeTime: "22.00",
    imageAsset: "assets/images/vio_basketball.jpg",
    price: 600);
SportField OLDTRAFFORD = SportField(
    id: "03",
    name: "OLD TRAFFORD TURF",
    address: "Edodi, Vadakara",
    category: All,
    facilities: [_wifi, _toilet, _canteen, _chargingArea, _changingRoom],
    eventname: 'FIVES TOURNAMENT',
    eventdetails: 'Time: 06:00\t\tDate:15-05-2024\nVenue: OLD TRAFFORD TURF',
    author: "Meritt Thomas",
    authorUrl: "https://unsplash.com/@merittthomas",
    imageUrl: "https://unsplash.com/photos/rgo4m8J0H2M",
    phoneNumber: "073569 46222",
    openDay: "All Day",
    openTime: "06.00",
    closeTime: "23.00",
    imageAsset: "assets/images/voli_pantai.jpg",
    price: 700);
SportField Pabellon = SportField(
    id: "04",
    name: "Pabellon Football Turf",
    address: "Mathi pengan, Vatakara",
    category: All,
    facilities: [_wifi, _toilet, _canteen],
    eventname: '',
    eventdetails: '',
    author: "Ivan cortez",
    authorUrl: "https://unsplash.com/@ivancortez14",
    imageUrl: "https://unsplash.com/photos/c9aGBqkeoE4",
    phoneNumber: "081378 22774",
    openDay: "All Day",
    openTime: "06.00",
    closeTime: "23.00",
    imageAsset: "assets/images/tenis_meja_cortez.jpg",
    price: 900);
SportField FreeKick = SportField(
    id: "05",
    name: "FREE KICK FOOTBALL TURF",
    address: "Thiruvallur Vadakara",
    category: All,
    facilities: [_toilet],
    eventname: '',
    eventdetails: '',
    author: "Ilnur kalimullin",
    authorUrl: "https://unsplash.com/@kalimullin",
    imageUrl: "https://unsplash.com/photos/kP1AxmCyEXM",
    phoneNumber: "0888 9999 1111",
    openDay: "All Day",
    openTime: "06.00",
    closeTime: "22.00",
    imageAsset: "assets/images/kali_basketball.jpg",
    price: 750);

SportField AimSports = SportField(
    id: "06",
    name: "Aim Sports",
    address: "Villiappally, Vadakara",
    category: All,
    facilities: [_toilet],
    eventname: 'FIVES TOURNAMENT',
    eventdetails: 'Time: 06:00\t\tDate:15-12-2024\nVenue: Aim Sports',
    author: "Lucas Marcomini",
    authorUrl: "https://unsplash.com/@lucasmarcomini",
    imageUrl: "https://unsplash.com/photos/77pAlgB8v_E",
    phoneNumber: "0855 6666 7777",
    openDay: "All Day",
    openTime: "06.00",
    closeTime: "22.00",
    imageAsset: "assets/images/lm_basketball.jpg",
    price: 850);

SportField OrionSports = SportField(
    id: "07",
    name: "Orion Sports Hub",
    address: "Ayancherry Thiruvallur Road",
    category: All,
    facilities: [_wifi, _toilet, _locker],
    eventname: 'NINES TOURNAMENT',
    eventdetails: 'Time: 16:00\t\tDate:25-12-2024\nVenue: OrionSports',
    author: "Denise chan",
    authorUrl: "https://unsplash.com/photos/hAr9Nlo2Fz4",
    imageUrl: "https://unsplash.com/@noripurrs",
    phoneNumber: "0811 2222 3333",
    openDay: "All Day",
    openTime: "06.00",
    closeTime: "17.00",
    imageAsset: "assets/images/dc_tennis_court.jpg",
    price: 650);

SportField PlayCityTurf = SportField(
    id: "08",
    name: "Play City Turf",
    address: "Meppayur Avala Road",
    category: All,
    facilities: [_toilet, _changingRoom, _chargingArea],
    eventname: '',
    eventdetails: '',
    author: "Rob coates",
    authorUrl: "https://unsplash.com/@itsrobcoates",
    imageUrl: "https://unsplash.com/photos/BDCTRVu7DwY",
    phoneNumber: "0877 8888 9999",
    openDay: "All Day",
    openTime: "06.00",
    closeTime: "23.00",
    imageAsset: "assets/images/tennis_coates.jpg",
    price: 600);

SportField PasosTurf = SportField(
    id: "09",
    name: "Pasos Turf Field",
    address: "Nadapuram Kallachi Road",
    category: All,
    facilities: [_toilet, _canteen],
    eventname: '',
    eventdetails: '',
    author: "Izuddin Helmi Adnan",
    authorUrl: "https://unsplash.com/@izuddinhelmi",
    imageUrl: "https://unsplash.com/photos/siurZcdJGEw",
    phoneNumber: "0844 5555 6666",
    openDay: "All Day",
    openTime: "06.00",
    closeTime: "22.00",
    imageAsset: "assets/images/jaya_futsal.jpg",
    price: 700);

SportField Turf = SportField(
    id: "010",
    name: "Turf",
    address: "Park Road, Edodi, Vadakara",
    category: All,
    facilities: [_toilet, _changingRoom, _locker, _canteen],
    eventname: '',
    eventdetails: '',
    author: "Sergei Wing",
    authorUrl: "https://unsplash.com/@sergeiwing",
    imageUrl: "https://unsplash.com/photos/Bt-oCv_YI3E",
    phoneNumber: "0899 1010 2222",
    openDay: "All Day",
    openTime: "06.00",
    closeTime: "23.00",
    imageAsset: "assets/images/wing_tennis.jpg",
    price: 800);

List<SportField> sportFieldList = [
  KICKOFF,
  ZaroSportz,
  OLDTRAFFORD,
  OrionSports,
  AimSports,
  Turf,
  PasosTurf,
  PlayCityTurf,
  FreeKick,
  Pabellon,
];

List<SportField> recommendedSportField = [
  KICKOFF,
  ZaroSportz,
  OLDTRAFFORD,
  OrionSports,
  AimSports,
];

List<FieldOrder> dummyUserOrderList = [];

List<String> timeToBook = [
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
