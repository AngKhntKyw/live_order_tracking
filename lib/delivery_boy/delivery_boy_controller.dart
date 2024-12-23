import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_order_tracking/model/my_order.dart';
import 'package:location/location.dart';

class DeliveryBoyController extends GetxController {
  TextEditingController orderIdController = TextEditingController();
  final Location location = Location();

  String deliveryAddress = '';
  String phoneNumber = '';
  String amountToCollect = '';
  double customerLatitude = 37.7749;
  double customerLongitude = -122.4194;
  bool showDeliveryInfo = false;
  bool isDeliveryStarted = false;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late final CollectionReference orderCollection;
  late final CollectionReference orderTrackingCollection;

  @override
  void onInit() {
    orderCollection = firestore.collection('order');
    orderTrackingCollection = firestore.collection('orderTracking');
    getLocationPermission();
    super.onInit();
  }

  getOrderById() async {
    try {
      String orderId = orderIdController.text;
      QuerySnapshot querySnapshot =
          await orderCollection.where('id', isEqualTo: orderId).get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        MyOrder? order = MyOrder.fromJson(data);

        deliveryAddress = order.address;
        phoneNumber = order.phone.toString();
        amountToCollect = order.amount.toString();
        customerLatitude = order.latitude;
        customerLongitude = order.longitude;
        showDeliveryInfo = true;

        update();
      } else {
        Get.snackbar(
          "Error",
          "Order not found.",
          overlayBlur: 0,
          barBlur: 0,
          backgroundColor: Colors.purple,
          colorText: Colors.white,
          dismissDirection: DismissDirection.horizontal,
        );
        return null;
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        overlayBlur: 0,
        barBlur: 0,
        backgroundColor: Colors.purple,
        colorText: Colors.white,
        dismissDirection: DismissDirection.horizontal,
      );
      rethrow;
    }
  }

  Future<void> getLocationPermission() async {
    try {
      bool serviceEnabled = await location.serviceEnabled();

      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }
      PermissionStatus permissionStatus = await location.hasPermission();

      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await location.requestPermission();
        if (permissionStatus != PermissionStatus.granted) {
          return;
        }
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        overlayBlur: 0,
        barBlur: 0,
        backgroundColor: Colors.purple,
        colorText: Colors.white,
        dismissDirection: DismissDirection.horizontal,
      );
    }
  }

  void startDelivery() async {
    location.onLocationChanged.listen(
      (currentLocation) {
        saveOrUpdateMyOrderLocation(
          orderIdController.text,
          currentLocation.latitude!,
          currentLocation.longitude!,
        );
      },
    );
    location.enableBackgroundMode(enable: true);
  }

  Future<void> saveOrUpdateMyOrderLocation(
      String orderId, double latitude, double longitude) async {
    try {
      final DocumentReference docRef = orderTrackingCollection.doc(orderId);
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
                'orderId': orderId,
                'latitude': latitude,
                'longitude': longitude,
              },
            );
          }
        },
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        overlayBlur: 0,
        barBlur: 0,
        backgroundColor: Colors.purple,
        colorText: Colors.white,
        dismissDirection: DismissDirection.horizontal,
      );
    }
  }
}
