import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_order_tracking/model/address.dart';
import 'package:live_order_tracking/model/booking.dart';
import 'package:location/location.dart';

class OberController extends GetxController {
  GoogleMapController? mapController;
  final Location location = Location();
  LocationData? currentLocationData;

  //
  Address? destination;
  Address? pickUp;
  List<LatLng> polylineCoordinates = [];
  String? fare;

  //
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late CollectionReference bookingCollection;
  bool isBooking = false;

  @override
  void onInit() {
    getCurrentLocation();
    super.onInit();
  }

  @override
  void dispose() {
    isBooking = false;
    super.dispose();
  }

  void getCurrentLocation() {
    location.onLocationChanged.listen(
      (event) {
        currentLocationData = event;
        update();
      },
    );
  }

  void updateDestinationLocation(
      String name, double latitude, double longitude) {
    destination = Address(name: name, latitude: latitude, longitude: longitude);
    log('Destination: $destination');
  }

  void updatePickUpLocation(String name, double latitude, double longitude) {
    pickUp = Address(name: name, latitude: latitude, longitude: longitude);
    log('Pick Up: $pickUp');
  }

  Future<void> getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: "AIzaSyBtzaTGeBrb0mTh911fAeuv2ZB0eJk8J-M",
      request: PolylineRequest(
        origin: PointLatLng(pickUp!.latitude, pickUp!.longitude),
        destination: PointLatLng(destination!.latitude, destination!.longitude),
        mode: TravelMode.driving,
      ),
    );
    fare = result.distanceValues!.first.toString();
    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();

      for (var point in result.points) {
        polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        );
      }
    }
  }

  void bookTaxi(BuildContext context) async {
    try {
      Booking booking =
          Booking(pickUp: pickUp!, destination: destination!, fare: fare!);
      final bookingJson = booking.toJson();
      bookingCollection = firestore.collection('booking');
      await bookingCollection.add(bookingJson);
      isBooking = true;
    } catch (e) {
      rethrow;
    }
  }
}
