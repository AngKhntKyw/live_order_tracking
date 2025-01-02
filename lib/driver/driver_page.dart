import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_order_tracking/driver/driver_controller.dart';
import 'package:live_order_tracking/go_to_pick_up/go_to_pick_up_page.dart';

class DriverPage extends StatefulWidget {
  const DriverPage({super.key});

  @override
  State<DriverPage> createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  @override
  Widget build(BuildContext context) {
    log("Build");
    return GetBuilder<DriverController>(
      init: DriverController(),
      builder: (driverController) {
        return driverController.currentLocationData == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Scaffold(
                body: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          driverController.currentLocationData!.latitude!,
                          driverController.currentLocationData!.longitude!,
                        ),
                        zoom: 10,
                      ),
                      onMapCreated: (controller) {
                        driverController.mapController = controller;
                        controller.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(
                                driverController.currentLocationData!.latitude!,
                                driverController
                                    .currentLocationData!.longitude!,
                              ),
                              zoom: 15,
                            ),
                          ),
                        );
                      },
                      onCameraMove: (position) {
                        driverController.onCameraMove(position);
                      },
                      markers: {
                        Marker(
                          markerId: const MarkerId('driver'),
                          position: LatLng(
                            driverController.currentLocationData!.latitude!,
                            driverController.currentLocationData!.longitude!,
                          ),
                          icon: driverController.markerIcon,
                          rotation: driverController.markerRotation,
                          anchor: const Offset(0.5, 0.5),
                        ),
                        ...driverController.markers,
                      },
                      circles: driverController.circles,
                    ),
                    DraggableScrollableSheet(
                      initialChildSize: 0.2,
                      maxChildSize: 1,
                      minChildSize: 0.2,
                      expand: true,
                      builder: (context, scrollController) {
                        return Container(
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              )),
                          child: driverController.clients.isEmpty
                              ? const Center(
                                  child: Text("There is no booking!"))
                              : SingleChildScrollView(
                                  controller: scrollController,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        title: Text(
                                            "Total Bookings : ${driverController.clients.length}"),
                                      ),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        itemCount:
                                            driverController.clients.length,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          final booking = driverController
                                              .clients
                                              .elementAt(index);
                                          return Column(
                                            children: [
                                              ListTile(
                                                title: Column(
                                                  children: [
                                                    Text(booking.pickUp.name),
                                                    Text(booking
                                                        .destination.name),
                                                  ],
                                                ),
                                                trailing: Text(
                                                    "${booking.fare} Kyats"),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  fixedSize: Size.fromWidth(
                                                      MediaQuery.sizeOf(context)
                                                          .width),
                                                ),
                                                onPressed: () {
                                                  Get.to(() => GoToPickUpPage(
                                                      booking: booking));
                                                },
                                                child: const Text(
                                                    "Accept booking"),
                                              ),
                                              const Divider(),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                        );
                      },
                    ),
                  ],
                ),
              );
      },
    );
  }
}
