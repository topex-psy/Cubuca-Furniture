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
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  double zoom = 16.0;

  @override
  void initState() {
    super.initState();
    final MarkerId markerId = MarkerId("primaryAddress");
    final Marker marker = Marker(
      markerId: markerId,
      position: latLng,
      infoWindow: InfoWindow(title: Kontak.nama, snippet:  Kontak.alamat),
      onTap: () {},
    );

    markers[markerId] = marker;

    WidgetsBinding.instance.addPostFrameCallback((_) { // when widget built
      //_refreshIndicatorKey[_tabPosition].currentState.show();
      animateZoom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /* body: GoogleMap(
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
      ), */
      body: Container(),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: _zoomIn,
            heroTag: "_fabZoomIn",
            child: Icon(Icons.zoom_in),
            backgroundColor: Colors.blue,
            mini: true,
          ),
          SizedBox(height: 6,),
          FloatingActionButton(
            onPressed: _zoomOut,
            heroTag: "_fabZoomOut",
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