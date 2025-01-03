import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_order_tracking/ober/ober_controller.dart';

class ConfirmPage extends StatefulWidget {
  const ConfirmPage({super.key});

  @override
  State<ConfirmPage> createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return GetBuilder<OberController>(
      init: OberController(),
      builder: (oberController) {
        return Scaffold(
          body: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0),
              zoom: 10,
            ),
            onMapCreated: (mapController) {
              oberController.mapController = mapController;
              mapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(oberController.pickUp!.latitude,
                        oberController.pickUp!.longitude),
                    zoom: 12,
                  ),
                ),
              );
            },
            markers: {
              Marker(
                markerId: const MarkerId('destination'),
                position: LatLng(oberController.destination!.latitude,
                    oberController.destination!.longitude),
                icon: BitmapDescriptor.defaultMarker,
                infoWindow: InfoWindow(
                    title: 'Destination',
                    snippet:
                        'Lat: ${oberController.destination!.latitude} & Lng: ${oberController.destination!.longitude}'),
              ),
              Marker(
                markerId: const MarkerId('pick up'),
                position: LatLng(
                  oberController.pickUp!.latitude,
                  oberController.pickUp!.longitude,
                ),
                icon: BitmapDescriptor.defaultMarker,
                infoWindow: InfoWindow(
                    title: 'Pick Up',
                    snippet:
                        'Lat: ${oberController.pickUp!.latitude} & Lng: ${oberController.pickUp!.longitude}'),
              ),
            },
            polylines: {
              Polyline(
                polylineId: const PolylineId('route'),
                points: oberController.polylineCoordinates,
                color: Colors.purple,
                width: 6,
              ),
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Pick Up :"),
                  Text(oberController.pickUp!.name),
                  SizedBox(height: size.height / 25),
                  const Text("Destination :"),
                  Text(oberController.destination!.name),
                  SizedBox(height: size.height / 25),
                  const Text("Fare: "),
                  Text("${oberController.fare} MMKS"),
                  SizedBox(height: size.height / 25),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize:
                          Size.fromWidth(MediaQuery.sizeOf(context).width),
                    ),
                    onPressed: () {
                      oberController.bookTaxi(context);
                    },
                    child: const Text("Book Taxi"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
