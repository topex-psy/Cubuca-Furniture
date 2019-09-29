import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'utils/constants.dart';

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  Codec codec = await instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
  FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ImageByteFormat.png)).buffer.asUint8List();
}

class Lokasi extends StatefulWidget {
  @override
  _LokasiState createState() => _LokasiState();
}

class _LokasiState extends State<Lokasi> {
  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  LatLng _latLng = LatLng(Kontak.lat, Kontak.lng);
  double _zoom = 18.0;

  @override
  void initState() {
    super.initState();

    Future muatPeta() async {
      final MarkerId markerId = MarkerId("primaryAddress");
      final Uint8List markerIcon = await getBytesFromAsset("images/marker.png", 100);
      final Marker marker = Marker(
        icon: BitmapDescriptor.fromBytes(markerIcon),
        alpha: 1.0,
        markerId: markerId,
        position: _latLng,
        infoWindow: InfoWindow(title: Kontak.nama, snippet:  Kontak.alamat),
        onTap: () {},
      );
      setState(() {
        _markers[markerId] = marker;
      });
    }
    muatPeta();
    
    WidgetsBinding.instance.addPostFrameCallback((_) { // when widget built
      _animateZoom();
    });
  }

  Future<void> _animateZoom() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(_latLng, _zoom));
  }

  _launchMap() async {
    var mapSchema = 'geo:${_latLng.latitude},${_latLng.longitude}';
    if (await canLaunch(mapSchema)) {
      await launch(mapSchema);
    } else {
      throw 'Could not open the map.';
    }
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
            icon: Icon(MdiIcons.map),
            tooltip: "Buka Aplikasi Map",
            onPressed: _launchMap,
          ),
        ],),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        markers: Set<Marker>.of(_markers.values),
        initialCameraPosition: CameraPosition(
          target: _latLng,
          zoom: _zoom,
          bearing: 0,
          tilt: 0,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        onCameraMove: (CameraPosition cameraPosition) {
          print("MAP CAMERA POSITION = ${cameraPosition.target.latitude}, ${cameraPosition.target.longitude}");
        },
      ),
    );
  }
}