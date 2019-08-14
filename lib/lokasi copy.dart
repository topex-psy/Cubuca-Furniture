import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'utils/constants.dart';

class Lokasi extends StatefulWidget {
  @override
  _LokasiState createState() => _LokasiState();
}

class _LokasiState extends State<Lokasi> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng latLng = LatLng(Kontak.lat, Kontak.lng);
  double zoom = 16.0;

  @override
  Widget build(BuildContext context) {
    Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
    String markerIdVal = "utama";
    String nama = Kontak.nama;
    String alamat = Kontak.alamat;
    double lat = Kontak.lat;
    double lng = Kontak.lng;

    final MarkerId markerId = MarkerId(markerIdVal);
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(title: nama, snippet: alamat),
      onTap: () {},
    );

    // adding a new marker to map
    markers[markerId] = marker;

    animateZoom();

    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        markers: Set<Marker>.of(markers.values),
        initialCameraPosition: CameraPosition(
          target: latLng,
          zoom: zoom,
          bearing: 0,
          tilt: 0,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: _zoomIn,
            heroTag: "fabZoomIn",
            child: Icon(Icons.zoom_in),
            backgroundColor: Colors.blue,
            mini: true,
          ),
          SizedBox(height: 6,),
          FloatingActionButton(
            onPressed: _zoomOut,
            heroTag: "fabZoomOut",
            child: Icon(Icons.zoom_out),
            backgroundColor: Colors.blue,
            mini: true,
          ),
        ],
      ),
    );
  }

  Future<void> animateZoom() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(latLng, zoom));
  }
  _zoomIn() {
    if (zoom < 20.0) setState(() => zoom += 1.0);
  }
  _zoomOut() {
    if (zoom > 10.0) setState(() => zoom -= 1.0);
  }
}