import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class Building {
  final String name;
  final LatLng centre;
  final Polygon polygon;

  Building(this.name, this.centre, this.polygon);
}
