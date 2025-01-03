import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_order_tracking/go_to_pick_up/go_to_pick_up_controller.dart';
import 'package:live_order_tracking/model/booking.dart';

class GoToPickUpPage extends StatefulWidget {
  final Booking booking;

  const GoToPickUpPage({super.key, required this.booking});

  @override
  State<GoToPickUpPage> createState() => _GoToPickUpPageState();
}

class _GoToPickUpPageState extends State<GoToPickUpPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return GetBuilder<GoToPickUpController>(
      init: GoToPickUpController(),
      builder: (goToPickUpController) {
        goToPickUpController.acceptBooking(widget.booking);
        //
        return Scaffold(
          body: goToPickUpController.currentLocationData == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      goToPickUpController.currentLocationData!.latitude!,
                      goToPickUpController.currentLocationData!.longitude!,
                    ),
                    zoom: 10,
                  ),
                  onMapCreated: (controller) {
                    goToPickUpController.mapController = controller;
                    controller.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(
                            goToPickUpController.currentLocationData!.latitude!,
                            goToPickUpController
                                .currentLocationData!.longitude!,
                          ),
                          zoom: 15,
                        ),
                      ),
                    );
                  },
                  onCameraMove: (position) {
                    goToPickUpController.onCameraMove(position);
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId('driver'),
                      position: LatLng(
                        goToPickUpController.currentLocationData!.latitude!,
                        goToPickUpController.currentLocationData!.longitude!,
                      ),
                      icon: goToPickUpController.markerIcon,
                      rotation: goToPickUpController.markerRotation,
                      anchor: const Offset(0.5, 0.5),
                    ),
                    if (goToPickUpController.pickUpMarker != null &&
                        !goToPickUpController.goingToDestination)
                      goToPickUpController.pickUpMarker!,
                    if (goToPickUpController.destinationMarker != null)
                      goToPickUpController.destinationMarker!,
                  },
                  polylines: {
                    if (goToPickUpController.polylineCoordinates.isNotEmpty)
                      Polyline(
                        polylineId: const PolylineId('route'),
                        points: goToPickUpController.polylineCoordinates,
                        color: Colors.purple,
                      )
                  },
                ),
          bottomSheet: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 0.1,
                  spreadRadius: 0.1,
                ),
              ],
            ),
            height: size.height / 2.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Pick Up :"),
                Text(widget.booking.pickUp.name),
                SizedBox(height: size.height / 25),
                const Text("Destination :"),
                Text(widget.booking.destination.name),
                SizedBox(height: size.height / 25),
                const Text("Fare: "),
                Text("${widget.booking.fare} MMKS"),
                SizedBox(height: size.height / 25),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size.fromWidth(MediaQuery.sizeOf(context).width),
                  ),
                  onPressed: () {
                    goToPickUpController.goingToDestination
                        ? showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Compelete Ride"),
                                content: const Text("Complete Ride?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Get.back();
                                      Get.back();
                                    },
                                    child: const Text("Drop Off"),
                                  ),
                                ],
                              );
                            },
                          )
                        : goToPickUpController.goToDestination();
                  },
                  child: Text(
                    goToPickUpController.goingToDestination
                        ? "Drop Off"
                        : "Let's Go",
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
