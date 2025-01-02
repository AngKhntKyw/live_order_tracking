import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compassx/compassx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_order_tracking/model/booking.dart';
import 'package:location/location.dart';

class GoToPickUpController extends GetxController {
  GoogleMapController? mapController;
  final Location location = Location();
  LocationData? currentLocationData;
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  double markerRotation = 0.0;
  double compassHeading = 0.0;
  double positionBearing = 0.0;
  Booking? booking;
  Marker? pickUpMarker;
  Marker? destinationMarker;
  List<LatLng> polylineCoordinates = [];
  bool goingToDestination = false;

  //

  //

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late final CollectionReference driverCollection;

  @override
  void onInit() {
    driverCollection = firestore.collection('driver');
    getCurrentLocation();
    addCustomMarker();
    changeCompass();
    super.onInit();
  }

  void getCurrentLocation() {
    location.onLocationChanged.listen(
      (event) async {
        currentLocationData = event;
        mapController?.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(event.latitude!, event.longitude!), zoom: 15)));
        goingToDestination
            ? getDestinationPolyPoints(event.latitude!, event.longitude!)
            : getPickUpPolyPoints(event.latitude!, event.longitude!);
        update();
        // saveOrUpdateDriverLocation(event.latitude!, event.longitude!);
      },
    );
  }

  void acceptBooking(Booking book) {
    booking = book;
    pickUpMarker = Marker(
      markerId: const MarkerId('pick up'),
      position: LatLng(booking!.pickUp.latitude, booking!.pickUp.longitude),
      icon: BitmapDescriptor.defaultMarker,
    );
  }

  Future<void> getPickUpPolyPoints(double latitude, double longitude) async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: "AIzaSyBtzaTGeBrb0mTh911fAeuv2ZB0eJk8J-M",
      request: PolylineRequest(
        origin: PointLatLng(latitude, longitude),
        destination:
            PointLatLng(booking!.pickUp.latitude, booking!.pickUp.longitude),
        mode: TravelMode.driving,
      ),
    );
    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();

      for (var point in result.points) {
        polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        );
      }
    }
  }

  Future<void> getDestinationPolyPoints(
      double latitude, double longitude) async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: "AIzaSyBtzaTGeBrb0mTh911fAeuv2ZB0eJk8J-M",
      request: PolylineRequest(
        origin: PointLatLng(latitude, longitude),
        destination: PointLatLng(
            booking!.destination.latitude, booking!.destination.longitude),
        mode: TravelMode.driving,
      ),
    );
    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();

      for (var point in result.points) {
        polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        );
      }
    }
  }

  void addCustomMarker() {
    BitmapDescriptor.asset(
      ImageConfiguration.empty,
      "assets/images/car.png",
      height: 50,
      width: 50,
    ).then(
      (value) {
        markerIcon = value;
      },
    );
  }

  void changeCompass() {
    CompassX.events.listen((event) {
      compassHeading = event.heading;
      markerRotation = (compassHeading - positionBearing) % 360;

      if (markerRotation < 0) {
        markerRotation += 360;
      }
      update();
      // updateDriverRotation();
    });
  }

  void onCameraMove(CameraPosition position) {
    positionBearing = position.bearing;
    markerRotation = (compassHeading - position.bearing) % 360;

    if (markerRotation < 0) {
      markerRotation += 360;
    }
    update();
    // updateDriverRotation();
  }

  Future<void> saveOrUpdateDriverLocation(
      double latitude, double longitude) async {
    try {
      final DocumentReference docRef = driverCollection.doc("D001");
      await firestore.runTransaction(
        (transaction) async {
          final DocumentSnapshot snapshot = await transaction.get(docRef);

          if (snapshot.exists) {
            transaction.update(
              docRef,
              {
                'latitude': latitude,
                'longitude': longitude,
              },
            );
          } else {
            transaction.set(
              docRef,
              {
                'driverId': "D001",
                'latitude': latitude,
                'longitude': longitude,
                'rotation': markerRotation,
              },
            );
          }
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateDriverRotation() async {
    try {
      final DocumentReference docRef = driverCollection.doc("D001");
      await firestore.runTransaction(
        (transaction) async {
          final DocumentSnapshot snapshot = await transaction.get(docRef);

          if (snapshot.exists) {
            transaction.update(
              docRef,
              {
                'rotation': markerRotation,
              },
            );
          } else {
            transaction.set(
              docRef,
              {
                'driverId': "D001",
                'latitude': 0.0,
                'longitude': 0.0,
                'rotation': markerRotation,
              },
            );
          }
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  void goToDestination() {
    goingToDestination = true;
    pickUpMarker = null;
    destinationMarker = Marker(
      markerId: const MarkerId('destination'),
      position:
          LatLng(booking!.destination.latitude, booking!.destination.longitude),
      icon: BitmapDescriptor.defaultMarker,
    );
    update();
  }
}
