import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_order_tracking/add_order/add_order_controller.dart';
import 'package:live_order_tracking/order_list/order_list_page.dart';

class AddOrderPage extends StatefulWidget {
  const AddOrderPage({super.key});

  @override
  State<AddOrderPage> createState() => _AddOrderPageState();
}

class _AddOrderPageState extends State<AddOrderPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddOrderController>(
      init: AddOrderController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Add Order"),
            actions: [
              IconButton(
                  onPressed: () {
                    Get.to(const OrderListPage());
                  },
                  icon: const Icon(Icons.list)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.map))
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                TextField(
                  controller: controller.orderIdController,
                  decoration: const InputDecoration(labelText: "Order ID"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.nameController,
                  decoration: const InputDecoration(labelText: "Customer Name"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.phoneController,
                  decoration:
                      const InputDecoration(labelText: "Customer Phone"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.addressController,
                  decoration:
                      const InputDecoration(labelText: "Customer Address"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.amountController,
                  decoration: const InputDecoration(labelText: "Bill Amount"),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 380,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: GoogleMap(
                    compassEnabled: true,
                    mapType: MapType.normal,
                    myLocationButtonEnabled: true,
                    myLocationEnabled: true,
                    initialCameraPosition:
                        const CameraPosition(target: LatLng(0, 0), zoom: 15),
                    onMapCreated: (mapController) {
                      controller.mapController = mapController;
                    },
                    onTap: (argument) {
                      controller.selectedLocation = argument;
                      controller.update();
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId('selectedLocation'),
                        position: controller.selectedLocation,
                        infoWindow: InfoWindow(
                          title: "selected location",
                          snippet:
                              "Lat : ${controller.selectedLocation.latitude} , Lng : ${controller.selectedLocation.longitude}",
                        ),
                      ),
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: () {
                      controller.addOrder(context);
                    },
                    child: const Text("Submit Order")),
              ],
            ),
          ),
        );
      },
    );
  }
}
