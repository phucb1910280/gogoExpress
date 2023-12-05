import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gogoship/UI/homepage.dart';
import 'package:gogoship/shared/app_constant.dart';
import 'package:gogoship/shared/mcolors.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MyMapView extends StatefulWidget {
  final LatLng coordinates;
  const MyMapView({super.key, required this.coordinates});

  @override
  State<MyMapView> createState() => _MyMapViewState();
}

class _MyMapViewState extends State<MyMapView> {
  var destination = const LatLng(0, 0);
  late http.Response routeResponse;
  List<LatLng> coordinatesRoute = [];

  Dio dio = Dio();

  @override
  void initState() {
    setState(() {
      destination =
          LatLng(widget.coordinates.latitude, widget.coordinates.longitude);
    });
    getCurrentPosition();
    getDataFromResponse();
    super.initState();
    // debugPrint(destination.toString());
    // debugPrint(HomePage.myLocation.toString());
  }

  String url() {
    String t =
        "https://api.openrouteservice.org/v2/directions/cycling-road?api_key=5b3ce3597851110001cf6248d6e6d646bd1d4d92ade68011ed72952e&start=${HomePage.myLocation.longitude},%20${HomePage.myLocation.latitude}&end=${destination.longitude},%20${destination.latitude}";
    return t;
  }

  Future getResponse() async {
    try {
      dio.options.contentType = Headers.jsonContentType;
      final responseData = await dio.get(url());
      return responseData.data;
    } catch (e) {
      print(e);
    }
  }

  Future<void> getDataFromResponse() async {
    final response = await getResponse();
    List t = response["features"][0]["geometry"]["coordinates"];
    for (var element in t) {
      coordinatesRoute.add(LatLng(element[1], element[0]));
    }
  }

  getCurrentPosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    HomePage.myLocation = LatLng(position.latitude, position.longitude);
    // print("1");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Xem đường đi"),
      ),
      body: SizedBox(
        child: FlutterMap(
          options: MapOptions(
            minZoom: 5,
            maxZoom: 18,
            initialZoom: 16,
            initialCenter: HomePage.myLocation,
            keepAlive: true,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  "https://api.mapbox.com/styles/v1/daovinhphuc/clo4fjffs00my01qs9r08er74/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiZGFvdmluaHBodWMiLCJhIjoiY2xvNDZ6b3QyMjFtdDJrczMwM2wwNW1ibSJ9.UcgP416WNtqeZTN-iq7x8Q",
              additionalOptions: const {
                'mapStyleId': AppConstants.mapBoxStyleId,
                'accessToken': AppConstants.mapBoxAccessToken,
              },
            ),
            PolylineLayer(polylines: [
              Polyline(
                points: coordinatesRoute,
                strokeWidth: 6,
                color: MColors.green,
              )
            ]),
            MarkerLayer(
              markers: [
                Marker(
                  point: HomePage.myLocation,
                  child: const Icon(
                    Icons.my_location,
                    size: 35,
                    color: MColors.orange,
                  ),
                  rotate: true,
                ),
                Marker(
                  point: destination,
                  child: const Icon(
                    Icons.location_on,
                    size: 35,
                    color: MColors.error,
                  ),
                  rotate: true,
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async => getCurrentPosition(),
        child: const Icon(Icons.location_searching),
      ),
    );
  }
}
