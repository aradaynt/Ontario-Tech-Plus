/*
* Contributors: Ayaan Mustafa
* Purpose: Define the logic of the map widget
*/

// imports
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_compass/flutter_map_compass.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'building.dart';

// Maps Page widget
class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  // create state
  @override
  State<StatefulWidget> createState() => _MapsPageState();
}

// Maps Page State
class _MapsPageState extends State<MapsPage> with TickerProviderStateMixin {
  // geolocator platform
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

  // location stream
  StreamSubscription<Position>? _positionStreamSubscription;

  // FlutterMap controller
  final MapController _mapController = MapController();

  // tile provider retrieves map tiles
  final TileProvider _tileProvider = NetworkTileProvider();

  // hit notifier for the polygon layer
  final LayerHitNotifier<Building> _polygonHtNotifier = ValueNotifier(null);

  // device location
  LatLng? _currentPosition;

  // camera position on map
  LatLng? _cameraPosition;

  // selected building
  Building? _selectedBuilding;

  // future route
  // Future<List<PointLatLng>>? _routeFuture;
  Future<Map<String, dynamic>>? _routeFuture;

  // map buildings
  final List<Building> _buildings = [
    Building("Sha building", LatLng(43.946213, -78.896540), [
      LatLng(43.946327, -78.896870),
      LatLng(43.945917, -78.896679),
      LatLng(43.945979, -78.896406),
      LatLng(43.946023, -78.896433),
      LatLng(43.946077, -78.896205),
      LatLng(43.946444, -78.896371),
    ]),
    Building("Energy Resource Center", LatLng(43.945639, -78.896306), [
      LatLng(43.945795, -78.896671),
      LatLng(43.945419, -78.896502),
      LatLng(43.945537, -78.895960),
      LatLng(43.945919, -78.896124),
    ]),
    Building("UB Building", LatLng(43.945189, -78.896076), [
      LatLng(43.945287, -78.896438),
      LatLng(43.944919, -78.896274),
      LatLng(43.945042, -78.895749),
      LatLng(43.945405, -78.895909),
    ]),
    Building("UA Building", LatLng(43.944527, -78.896433), [
      LatLng(43.944546, -78.897213),
      LatLng(43.944160, -78.896998),
      LatLng(43.944488, -78.895612),
      LatLng(43.944886, -78.895783),
    ]),
    Building("Health And Recreation Center", LatLng(43.944029, -78.898629), [
      LatLng(43.944318, -78.899168),
      LatLng(43.943619, -78.898847),
      LatLng(43.943795, -78.898098),
      LatLng(43.944063, -78.898219),
      LatLng(43.944077, -78.898157),
      LatLng(43.944229, -78.898235),
      LatLng(43.944220, -78.898273),
      LatLng(43.944502, -78.898399),
    ]),
    Building("Library", LatLng(43.945898, -78.897307), [
      LatLng(43.945940, -78.897693),
      LatLng(43.945543, -78.897508),
      LatLng(43.945585, -78.897326),
      LatLng(43.945734, -78.897406),
      LatLng(43.945855, -78.896934),
      LatLng(43.946099, -78.897028),
    ]),
    Building("OPG Engineering Building", LatLng(43.945832, -78.898281), [
      LatLng(43.945898, -78.898568),
      LatLng(43.945656, -78.898444),
      LatLng(43.945776, -78.897967),
      LatLng(43.945853, -78.898007),
      LatLng(43.945842, -78.898058),
      LatLng(43.946004, -78.898130),
    ]),
    Building("Automotive Center Of Excellence", LatLng(43.945633, -78.899174), [
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
    ]),
    Building("English Language Center", LatLng(43.946608, -78.898737), [
      LatLng(43.946751, -78.899093),
      LatLng(43.946334, -78.898892),
      LatLng(43.946456, -78.898382),
      LatLng(43.946873, -78.898578),
    ]),
    Building("Clean Energy Research Lab", LatLng(43.946582, -78.900287), [
      LatLng(43.946739, -78.900477),
      LatLng(43.946385, -78.900314),
      LatLng(43.946394, -78.900263),
      LatLng(43.946363, -78.900252),
      LatLng(43.946398, -78.900096),
      LatLng(43.946424, -78.900111),
      LatLng(43.946437, -78.900088),
      LatLng(43.946790, -78.900255),
    ]),
    Building("University Pavillion", LatLng(43.943161, -78.898648), [
      LatLng(43.943293, -78.898847),
      LatLng(43.943013, -78.898715),
      LatLng(43.943076, -78.898420),
      LatLng(43.943358, -78.898570),
    ]),
    Building("SIRC", LatLng(43.947811, -78.899104), [
      LatLng(43.947833, -78.899514),
      LatLng(43.947626, -78.899434),
      LatLng(43.947785, -78.898694),
      LatLng(43.948047, -78.898798),
      LatLng(43.947999, -78.899034),
      LatLng(43.947937, -78.899010),
    ]),
    Building("Campus Field House", LatLng(43.948580, -78.899142), [
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
    ]),
    Building("Campus Ice Center", LatLng(43.950683, -78.898262), [
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
    ]),
  ];

