import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_order_tracking/live_tracking/live_tracking_controller.dart';
import 'package:live_order_tracking/model/my_order.dart';

class LiveTrackingPage extends StatefulWidget {
  const LiveTrackingPage({super.key});

  @override
  State<LiveTrackingPage> createState() => _LiveTrackingPageState();
}

class _LiveTrackingPageState extends State<LiveTrackingPage> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> arg = Get.arguments;
    MyOrder order = arg['order'];
    //
    return GetBuilder<LiveTrackingController>(
      init: LiveTrackingController(),
      builder: (controller) {
        controller.myOrder = order;
        controller.updateDestinationLocation(order.latitude, order.longitude);
        //
        return Scaffold(
          appBar: AppBar(
            title: const Text("Order Traking"),
          ),
          body: Stack(
            children: [
              GoogleMap(
                // compassEnabled: true,
                // myLocationEnabled: true,
                // myLocationButtonEnabled: true,
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: controller.deliveryboyLocation,
                  zoom: 15,
                ),
                onMapCreated: (mapController) {
                  controller.mapController = mapController;
                  controller.startTracking(order.id);
                },
                markers: {
                  Marker(
                    markerId: const MarkerId('destination'),
                    position: controller.destination,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueBlue),
                    infoWindow: InfoWindow(
                        title: 'Destination',
                        snippet:
                            'Lat: ${controller.destination.latitude} & Lng: ${controller.destination.longitude}'),
                  ),
                  Marker(
                    markerId: const MarkerId('deliveryBoy'),
                    position: controller.deliveryboyLocation,
                    icon: controller.markerIcon,
                    rotation: controller.rotation,
                    infoWindow: InfoWindow(
                        title: 'Delivery boy',
                        snippet:
                            'Lat: ${controller.deliveryboyLocation.latitude} & Lng: ${controller.deliveryboyLocation.longitude}'),
                  ),
                },
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('route'),
                    points: controller.polylineCoordinates,
                    color: Colors.purple,
                    width: 6,
                  ),
                },
              ),

              //

              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.yellowAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                        "Remaining Distance: ${controller.remainingDistance.toStringAsFixed(2)} kilometers"),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
