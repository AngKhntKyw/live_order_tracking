import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_order_tracking/model/my_order.dart';

class AddOrderController extends GetxController {
  TextEditingController orderIdController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  GoogleMapController? mapController;
  LatLng currentLocation = const LatLng(0, 0);
  LatLng selectedLocation = const LatLng(0, 0);

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late CollectionReference orderCollection;

  @override
  Future<void> onInit() async {
    orderCollection = firestore.collection('order');
    super.onInit();
  }

  void addOrder(BuildContext context) {
    try {
      if (nameController.text.isEmpty ||
          orderIdController.text.isEmpty ||
          amountController.text.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Please fill fileds")));
        return;
      } else {
        DocumentReference doc = orderCollection.doc(orderIdController.text);
        MyOrder order = MyOrder(
          id: orderIdController.text,
          name: nameController.text,
          phone: phoneController.text,
          address: addressController.text,
          latitude: selectedLocation.latitude,
          longitude: selectedLocation.longitude,
          amount: double.parse(amountController.text),
        );
        final orderJson = order.toJson();
        doc.set(orderJson);
        clearTextFields();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Order added successfully.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Fail to add order.")));
      rethrow;
    }
  }

  void clearTextFields() {
    orderIdController.clear();
    nameController.clear();
    phoneController.clear();
    addressController.clear();
    amountController.clear();
  }
}
