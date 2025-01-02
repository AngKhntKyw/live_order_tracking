import 'package:live_order_tracking/model/address.dart';

class Booking {
  Address pickUp;
  Address destination;
  String fare;

  Booking({
    required this.pickUp,
    required this.destination,
    required this.fare,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        pickUp: Address.fromJson(json['pickUp']),
        destination: Address.fromJson(json['destination']),
        fare: json['fare'],
      );

  Map<String, dynamic> toJson() => {
        'pickUp': pickUp.toJson(),
        'destination': destination.toJson(),
        'fare': fare,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Booking &&
          pickUp == other.pickUp &&
          destination == other.destination &&
          fare == other.fare;

  @override
  int get hashCode => pickUp.hashCode ^ destination.hashCode ^ fare.hashCode;
}
