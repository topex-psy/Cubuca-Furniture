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
  double _zoom = 19.0;

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
      _animateZoom();
    });
  }

  Future<void> _animateZoom() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(latLng, _zoom));
  }
  _zoomIn() {
    if (_zoom < 20.0) setState(() => _zoom += 1.0);
    _animateZoom();
  }
  _zoomOut() {
    if (_zoom > 10.0) setState(() => _zoom -= 1.0);
    _animateZoom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: HSLColor.fromColor(Colors.blue).withLightness(0.85).toColor(),
        titleSpacing: 0.0,
        title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
          InkWell(
            onTap: () => Navigator.of(context).pop(true),
            child: Container(
              padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 20),
              child: Row(children: <Widget>[
                Icon(Icons.chevron_left, color: Colors.black87,),
                SizedBox(width: 8,),
                Text("Peta Lokasi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
              ],),
            ),
          ),
          IconButton(
            color: Colors.black87,
            icon: Icon(Icons.person_pin),
            tooltip: "Street View",
            onPressed: () {}, //TODO launch streetview
          ),
        ],),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        markers: Set<Marker>.of(markers.values),
        initialCameraPosition: CameraPosition(
          target: latLng,
          zoom: _zoom,
          bearing: 0,
          tilt: 0,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 50),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton(
              onPressed: _zoomIn,
              heroTag: "_fabZoomIn",
              child: Icon(Icons.zoom_in, color: Colors.white,),
              backgroundColor: Colors.grey[700],
              mini: true,
            ),
            //SizedBox(height: 8,),
            FloatingActionButton(
              onPressed: _zoomOut,
              heroTag: "_fabZoomOut",
              child: Icon(Icons.zoom_out, color: Colors.white,),
              backgroundColor: Colors.grey[700],
              mini: true,
            ),
          ],
        ),
      ),
    );
  }
}