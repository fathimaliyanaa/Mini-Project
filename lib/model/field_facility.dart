// field_facility.dart

class FieldFacility {
  String name;
  String imageAsset;
  bool showText; // Add this line

  FieldFacility({
    required this.name,
    required this.imageAsset,
    this.showText = false, // Provide default value
  });
}
