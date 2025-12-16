import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() => runApp(
  const MaterialApp(debugShowCheckedModeBanner: false, home: DriverMapScreen()),
);

class DriverMapScreen extends StatefulWidget {
  const DriverMapScreen({super.key});

  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen> {
  final MapController mapController = MapController();

  // Connect to backend (Use 10.0.2.2 for Android Emulator)
  final channel = WebSocketChannel.connect(Uri.parse('ws://10.0.2.2:8000/ws'));

  LatLng currentPos = const LatLng(22.7292, 88.4878);
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();

    // Listen for WebSocket updates
    channel.stream.listen((message) {
      final data = jsonDecode(message);
      final newLoc = LatLng(data['lat'], data['lng']);

      setState(() {
        currentPos = newLoc;
        _markers = [
          Marker(
            point: newLoc,
            width: 80,
            height: 80,
            // A prettier custom marker
            child: Stack(
              alignment: Alignment.center,
              children: [
                // White background circle with shadow
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                ),
                // The Car Icon
                const Icon(
                  Icons.directions_car_filled,
                  color: Colors.blueAccent,
                  size: 30,
                ),
              ],
            ),
          ),
        ];
      });

      // Move camera smoothly
      mapController.move(newLoc, 16.0);
    });
  }

  Future<void> _startTracking() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      final data = {
        'lat': position.latitude,
        'lng': position.longitude,
        'id': 'driver_1',
      };
      channel.sink.add(jsonEncode(data));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: currentPos,
              initialZoom: 16.0,
              minZoom: 5.0,
              maxZoom: 18.0,
            ),
            children: [
              // 1. THE BEAUTIFUL TILE LAYER (CartoDB Voyager)
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.saferoute',
              ),
              // 2. The Marker Layer
              MarkerLayer(markers: _markers),
            ],
          ),

          // UI Overlay: Start Button
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: _startTracking,
              icon: const Icon(Icons.play_arrow),
              label: const Text("Start Simulation"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
            ),
          ),

          // UI Overlay: Top Title Card
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Status: Connected",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
