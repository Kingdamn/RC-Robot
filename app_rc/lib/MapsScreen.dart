import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LocationScreen(),
  ));
}

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  LatLng currentLocation = LatLng(0, 0); // Initial location
  MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    listenToLocationChanges();
  }

  void listenToLocationChanges() {
    DatabaseReference locationRef =
    FirebaseDatabase.instance.reference().child('GPS');

    locationRef.onValue.listen((DatabaseEvent event) {
      final Map<dynamic, dynamic>? data =
      event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        double lat = data['lat'];
        double lng = data['lng'];

        // Update the location and trigger a map update
        setState(() {
          currentLocation = LatLng(lat, lng);
          mapController.moveAndRotate(currentLocation, 13.0, 0.0);
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Location"),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Container(
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(center: currentLocation, zoom: 13.0),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 30.0,
                  height: 30.0,
                  point: currentLocation,
                  builder: (ctx) => Container(
                    child: Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}