import 'dart:math';
import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_order_tracking/model/my_order.dart';
import 'package:location/location.dart';

class LiveTrackingController extends GetxController {
  MyOrder? myOrder;

  String orderId = '0000';
  LatLng destination = const LatLng(0, 0);
  LatLng deliveryboyLocation = const LatLng(0, 0);
  GoogleMapController? mapController;
  BitmapDescriptor markerIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
  double remainingDistance = 0;
  final Location location = Location();
  List<LatLng> polylineCoordinates = [];
  double rotation = 0;
  LatLng? previousDeliveryBoyLocation;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late CollectionReference orderTrackingCollection;

  @override
  void onInit() {
    orderTrackingCollection = firestore.collection('orderTracking');
    addCustomMarker();
    super.onInit();
  }

  void addCustomMarker() {
    BitmapDescriptor.asset(
      ImageConfiguration.empty,
      "assets/images/car.png",
      height: 30,
      width: 30,
    ).then(
      (value) {
        markerIcon = value;
      },
    );
  }

  void updateDestinationLocation(double latitude, double longitude) {
    destination = LatLng(latitude, longitude);
    update();
  }

  void startTracking(String orderId) {
    try {
      if (mapController != null) {
        orderTrackingCollection.doc(orderId).snapshots().listen(
          (snapshot) {
            if (snapshot.exists) {
              var trackingData = snapshot.data() as Map<String, dynamic>;
              double latitude = trackingData['latitude'];
              double longitude = trackingData['longitude'];
              updateUIWithLocation(latitude, longitude);
            } else {
              Get.snackbar(
                "Error",
                "No tracking data found",
                overlayBlur: 0,
                icon: const Icon(Icons.error),
                backgroundColor: Colors.purple,
                colorText: Colors.white,
                dismissDirection: DismissDirection.horizontal,
              );
            }
          },
        );
      } else {
        Get.snackbar(
          "Error",
          "Map Controller is null",
          overlayBlur: 0,
          icon: const Icon(Icons.error),
          backgroundColor: Colors.purple,
          colorText: Colors.white,
          dismissDirection: DismissDirection.horizontal,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  void updateUIWithLocation(double latitude, double longitude) async {
    deliveryboyLocation = LatLng(latitude, longitude);

    if (previousDeliveryBoyLocation != null) {
      calculateRotation(previousDeliveryBoyLocation!, deliveryboyLocation);
    }
    await getPolyPoints(latitude, longitude);
    mapController?.animateCamera(CameraUpdate.newLatLng(deliveryboyLocation));
    calculateRemainingDistance();
    previousDeliveryBoyLocation = LatLng(latitude, longitude);
  }

  void calculateRemainingDistance() {
    double distance = Geolocator.distanceBetween(
      deliveryboyLocation.latitude,
      deliveryboyLocation.longitude,
      destination.latitude,
      destination.longitude,
    );

    double distanceInKm = distance / 1000;
    remainingDistance = distanceInKm;
    update();
  }

  Future<void> getPolyPoints(double latitude, double longitude) async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: "AIzaSyBtzaTGeBrb0mTh911fAeuv2ZB0eJk8J-M",
      request: PolylineRequest(
        origin: PointLatLng(latitude, longitude),
        destination: PointLatLng(destination.latitude, destination.longitude),
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

  void calculateRotation(LatLng start, LatLng end) {
    double latDiff = end.latitude - start.latitude;
    double lngDiff = end.longitude - start.longitude;
    double angle = atan2(lngDiff, latDiff);
    rotation = angle * 180 / pi;
    dev.log(rotation.toString());
    update();
  }
}