  // marker
  Marker? _destinationMarker;

  // selection animations
  late AnimationController _selectionAnimationController;
  late Animation<Color?> _polygonColorAnimation;
  late Animation<double> _borderWidthAnimation;
  late Animation<Offset> _nameBoxSlide;
  late Animation<Offset> _compassSlide;
  late Animation<Offset> _navButtonSlide;

  // recenter animations
  late AnimationController _recenterAnimationController;
  late Animation<Offset> _recenterButtonSlide;

  // route polyline animation
  late AnimationController _routeAnimationController;
  late Animation<double> _routeAnimation;

  // begin navigation animation
  late AnimationController _beginNavAnimationController;
  late Animation<Offset> _closeButtonSlide;

  // boolean variables for program control
  bool _isRouting = false;
  bool _isNavigating = false;
  bool _showAttribution = true;

  // initState
  @override
  void initState() {
    super.initState();
    _setupLocation();

    // initialize the select animation controller
    _selectionAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // define the color transition
    _polygonColorAnimation =
        ColorTween(
          begin: Color(0xFF0077CA).withValues(alpha: 0.20),
          end: Color(0xFF0077CA).withValues(alpha: 0.60),
        ).animate(
          CurvedAnimation(
            parent: _selectionAnimationController,
            curve: Curves.easeInOut,
          ),
        );

    // define the border thickness transition
    _borderWidthAnimation = Tween<double>(begin: 1.0, end: 3.0).animate(
      CurvedAnimation(
        parent: _selectionAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // define the name box slide transition
    _nameBoxSlide =
        Tween<Offset>(
          begin: const Offset(0.0, -2.0), // Start above the visible area
          end: Offset.zero, // End at the default position
        ).animate(
          CurvedAnimation(
            parent: _selectionAnimationController,
            curve: Curves.easeInOut,
          ),
        );

    // define the compass slide transition so that it starts in its normal
    // position and then slides down with the name box
    _compassSlide =
        Tween<Offset>(
          begin: const Offset(0.0, 0.0),
          end: const Offset(0.0, 2.0),
        ).animate(
          CurvedAnimation(
            parent: _selectionAnimationController,
            curve: Curves.easeInOut,
          ),
        );

    // define the nav button slide so that the start navigation button
    // is off screen until a building is selected
    _navButtonSlide =
        Tween<Offset>(
          begin: const Offset(0.0, 2.0),
          end: const Offset(0.0, 0.0),
        ).animate(
          CurvedAnimation(
            parent: _selectionAnimationController,
            curve: Curves.easeInOut,
          ),
        );

    // animation controller for the recenter button
    _recenterAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // define recenter button slide animation
    _recenterButtonSlide =
        Tween<Offset>(
          begin: const Offset(0.0, 2.0), // Start above the visible area
          end: Offset.zero, // End at the default position
        ).animate(
          CurvedAnimation(
            parent: _recenterAnimationController,
            curve: Curves.easeInOut,
          ),
        );

    // route polyline animation controller
    _routeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // define polyline draw animation
    _routeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _routeAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // initialize the select animation controller
    _beginNavAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // define the end navigation button animation
    _closeButtonSlide =
        Tween<Offset>(
          begin: const Offset(0.0, 2.0),
          end: const Offset(0.0, 0.0),
        ).animate(
          CurvedAnimation(
            parent: _beginNavAnimationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  // build method
  @override
  Widget build(BuildContext context) {
    // widget is organized into a stack with the map layer
    // as the bottom most element of the stack. All other
    // Widgets are rendered on-top of it.
    return Scaffold(
      appBar: AppBar(title: Text("Campus Map")),
      body: Stack(
        children: [
          // The FlutterMap widget that constructs the map
          FlutterMap(
            // mapController defines how the map can be interacted with
            mapController: _mapController,
            // options sets the maps rules
            options: MapOptions(
              // center the map on ontario tech north oshawa campus
              initialCenter: LatLng(43.945152871124854, -78.89684924186564),
              initialZoom: 16.5,
              initialRotation: 16.0,
              // onMapEvent used to detect when the user has interacted with the
              // map. Used to hide attribution on map interact as allowed under
              // OpenStreetMap Licencing and Attribution. Also detect if user
              // has tapped map to disable routing.
              onMapEvent: (event) {
                if (event.runtimeType != MapEventNonRotatedSizeChange) {
                  _showAttribution = false;
                }

                // if currently routing allow user to cancel routing by
                // tapping the map
                if (event is MapEventTap && _isRouting && !_isNavigating) {
                  _selectionAnimationController.reverse().then((_) {
                    if (mounted) {
                      setState(() {
                        _isRouting = false;
                        _destinationMarker = null;
                        _selectedBuilding = null;
                        _routeFuture = null;
                      });
                    }
                  });
                }

                // on any map event update camera position
                setState(() {
                  _cameraPosition = _mapController.camera.center;
                });

                // check to see if the camera and user position are centered
                _checkIfCentered();
              },

              // get camera position when the map is loaded
              onMapReady: () {
                setState(() {
                  _cameraPosition = _mapController.camera.center;
                });
              },
              backgroundColor: Color(0xFFF7FCFF),
            ),
            // children contains all the layers that make up the map
            children: [
              // First layer is the tile layer, this layer makes a call
              // to a tile provider and displays it.
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "mobile_devices_project",
                tileProvider: _tileProvider,
              ),
              // The second layer is polygon layer that draws polygons on the map
              // these polygons are constructed from a list of coordinates.
              // this layer is used to highlight the buildings of the OTU Campus.
              // A gesture detector is used with flutter_map's hit detector
              // to select the building that the user has tapped and set routing
              // as true.
              GestureDetector(
                child: AnimatedBuilder(
                  animation: _selectionAnimationController,
                  builder: (context, child) {
                    return PolygonLayer(
                      hitNotifier: _polygonHtNotifier,
                      polygons: [
                        for (var building in _buildings)
                          Polygon<Building>(
                            hitValue: building,
                            points: building.polygon,
                            // Conditionally change the color/opacity
                            // if it's the selected building
                            color:
                                (_selectedBuilding?.name == building.name &&
                                    _isRouting)
                                ? _polygonColorAnimation.value ??
                                      Color(0xFF0077CA).withValues(alpha: 0.20)
                                : Color(0xFF0077CA).withValues(alpha: 0.20),
                            borderColor: Color(0xFF003C71),
                            // Use the animated border width
                            borderStrokeWidth:
                                (_selectedBuilding?.name == building.name &&
                                    _isRouting)
                                ? _borderWidthAnimation.value
                                : 1.0,
                          ),
                      ],
                    );
                  },
                ),
                // on polygon tap set it as the selected building and play
                // animation
                onTap: () {
                  Building? tappedBuilding =
                      _polygonHtNotifier.value?.hitValues.isNotEmpty == true
                      ? _polygonHtNotifier.value!.hitValues[0]
                      : null;

                  if (tappedBuilding != null) {
                    if (tappedBuilding.name == _selectedBuilding?.name) {
                      // Tapping the same building: toggle routing and reverse animations
                      _routeAnimationController.reverse();
                      _selectionAnimationController.reverse().then((_) {
                        if (mounted) {
                          setState(() {
                            _isRouting = false;
                            _destinationMarker = null;
                            _selectedBuilding = null;
                            _routeFuture = null;
                          });
                        }
                      });
                    } else {
                      // Tapping a new building
                      setState(() {
                        _selectedBuilding = tappedBuilding;
                        _isRouting = true;
                        _destinationMarker = Marker(
                          point: _selectedBuilding!.centre,
                          alignment: Alignment.center,
                          rotate: true,
                          child: Icon(
                            Icons.location_pin,
                            color: Color(0xFFE75D2A),
                            size: 30,
                          ),
                        );
                        _mapController.move(_selectedBuilding!.centre, 16.5);

                        if (_currentPosition != null) {
                          _routeAnimationController.reset(); // Reset the line

                          _routeFuture =
                              fetchRoute(
                                _currentPosition!,
                                _selectedBuilding!.centre,
                              )..then((_) {
                                // Play the animation once the future completes
                                if (mounted && _isRouting) {
                                  _routeAnimationController.forward();
                                }
                              });
                        }
                      });
                      _selectionAnimationController.forward(from: 0.0);
                    }
                  }
                },
              ),
              // the third layer is the MarkerLayer that is used to mark locations
              // on the map with a widget.
              MarkerLayer(markers: [?_destinationMarker]),
              // the fourth layer is the currentLocationLayer, that displays the
              // users current location and the direction their device is
              // pointing. Uses an alternate icon during navigation.
              CurrentLocationLayer(
                alignPositionOnUpdate: AlignOnUpdate.never,
                alignDirectionOnUpdate: AlignOnUpdate.never,
                style: LocationMarkerStyle(
                  marker: _isNavigating
                      ? DefaultLocationMarker(
                          color: Colors.white,
                          child: Icon(
                            Icons.navigation_sharp,
                            color: Color(0xFF0077CA),
                            size: 20,
                          ),
                        )
                      : DefaultLocationMarker(),
                  markerAlignment: Alignment.center,
                  markerDirection: MarkerDirection.heading,
                  markerSize: _isNavigating
                      ? const Size.square(25)
                      : Size.square(20),
                ),
              ),
              if (_isRouting && _routeFuture != null)
                FutureBuilder<Map<String, dynamic>>(
                  future: _routeFuture, // Use the stored future!
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Show a loading indicator while
                      // the route fetches
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasData) {
                      return AnimatedBuilder(
                        animation: _routeAnimation,
                        builder: (context, child) {
                          List<LatLng> points = [];

                          for (var point in snapshot.data!["points"]) {
                            points.add(LatLng(point.latitude, point.longitude));
                          }

                          // Calculate how many points to show based
                          // on the animation (0.0 to 1.0)
                          int pointCount =
                              (points.length * _routeAnimation.value).ceil();

                          List<LatLng> animatedPoints = points
                              .take(pointCount)
                              .toList();

                          return PolylineLayer(
                            polylines: [
                              // A Polyline needs at least 2 points
                              // to be drawn on the canvas
                              if (animatedPoints.length > 1)
                                Polyline(
                                  points: animatedPoints,
                                  color: Color(0xFFE75D2A),
                                  strokeWidth: 4,
                                ),
                            ],
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      // Handle any API errors gracefully
                      return Center(child: Text('Error loading route'));
                    }
                    return Container();
                  },
                ),
              // the Attribution Layer used to credit the map provider
              if (_showAttribution)
                SimpleAttributionWidget(
                  source: Text(
                    "OpenStreetMap Contributors\n"
                    " OpenStreetRoutingMachine",
                  ),
                ),
              // compass widget that always points north. the user can tap the
              // compass in order to rotate the map so that the top of the
              // screen points north. Animated so that it slides with the
              // building name box. It is the topmost widget in the map
              AnimatedBuilder(
                animation: _compassSlide,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0.0, _compassSlide.value.dy * 60.0),
                    child: child,
                  );
                },
                child: MapCompass.cupertino(animationCurve: Curves.easeInOut),
              ),
            ],
          ),
          // end of FlutterMap widget
          // box that displays name of tapped building and route info
          Align(
            alignment: AlignmentGeometry.topCenter,
            child: SlideTransition(
              position: _nameBoxSlide,
              child: Padding(
                padding: EdgeInsetsGeometry.all(10),
                child: Container(
                  height: 115,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFF003C71),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [BoxShadow(blurRadius: 3)],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _selectedBuilding?.name ?? "",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _selectionAnimationController.reverse().then((
                                  _,
                                ) {
                                  // ait until the animation finishes,
                                  // then clear the state
                                  if (mounted) {
                                    setState(() {
                                      _isRouting = false;
                                      _destinationMarker = null;
                                      _selectedBuilding = null;
                                      _routeFuture =
                                          null; // Clear the drawn route line
                                    });
                                  }
                                });
                              },
                              icon: Icon(Icons.close, color: Colors.white),
                            ),
                          ],
                        ),
                        // row that shows information about the rout (distance,
                        // duration) and whether or not the user has any
                        // classes in the building
                        Row(
                          children: [
                            FutureBuilder<Map<String, dynamic>>(
                              future: _routeFuture,
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  return Text(
                                    "${_formatDuration(snapshot.data!["duration"])}\n"
                                    "${_formatDistance(snapshot.data!["distance"])}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  );
                                }
                                // while fetching the route display placeholder
                                // text
                                return Text(
                                  "loading...",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontStyle: FontStyle.italic,
                                  ),
                                );
                              },
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Placeholder for classes info",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // re-center button that allows the user to move the
          // map's center to their current position
          Align(
            alignment: Alignment.bottomLeft,
            child: SlideTransition(
              position: _recenterButtonSlide,
              child: Padding(
                padding: EdgeInsetsGeometry.all(10),
                child: InkWell(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromRadius(25),
                      shape: CircleBorder(),
                      padding: EdgeInsetsGeometry.all(10),
                      backgroundColor: Color(0xFF5B6770),
                    ),
                    // on press move the camera to the user's location
                    onPressed: () {
                      if (_currentPosition == null) return;
                      _mapController.move(_currentPosition!, 17);

                      setState(() {
                        _cameraPosition = _currentPosition;
                      });

                      _checkIfCentered();
                    },
                    child: Icon(
                      Icons.navigation_outlined,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // begin navigation button that starts the step by step navigation
          SlideTransition(
            position: _navButtonSlide,
            child: Align(
              alignment: AlignmentGeometry.bottomCenter,
              child: Padding(
                padding: EdgeInsetsGeometry.all(10),
                child: ElevatedButton(
                  onPressed: () {
                    _beginNavAnimationController.forward();
                    _selectionAnimationController.reverse();
                    setState(() {
                      _isNavigating = true;
                    });
                  },
                  child: Text(
                    "Begin Navigation",
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // end navigation button that ends steps by step navigation
          SlideTransition(
            position: _closeButtonSlide,
            child: Align(
              alignment: AlignmentGeometry.bottomRight,
              child: Padding(
                padding: EdgeInsetsGeometry.all(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      _beginNavAnimationController.reverse().then((_) {
                        setState(() {
                          _isNavigating = false;
                          _isRouting = false;
                          _destinationMarker = null;
                        });
                      });
                    },
                    icon: Icon(Icons.close),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // END OF BUILD METHOD
  // ---------------------------------------------------------------------------

  // dispose
  @override
  void dispose() {
    // dispose of position stream
    _selectionAnimationController.dispose();
    _recenterAnimationController.dispose();
    _routeAnimationController.dispose();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  // _setupLocation method that gets the users current position
  Future<void> _setupLocation() async {
    // check if we have permission
    bool hasPermission = await _handlePermission();
    if (!hasPermission) {
      // if we don't have permission exit method
      return;
    }

    // get position stream
    _positionStreamSubscription =
        // create position stream and set location settings
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
          //   listen for position events
        ).listen((Position position) {
          // update position
          setState(() {
            _currentPosition = LatLng(position.latitude, position.longitude);
          });

          _checkIfCentered();
        });
  }

  // _handlerPermission method that asks the user for
  // permission to use location services
  Future<bool> _handlePermission() async {
    // permission variables
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // the service is not enabled
      return false;
    }

    // if location services are enabled check if we have permission
    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      // if we don't have permission open settings
      // and ask user for permission
      await _geolocatorPlatform.openLocationSettings();
      permission = await _geolocatorPlatform.requestPermission();

      if (permission == LocationPermission.denied) {
        // if we don't get permission return false
        return false;
      }
    }

    // if the permission is denied return false
    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    // if we have permission return true
    return true;
  }

  void _checkIfCentered() {
    if (_currentPosition == null || _cameraPosition == null) return;

    double distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _cameraPosition!.latitude,
      _cameraPosition!.longitude,
    );

    if (!_showAttribution && distance > 5) {
      _recenterAnimationController.forward();
    } else {
      _recenterAnimationController.reverse();
    }
  }

  // helper method that formats a duration object into
  // x days, y hours, z minutes format
  String _formatDuration(Duration duration) {
    // create string buffer
    StringBuffer output = StringBuffer();

    // check if the duration has days
    if (duration.inDays != 0) {
      // if the amount of days is 1 use Day
      // otherwise use Days
      if (duration.inDays == 1) {
        output.write("${duration.inDays} Day");
      } else {
        output.write("${duration.inDays} Days");
      }
    }

    // if the amount of days is 1 use Hour
    // otherwise use Hours
    if (duration.inHours != 0) {
      if (output.isNotEmpty) {
        output.write(", ");
      }
      if (duration.inHours == 1) {
        output.write("${duration.inHours} hour");
      } else {
        output.write("${duration.inHours} hours");
      }
    }

    // if the amount of days is 1 use Minute
    // otherwise use Minutes
    if (duration.inMinutes != 0) {
      if (output.isNotEmpty) {
        output.write(", ");
      }
      if (duration.inMinutes == 1) {
        output.write("${duration.inMinutes} Minute");
      } else {
        output.write("${duration.inMinutes} Minutes");
      }
    }

    // if the duration of the route is less than 1 minute
    if (output.isEmpty && duration.inSeconds > 0) {
      output.write("< 1 minute");
    }

    // return the output of the string buffer
    return output.toString();
  }

  // helper method that formats the distance for printing
  String _formatDistance(double distance) {
    // round the distance value
    int output = distance.round();

    // if the amount of meters is over 1000 use kilometers
    if (output >= 1000) {
      return "${(output / 1000).toStringAsFixed(1)} km";
    }

    // otherwise return distance in m
    return "$output m";
  }

  // fetchRoute method that performs HTTP request to generate polyline
  // and then decodes and returns it
  Future<Map<String, dynamic>> fetchRoute(LatLng start, LatLng end) async {
    // make a api request
    final response = await http.get(
      Uri.parse(
        'http://router.project-osrm.org/route/v1/foot/'
        '${start.longitude},${start.latitude};'
        '${end.longitude},${end.latitude}?'
        'overview=full&geometries=polyline&steps=true&generate_hints=false',
      ),
    );

    // if successful return response as Response object
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      Map<String, dynamic> temp =
          jsonDecode(response.body) as Map<String, dynamic>;

      // process relevant information
      String geometry = temp["routes"][0]["geometry"];
      List<PointLatLng> points = PolylinePoints.decodePolyline(geometry);
      Duration duration = Duration(
        seconds: (temp["routes"][0]["duration"] as double).round(),
      );
      double distance = temp["routes"][0]["distance"] as double;

      // create output map
      Map<String, dynamic> routeInfo = {
        "points": points,
        "distance": distance,
        "duration": duration,
      };

      // return the route information
      return routeInfo;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load response');
    }
  }
}
