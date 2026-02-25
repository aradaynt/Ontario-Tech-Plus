// imports
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'building.dart';

// main function for testing
void main() => runApp(const TestApp());

// test app for testing
class TestApp extends StatelessWidget {
  const TestApp({super.key});

  // creates app with
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Maps Page",
      theme: ThemeData(),
      home: Scaffold(
        appBar: AppBar(title: Text("Map")),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              label: "schedule",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: "Map",
            ),
          ],
        ),
        body: MapsPage(),
      ),
    );
  }
}

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<StatefulWidget> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  // geolocator platform
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

  // location stream
  StreamSubscription<Position>? _positionStreamSubscription;

  // device location
  LatLng? _currentPosition;

  // FlutterMap objects
  final MapController _mapController = MapController();
  final MapOptions _mapOptions = MapOptions(
    // center the map on ontario tech north oshawa campus
    initialCenter: LatLng(43.945152871124854, -78.89684924186564),
    initialZoom: 16.5,
    initialRotation: 16.0,
    interactionOptions: InteractionOptions(
      flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
    ),
  );
  final TileProvider _tileProvider = NetworkTileProvider();

  // Map buildings
  final List<Building> _buildings = [
    Building(
      "Sha building",
      LatLng(43.946213, -78.896540),
      Polygon(
        points: [
          LatLng(43.946327, -78.896870),
          LatLng(43.945917, -78.896679),
          LatLng(43.945979, -78.896406),
          LatLng(43.946023, -78.896433),
          LatLng(43.946077, -78.896205),
          LatLng(43.946444, -78.896371),
        ],
        color: Color(0xFF0077CA).withValues(alpha: 0.20),
        borderColor: Color(0xFF003C71),
      ),
    ),
    Building(
      "Energy Resource Center",
      LatLng(43.945639, -78.896306),
      Polygon(
        points: [
          LatLng(43.945795, -78.896671),
          LatLng(43.945419, -78.896502),
          LatLng(43.945537, -78.895960),
          LatLng(43.945919, -78.896124),
        ],
        color: Color(0xFF0077CA).withValues(alpha: 0.20),
        borderColor: Color(0xFF003C71),
      ),
    ),
    Building(
      "UB Building",
      LatLng(43.945189, -78.896076),
      Polygon(
        points: [
          LatLng(43.945287, -78.896438),
          LatLng(43.944919, -78.896274),
          LatLng(43.945042, -78.895749),
          LatLng(43.945405, -78.895909),
        ],
        color: Color(0xFF0077CA).withValues(alpha: 0.20),
        borderColor: Color(0xFF003C71),
      ),
    ),
    Building(
      "UA Building",
      LatLng(43.944527, -78.896433),
      Polygon(
        points: [
          LatLng(43.944546, -78.897213),
          LatLng(43.944160, -78.896998),
          LatLng(43.944488, -78.895612),
          LatLng(43.944886, -78.895783),
        ],
        color: Color(0xFF0077CA).withValues(alpha: 0.20),
        borderColor: Color(0xFF003C71),
      ),
    ),
    Building(
      "Health And Recreation Center",
      LatLng(43.944029, -78.898629),
      Polygon(
        points: [
          LatLng(43.944318, -78.899168),
          LatLng(43.943619, -78.898847),
          LatLng(43.943795, -78.898098),
          LatLng(43.944063, -78.898219),
          LatLng(43.944077, -78.898157),
          LatLng(43.944229, -78.898235),
          LatLng(43.944220, -78.898273),
          LatLng(43.944502, -78.898399),
        ],
        color: Color(0xFF0077CA).withValues(alpha: 0.20),
        borderColor: Color(0xFF003C71),
      ),
    ),
    Building(
      "Library",
      LatLng(43.945898, -78.897307),
      Polygon(
        points: [
          LatLng(43.945940, -78.897693),
          LatLng(43.945543, -78.897508),
          LatLng(43.945585, -78.897326),
          LatLng(43.945734, -78.897406),
          LatLng(43.945855, -78.896934),
          LatLng(43.946099, -78.897028),
        ],
        color: Color(0xFF0077CA).withValues(alpha: 0.20),
        borderColor: Color(0xFF003C71),
      ),
    ),
    Building(
      "OPG Engineering Building",
      LatLng(43.945832, -78.898281),
      Polygon(
        points: [
          LatLng(43.945898, -78.898568),
          LatLng(43.945656, -78.898444),
          LatLng(43.945776, -78.897967),
          LatLng(43.945853, -78.898007),
          LatLng(43.945842, -78.898058),
          LatLng(43.946004, -78.898130),
        ],
        color: Color(0xFF0077CA).withValues(alpha: 0.20),
        borderColor: Color(0xFF003C71),
      ),
    ),
    Building(
      "Automotive Center Of Excellence",
      LatLng(43.945633, -78.899174),
      Polygon(
        points: [
          LatLng(43.945898, -78.898570),
          LatLng(43.945782, -78.899069),
          LatLng(43.945892, -78.899128),
          LatLng(43.945774, -78.899673),
          LatLng(43.945680, -78.899632),
          LatLng(43.945655, -78.899748),
          LatLng(43.945284, -78.899587),
          LatLng(43.945313, -78.899463),
          LatLng(43.945216, -78.899415),
          LatLng(43.945301, -78.899072),
          LatLng(43.945490, -78.899158),
          LatLng(43.945539, -78.898967),
          LatLng(43.945510, -78.898962),
          LatLng(43.945618, -78.898522),
          LatLng(43.945639, -78.898530),
          LatLng(43.945660, -78.898447),
        ],
        color: Color(0xFF0077CA).withValues(alpha: 0.20),
        borderColor: Color(0xFF003C71),
      ),
    ),
    Building(
      "English Language Center",
      LatLng(43.946608, -78.898737),
      Polygon(
        points: [
          LatLng(43.946751, -78.899093),
          LatLng(43.946334, -78.898892),
          LatLng(43.946456, -78.898382),
          LatLng(43.946873, -78.898578),
        ],
        color: Color(0xFF0077CA).withValues(alpha: 0.20),
        borderColor: Color(0xFF003C71),
      ),
    ),
    Building(
      "Clean Energy Research Lab",
      LatLng(43.946582, -78.900287),
      Polygon(
        points: [
          LatLng(43.946739, -78.900477),
          LatLng(43.946385, -78.900314),
          LatLng(43.946394, -78.900263),
          LatLng(43.946363, -78.900252),
          LatLng(43.946398, -78.900096),
          LatLng(43.946424, -78.900111),
          LatLng(43.946437, -78.900088),
          LatLng(43.946790, -78.900255),
        ],
        color: Color(0xFF0077CA).withValues(alpha: 0.20),
        borderColor: Color(0xFF003C71),
      ),
    ),
    Building(
      "University Pavillion",
      LatLng(43.943161, -78.898648),
      Polygon(
        points: [
          LatLng(43.943293, -78.898847),
          LatLng(43.943013, -78.898715),
          LatLng(43.943076, -78.898420),
          LatLng(43.943358, -78.898570),
        ],
        color: Color(0xFF0077CA).withValues(alpha: 0.20),
        borderColor: Color(0xFF003C71),
      ),
    ),
    Building(
      "SIRC",
      LatLng(43.947811, -78.899104),
      Polygon(
        points: [
          LatLng(43.947833, -78.899514),
          LatLng(43.947626, -78.899434),
          LatLng(43.947785, -78.898694),
          LatLng(43.948047, -78.898798),
          LatLng(43.947999, -78.899034),
          LatLng(43.947937, -78.899010),
        ],
        color: Color(0xFF0077CA).withValues(alpha: 0.20),
        borderColor: Color(0xFF003C71),
      ),
    ),
    Building(
      "Campus Field House",
      LatLng(43.948580, -78.899142),
      Polygon(
        points: [
          LatLng(43.948601, -78.899831),
          LatLng(43.948285, -78.899697),
          LatLng(43.948445, -78.898981),
          LatLng(43.948291, -78.898914),
          LatLng(43.948333, -78.898739),
          LatLng(43.948414, -78.898774),
          LatLng(43.948443, -78.898635),
          LatLng(43.948511, -78.898664),
          LatLng(43.948563, -78.898447),
          LatLng(43.948883, -78.898586),
        ],
        color: Color(0xFF0077CA).withValues(alpha: 0.20),
        borderColor: Color(0xFF003C71),
      ),
    ),
    Building(
      "Campus Ice Center",
      LatLng(43.950683, -78.898262),
      Polygon(
        points: [
          LatLng(43.950214, -78.898527),
          LatLng(43.950866, -78.898833),
          LatLng(43.950882, -78.898779),
          LatLng(43.951042, -78.898796),
          LatLng(43.951073, -78.898353),
          LatLng(43.951127, -78.898112),
          LatLng(43.951046, -78.898063),
          LatLng(43.951075, -78.897932),
          LatLng(43.950432, -78.897648),
          LatLng(43.950297, -78.898283),
          LatLng(43.950268, -78.898278),
        ],
        color: Color(0xFF0077CA).withValues(alpha: 0.20),
        borderColor: Color(0xFF003C71),
      ),
    ),
  ];

  // boolean variables for program control
  bool _isNavigating = false;
  bool _showAttribution = true;

  @override
  void initState() {
    super.initState();
    _setupLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentGeometry.center,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: _mapOptions,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showAttribution = false;
                  });
                },
                child: TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: "mobile_devices_project",
                  tileProvider: _tileProvider,
                ),
              ),
              PolygonLayer(
                polygons: [for (var building in _buildings) building.polygon],
              ),
              MarkerLayer(
                markers: [
                  if (_currentPosition != null)
                    Marker(
                      rotate: true,
                      child: Icon(Icons.location_pin, color: Colors.redAccent),
                      point: _currentPosition!,
                    ),
                ],
              ),
              if (_showAttribution)
                SimpleAttributionWidget(
                  source: Text("OpenStreetMap Contributors"),
                ),
              // PolylineLayer(polylines: []),
            ],
          ),
          Padding(
            padding: EdgeInsetsGeometry.all(10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _setupLocation() async {
    bool hasPermission = await _handlePermission();
    if (!hasPermission) {
      return;
    }

    _positionStreamSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position position) {
          setState(() {
            _currentPosition = LatLng(position.latitude, position.longitude);
          });
        });
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      await _geolocatorPlatform.openLocationSettings();
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }
}
