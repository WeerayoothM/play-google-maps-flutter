import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_map_tutorial/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();
  TextEditingController _originController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();

  Set<Marker> _markers = Set<Marker>();
  Set<Polygon> _polygons = Set<Polygon>();
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polygonLatLngs = <LatLng>[];

  int _polygonIdCounter = 1;
  int _polylineIdCounter = 1;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(13.8330232, 100.5018732),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _setMarker(LatLng(13.8330232, 100.5018732));
  }

  void _setMarker(LatLng point) {
    setState(() {
      _markers.add(Marker(markerId: MarkerId('marker'), position: point));
    });
  }

  void _setPolygon() {
    final String polygonIdVal = 'polygon_$_polygonIdCounter';
    _polygonIdCounter++;

    _polygons = {
      Polygon(
          polygonId: PolygonId(polygonIdVal),
          points: polygonLatLngs,
          strokeWidth: 2,
          fillColor: Colors.transparent)
    };
  }

  void _setPolyline(List<PointLatLng> points) {
    final String polylineIdVal = 'polygon_$_polygonIdCounter';
    _polylineIdCounter++;

    _polylines.add(Polyline(
        polylineId: PolylineId(polylineIdVal),
        width: 2,
        color: Colors.blue,
        points: points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList()));
  }

  // static final CameraPosition _kLake = CameraPosition(
  //     bearing: 192.8334901395799,
  //     target: LatLng(13.8330232, 100.5018732),
  //     tilt: 19.440717697143555,
  //     zoom: 19.151926040649414);

  // static final Marker _kGooglePlexMarker = Marker(
  //     markerId: MarkerId("_kGooglePlex"),
  //     infoWindow: InfoWindow(title: 'Google Plex'),
  //     icon: BitmapDescriptor.defaultMarker,
  //     position: LatLng(13.8329900, 100.5018732));

  // static final Marker _kGoogleLakeMarker = Marker(
  //     markerId: MarkerId("_kGoogleLakeMarker"),
  //     infoWindow: InfoWindow(title: 'Lake Plex'),
  //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
  //     position: LatLng(13.8339232, 100.4946732));

  // static final Polyline _kPolyline = Polyline(
  //     polylineId: PolylineId('_kPolyline'),
  //     points: [
  //       LatLng(13.8329900, 100.5018732),
  //       LatLng(13.8339232, 100.4946732)
  //     ],
  //     width: 5);

  static final Polygon _kPolygon = Polygon(
      polygonId: PolygonId('_kPolygon'),
      points: [
        LatLng(13.8329900, 100.5018732),
        LatLng(13.8339232, 100.4946732),
        LatLng(13.8239232, 100.4946732),
        LatLng(13.8229900, 100.5010732),
      ],
      strokeWidth: 5,
      fillColor: Colors.transparent);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(title: Text('Google Map')),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _originController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                          hintText: 'Origin',
                          contentPadding: EdgeInsets.all(10.0)),
                      onChanged: (value) {
                        print(value);
                      },
                    ),
                    TextFormField(
                      controller: _destinationController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                          hintText: 'Destination',
                          contentPadding: EdgeInsets.all(10.0)),
                      onChanged: (value) {
                        print(value);
                      },
                    ),
                  ],
                ),
              ),
              IconButton(
                  onPressed: (() async {
                    var direction = await LocationService().getDirection(
                        _originController.text, _destinationController.text);
                    // var place = await LocationService()
                    //     .getPlace(_searchController.text);
                    _goToThePlace(
                      direction['start_location']['lat'],
                      direction['start_location']['lng'],
                      direction['bounds_ne'],
                      direction['bounds_sw'],
                    );

                    _setPolyline(direction['polyline_decoded']);
                  }),
                  icon: Icon(Icons.search)),
            ],
          ),
          // Row(
          //   children: [
          //     Expanded(
          //         child: TextFormField(
          //       controller: _searchController,
          //       textCapitalization: TextCapitalization.words,
          //       decoration: InputDecoration(
          //           hintText: 'Search by city',
          //           contentPadding: EdgeInsets.all(10)),
          //       onChanged: (value) {
          //         print(value);
          //       },
          //     )),
          //   IconButton(
          //       onPressed: (() async {
          //         var place = await LocationService()
          //             .getPlace(_searchController.text);
          //         _goToThePlace(place);
          //       }),
          //       icon: Icon(Icons.search)),
          // ],
          // ),
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              markers: _markers,
              polylines: _polylines,
              polygons: _polygons,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onTap: (point) {
                setState(() {
                  polygonLatLngs.add(point);
                  _setPolygon();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _goToThePlace(
    double lat,
    double lng,
    Map<String, dynamic> boundsNe,
    Map<String, dynamic> boundsSw,

    // Map<String, dynamic> place
  ) async {
    // final double lat = place['geometry']['location']['lat'];
    // final double lng = place['geometry']['location']['lng'];

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 12)));
    _setMarker(LatLng(lat, lng));

    controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
            southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
            northeast: LatLng(boundsNe['lat'], boundsNe['lng'])),
        40));
    _setMarker(LatLng(lat, lng));
  }
}
