import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_order_tracking/ober/ober_controller.dart';
import 'package:live_order_tracking/ober/pick_up_page.dart';
import 'package:place_picker_google/place_picker_google.dart';

class OberPage extends StatefulWidget {
  const OberPage({super.key});

  @override
  State<OberPage> createState() => _OberPageState();
}

class _OberPageState extends State<OberPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<OberController>(
      init: OberController(),
      builder: (oberController) {
        return oberController.currentLocationData == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Scaffold(
                body: PlacePicker(
                  apiKey: 'AIzaSyBtzaTGeBrb0mTh911fAeuv2ZB0eJk8J-M',
                  onPlacePicked: (LocationResult result) {
                    log(result.formattedAddress!);
                    oberController.updateDestinationLocation(
                        result.formattedAddress!,
                        result.latLng!.latitude,
                        result.latLng!.longitude);
                    Get.to(() => const PickUpPage());
                  },
                  onMapCreated: (controller) {
                    controller.animateCamera(
                      CameraUpdate.newCameraPosition(CameraPosition(
                        target: LatLng(
                            oberController.currentLocationData!.latitude!,
                            oberController.currentLocationData!.longitude!),
                        zoom: 15,
                      )),
                    );
                  },
                  initialLocation: LatLng(
                      oberController.currentLocationData!.latitude!,
                      oberController.currentLocationData!.longitude!),
                  searchInputConfig: const SearchInputConfig(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    autofocus: false,
                    textDirection: TextDirection.ltr,
                  ),
                  searchInputDecorationConfig:
                      const SearchInputDecorationConfig(
                    hintText: "Search for a building, street or ...",
                  ),
                  enableNearbyPlaces: false,
                  myLocationButtonEnabled: true,
                  usePinPointingSearch: true,
                  minMaxZoomPreference: const MinMaxZoomPreference(1, 16),
                  myLocationEnabled: true,
                  showSearchInput: true,
                  autoCompleteOverlayElevation: 10,
                  autocompletePlacesSearchRadius: 10,
                  pinPointingDebounceDuration: 0,
                  selectedActionButtonChild: const Text("Confirm destination"),
                ),
              );
      },
    );
  }
}
