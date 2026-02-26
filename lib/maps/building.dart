import 'package:latlong2/latlong.dart';

class Building {
  final String name;
  final LatLng centre;
  final List<LatLng> polygon;

  Building(this.name, this.centre, this.polygon);
}
