import 'dart:developer';
import 'package:compassx/compassx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Location location = Location();
  LocationData? currentLocationData;
  GoogleMapController? mapController;
  double markerRotation = 0.0;
  double compassHeading = 0.0;
  BitmapDescriptor markerIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
  List<LatLng> route = [];
  String? status;
  List<String> duration = [];
  double positionBearing = 0.0;

  @override
  void initState() {
    fetchPermissionStatus();
    getCurrentLocation();
    addCustomMarker();
    changeCompass();

    super.initState();
  }

  void fetchPermissionStatus() async {
    final permission = await Permission.locationWhenInUse.status;
    log(permission.isGranted.toString());
  }

  void getCurrentLocation() {
    location.getLocation().then(
      (value) {
        setState(() {
          log(value.toString());
          currentLocationData = value;
        });
      },
    );
  }

  void changeLocation() {
    location.onLocationChanged.listen(
      (event) {
        setState(() {
          currentLocationData = event;
        });
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

  void getRoute() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: "AIzaSyBtzaTGeBrb0mTh911fAeuv2ZB0eJk8J-M",
      request: PolylineRequest(
        origin: PointLatLng(
            currentLocationData!.latitude!, currentLocationData!.longitude!),
        destination: const PointLatLng(16.849640, 96.129215),
        mode: TravelMode.driving,
        alternatives: true,
      ),
    );
    if (result.points.isNotEmpty) {
      route.clear();
      for (var point in result.points) {
        setState(() {
          route.add(
            LatLng(point.latitude, point.longitude),
          );
        });
      }
    }
  }

  void changeCompass() {
    CompassX.events.listen((event) {
      log("Compass Heading: ${event.heading}");
      setState(() {
        compassHeading = event.heading;
        markerRotation = (compassHeading - positionBearing) % 360;

        if (markerRotation < 0) {
          markerRotation += 360;
        }
      });
    });
  }

  void onCameraMove(CameraPosition position) {
    setState(() {
      positionBearing = position.bearing;
      markerRotation = (compassHeading - position.bearing) % 360;

      if (markerRotation < 0) {
        markerRotation += 360;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return currentLocationData == null
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : SafeArea(
            child: Scaffold(
              body: Stack(
                alignment: Alignment.center,
                children: [
                  GoogleMap(
                    onCameraMove: (position) {
                      onCameraMove(position);
                    },
                    initialCameraPosition: CameraPosition(
                      target: LatLng(currentLocationData!.latitude!,
                          currentLocationData!.longitude!),
                      zoom: 10,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                      controller.animateCamera(CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(currentLocationData!.latitude!,
                              currentLocationData!.longitude!),
                          zoom: 15,
                        ),
                      ));

                      getRoute();
                    },
                    markers: {
                      const Marker(
                        markerId: MarkerId('destination'),
                        position: LatLng(16.849640, 96.129215),
                        icon: BitmapDescriptor.defaultMarker,
                      ),
                      Marker(
                        markerId: const MarkerId('myLocation'),
                        position: LatLng(currentLocationData!.latitude!,
                            currentLocationData!.longitude!),
                        rotation: markerRotation,
                        icon: markerIcon,
                        anchor: const Offset(0.5, 0.5),
                      ),
                    },
                    polylines: {
                      Polyline(
                        polylineId: const PolylineId('route'),
                        points: route,
                        color: Colors.red,
                        width: 8,
                      ),
                    },
                    // cameraTargetBounds: CameraTargetBounds.unbounded,
                    mapType: MapType.normal,
                    trafficEnabled: true,
                  ),
                  //
                  // Positioned(
                  //   child: PlacePicker(
                  //     apiKey: 'AIzaSyBtzaTGeBrb0mTh911fAeuv2ZB0eJk8J-M',
                  //     onPlacePicked: (LocationResult result) {
                  //       log("Place picked: ${result.formattedAddress}");
                  //     },
                  //     onMapCreated: (controller) {
                  //       controller.animateCamera(
                  //         CameraUpdate.newCameraPosition(CameraPosition(
                  //           target: LatLng(currentLocationData!.latitude!,
                  //               currentLocationData!.longitude!),
                  //           zoom: 10,
                  //         )),
                  //       );
                  //     },
                  //     initialLocation: LatLng(currentLocationData!.latitujde!,
                  //         currentLocationData!.longitude!),
                  //     searchInputConfig: const SearchInputConfig(
                  //       padding: EdgeInsets.symmetric(
                  //         horizontal: 16.0,
                  //         vertical: 8.0,
                  //       ),
                  //       autofocus: false,
                  //       textDirection: TextDirection.ltr,
                  //     ),
                  //     searchInputDecorationConfig:
                  //         const SearchInputDecorationConfig(
                  //       hintText: "Search for a building, street or ...",
                  //     ),
                  //     enableNearbyPlaces: true,
                  //     myLocationButtonEnabled: true,
                  //     usePinPointingSearch: true,
                  //     minMaxZoomPreference: const MinMaxZoomPreference(1, 20),
                  //     myLocationEnabled: true,
                  //     showSearchInput: true,
                  //     autoCompleteOverlayElevation: 10,
                  //     autocompletePlacesSearchRadius: 10,
                  //     pinPointingDebounceDuration: 0,
                  //   ),
                  // ),
                ],
              ),
            ),
          );
  }
}



    //  ElevatedButton(
    //               onPressed: () {
    //                 var googlePlace = gp.GooglePlace(
    //                     "AIzaSyBtzaTGeBrb0mTh911fAeuv2ZB0eJk8J-M");
    //                 googlePlace.search
    //                     .getNearBySearch(
    //                         gp.Location(
    //                             lat: currentLocationData!.latitude!,
    //                             lng: currentLocationData!.longitude),
    //                         1500,
    //                         type: "hotel",
    //                         keyword: "hotel")
    //                     .then(
    //                   (value) {
    //                     log(value == null
    //                         ? "NULL"
    //                         : value.results!.length.toString());
    //                     if (value != null && mounted) {
    //                       showModalBottomSheet(
    //                         context: context,
    //                         builder: (context) {
    //                           return Container(
    //                             width: MediaQuery.sizeOf(context).width,
    //                             color: Colors.white,
    //                             alignment: Alignment.center,
    //                             child: ListView.builder(
    //                               itemCount: value.results!.length,
    //                               itemBuilder: (context, index) {
    //                                 return Column(
    //                                   children: [
    //                                     ListTile(
    //                                       leading: CircleAvatar(
    //                                         backgroundImage: NetworkImage(
    //                                           value.results![index].icon!,
    //                                         ),
    //                                       ),
    //                                       title:
    //                                           Text(value.results![index].name!),
    //                                       // subtitle: Text(value.results![index]
    //                                       //         .openingHours!.openNow!
    //                                       //     ? "Open"
    //                                       //     : "Close"),
    //                                     ),
    //                                     // Text(value
    //                                     //     .results![index].photos!.length
    //                                     //     .toString()),
    //                                     // SizedBox(
    //                                     //   height: 200,
    //                                     //   child: ListView.builder(
    //                                     //     scrollDirection: Axis.horizontal,
    //                                     //     itemCount: value
    //                                     //         .results![index].photos!.length,
    //                                     //     itemBuilder: (context, idx) {
    //                                     //       return FutureBuilder(
    //                                     //         future: googlePlace.photos.get(
    //                                     //           photoReference: value
    //                                     //               .results![index]
    //                                     //               .photos![idx]
    //                                     //               .photoReference!,
    //                                     //           maxHeight: null,
    //                                     //           maxWidth: 400,
    //                                     //         ),
    //                                     //         builder: (context, snapshot) {
    //                                     //           if (snapshot
    //                                     //                   .connectionState ==
    //                                     //               ConnectionState.waiting) {
    //                                     //             return const Center(
    //                                     //               child:
    //                                     //                   CircularProgressIndicator(),
    //                                     //             );
    //                                     //           } else if (snapshot
    //                                     //               .hasError) {
    //                                     //             return const Center(
    //                                     //               child: Text("Error"),
    //                                     //             );
    //                                     //           }

    //                                     //           Uint8List image =
    //                                     //               snapshot.data!;
    //                                     //           return Image.memory(
    //                                     //             image,
    //                                     //             errorBuilder: (context,
    //                                     //                     error,
    //                                     //                     stackTrace) =>
    //                                     //                 const Icon(Icons.info),
    //                                     //           );
    //                                     //         },
    //                                     //       );
    //                                     //     },
    //                                     //   ),
    //                                     // ),
    //                                     const Divider(),
    //                                   ],
    //                                 );
    //                               },
    //                             ),
    //                           );
    //                         },
    //                       );
    //                     }
    //                   },
    //                 );
    //               },
    //               child: const Text("Search"),
    //             ),
           