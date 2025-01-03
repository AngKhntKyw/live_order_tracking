import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compassx/compassx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_order_tracking/model/booking.dart';
import 'package:live_order_tracking/model/driver.dart';
import 'package:location/location.dart';

class DriverController extends GetxController {
  GoogleMapController? mapController;
  final Location location = Location();
  LocationData? currentLocationData;
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  double markerRotation = 0.0;
  double compassHeading = 0.0;
  double positionBearing = 0.0;
  Set<Booking> clients = {};
  Set<Marker> markers = {};
  Set<Circle> circles = {};
  List<LatLng> polylineCoordinates = [];
  Booking? booking;
  String state = '';

  //

  //

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late final CollectionReference driverCollection;
  late CollectionReference bookingCollection;

  @override
  void onInit() {
    driverCollection = firestore.collection('driver');
    bookingCollection = firestore.collection('booking');
    clients.clear();
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
        update();
        saveOrUpdateDriverLocation(event.latitude!, event.longitude!);
        booking != null
            ? getDestinationPolyPoints(
                event.latitude!, event.longitude!, booking!)
            : null;
        List<Booking> bookings = await getBookings();
        for (Booking booking in bookings) {
          markers.add(Marker(
            markerId: MarkerId(booking.pickUp.name),
            position: LatLng(booking.pickUp.latitude, booking.pickUp.longitude),
            icon: BitmapDescriptor.defaultMarker,
          ));
          log("Clients: ${clients.length.toString()}");

          circles.add(Circle(
            circleId: CircleId(booking.pickUp.name),
            center: LatLng(booking.pickUp.latitude, booking.pickUp.longitude),
            radius: 1000,
            fillColor: Colors.blue.withOpacity(0.2),
            strokeColor: Colors.blue,
            strokeWidth: 1,
          ));

          bool isWithin1km = checkDistanceWithin1km(
            event.latitude!,
            event.longitude!,
            booking.pickUp.latitude,
            booking.pickUp.longitude,
          );
          if (isWithin1km) {
            log("Booking is within 1 km.");
            clients.contains(booking) ? log("Contained") : clients.add(booking);
          } else {
            log("Booking is too far.");
            clients.remove(booking);
          }
        }
      },
    );
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
      updateDriverRotation();
    });
  }

  void onCameraMove(CameraPosition position) {
    positionBearing = position.bearing;
    markerRotation = (compassHeading - position.bearing) % 360;

    if (markerRotation < 0) {
      markerRotation += 360;
    }
    update();
    updateDriverRotation();
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

  bool checkDistanceWithin1km(double driverLat, double driverLng,
      double bookingLat, double bookingLng) {
    double distanceInMeters = Geolocator.distanceBetween(
      driverLat,
      driverLng,
      bookingLat,
      bookingLng,
    );

    return distanceInMeters <= 1000;
  }

  Future<List<Booking>> getBookings() async {
    final querySnapshot = await bookingCollection.get();

    final bookings = querySnapshot.docs.map((doc) {
      return Booking.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();
    return bookings;
  }

  void acceptBooking(Booking bk) async {
    booking = bk;
    state = 'goingToPickUp';
    await bookingCollection.doc("CHatPH4zfUVrAedu9bH3").update({
      'driver': Driver(
        driverId: 'D001',
        latitude: currentLocationData!.latitude!,
        longitude: currentLocationData!.longitude!,
        rotation: markerRotation,
      ).toJson(),
      'state': 'goingToPickUp'
    });
  }

  Future<void> getDestinationPolyPoints(
      double latitude, double longitude, Booking booking) async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: "AIzaSyBtzaTGeBrb0mTh911fAeuv2ZB0eJk8J-M",
      request: PolylineRequest(
        origin: PointLatLng(latitude, longitude),
        destination:
            PointLatLng(booking.pickUp.latitude, booking.pickUp.longitude),
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
}
