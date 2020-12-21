import 'package:flutter/material.dart';
import 'package:pos_app/storePage/hardware.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

const LatLng SOURCE_LOCATION = LatLng(37.565931, 126.982605);

class Location extends StatelessWidget {
  static const id = 'location';
  LocationData currentLocation;
  static const LatLng _center = LatLng(337.565931, 126.982605);
  LatLng _lastMapPosition = _center;

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = CameraPosition(
      target: SOURCE_LOCATION,
      zoom: 15.5,
    );
    if (currentLocation != null) {
      initialCameraPosition = CameraPosition(
        zoom: 15.5,
        target: LatLng(currentLocation.latitude, currentLocation.longitude),
      );
    }

    void _onCameraMove(CameraPosition position) {
      _lastMapPosition = position.target;
    }

    Future<GoogleMap> _googleMap() async {
      return GoogleMap(
        zoomGesturesEnabled: true,
        myLocationEnabled: true,
        compassEnabled: true,
        tiltGesturesEnabled: false,
        initialCameraPosition: initialCameraPosition,
        onCameraMove: _onCameraMove,
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Container(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Locations",
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  FutureBuilder(
                    future: _googleMap(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Padding(
                          padding: EdgeInsets.all(
                            10.0,
                          ),
                          child: SizedBox(
                            height: 200.0,
                            child: snapshot.data,
                          ),
                        );
                      }
                      return CircularProgressIndicator();
                    },
                  ),
                ],
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 1.0), //(x,y)
                  blurRadius: 6.0,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Container(
            height: 60.0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Edit locations",
                    style: TextStyle(
                        color: Colors.purple,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500),
                  ),
                  Icon(
                    Icons.link,
                    color: Colors.purple,
                  ),
                ],
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 1.0), //(x,y)
                  blurRadius: 6.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
