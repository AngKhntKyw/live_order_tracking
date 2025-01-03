class Driver {
  String driverId;
  double latitude;
  double longitude;
  double rotation;

  Driver({
    required this.driverId,
    required this.latitude,
    required this.longitude,
    required this.rotation,
  });

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
        driverId: json['driverId'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        rotation: json['rotation'],
      );

  Map<String, dynamic> toJson() => {
        'driverId': driverId,
        'latitude': latitude,
        'longitude': longitude,
        'rotation': rotation,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Driver &&
          driverId == other.driverId &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          rotation == other.rotation;

  @override
  int get hashCode =>
      driverId.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      rotation.hashCode;
}
