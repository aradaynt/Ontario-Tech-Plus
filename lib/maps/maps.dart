import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() => runApp(const TestApp());

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Maps Page",
      theme: ThemeData(),
      home: Scaffold(appBar: AppBar(), body: MapsPage()),
    );
  }
}

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<StatefulWidget> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  final MapController _mapController = MapController();
  final MapOptions _mapOptions = MapOptions(
    // center the map on ontario tech north oshawa campus
    initialCenter: LatLng(43.94577409162885, -78.89682951911573),
    initialZoom: 16,
    initialRotation: 0.0,
  );
  final TileProvider _tileProvider = NetworkTileProvider();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentGeometry.center,
      child: FlutterMap(
        mapController: _mapController,
        options: _mapOptions,
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: "mobile_devices_project",
            tileProvider: _tileProvider,
          ),
        ],
      ),
    );
  }
}
