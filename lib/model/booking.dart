import 'package:live_order_tracking/model/address.dart';
import 'package:live_order_tracking/model/driver.dart';

class Booking {
  String bookingId;
  Address pickUp;
  Address destination;
  String fare;
  Driver? driver;
  String state;

  Booking({
    required this.bookingId,
    required this.pickUp,
    required this.destination,
    required this.fare,
    this.driver,
    required this.state,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        bookingId: json['bookingId'],
        pickUp: Address.fromJson(json['pickUp']),
        destination: Address.fromJson(json['destination']),
        fare: json['fare'],
        driver: json['driver'] != null ? Driver.fromJson(json['driver']) : null,
        state: json['state'],
      );

  Map<String, dynamic> toJson() => {
        'bookingId': bookingId,
        'pickUp': pickUp.toJson(),
        'destination': destination.toJson(),
        'fare': fare,
        'driver': driver!.toJson(),
        'state': state,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Booking &&
          bookingId == other.bookingId &&
          pickUp == other.pickUp &&
          destination == other.destination &&
          fare == other.fare &&
          driver == other.driver &&
          state == other.state;

  @override
  int get hashCode =>
      bookingId.hashCode ^
      pickUp.hashCode ^
      destination.hashCode ^
      fare.hashCode ^
      driver.hashCode ^
      state.hashCode;
}
