// lib/pages/rutas/ruta_detail_page.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transdovic_erp/main.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

class RutaDetailPage extends StatefulWidget {
  final String routeId;

  const RutaDetailPage({super.key, required this.routeId});

  @override
  State<RutaDetailPage> createState() => _RutaDetailPageState();
}

class _RutaDetailPageState extends State<RutaDetailPage> {
  final Completer<GoogleMapController> _controller = Completer();
  bool _isLoading = true;

  // Estado para el mapa
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Map<String, dynamic>? _routeData;

  // Tu API Key
  static const String _googleMapsApiKey = 'AIzaSyB3f7SMf8Y4lHnJ6vwMB9pCom5HU__-bI0';

  @override
  void initState() {
    super.initState();
    _fetchRouteDetails();
  }

  Future<void> _fetchRouteDetails() async {
    try {
      final data = await supabase
          .from('routes')
          .select('*, route_stops(*, ranchers(*))')
          .eq('id', widget.routeId)
          .single();

      if (mounted) {
        setState(() {
          _routeData = data;
          _isLoading = false;
        });
        await _buildMapElements(data);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar la ruta: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _buildMapElements(Map<String, dynamic> data) async {
    final List stops = data['route_stops'];
    if (stops.isEmpty) return;

    final Set<Marker> markers = {};
    final List<LatLng> waypoints = [];

    // Ordenar paradas por stop_order
    stops.sort((a, b) => (a['stop_order'] ?? 0).compareTo(b['stop_order'] ?? 0));

    // Crear marcadores
    for (int i = 0; i < stops.length; i++) {
      final stop = stops[i];
      final rancher = stop['ranchers'];
      
      if (rancher != null && rancher['latitude'] != null && rancher['longitude'] != null) {
        final position = LatLng(
          double.parse(rancher['latitude'].toString()), 
          double.parse(rancher['longitude'].toString())
        );
        waypoints.add(position);

        markers.add(
          Marker(
            markerId: MarkerId(rancher['id'].toString()),
            position: position,
            infoWindow: InfoWindow(
              title: rancher['commercial_name'] ?? 'Parada ${i + 1}',
              snippet: 'Parada #${stop['stop_order']}',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              i == 0 
                ? BitmapDescriptor.hueGreen  // Primera parada en verde
                : i == stops.length - 1
                  ? BitmapDescriptor.hueRed  // Última parada en rojo
                  : BitmapDescriptor.hueBlue // Paradas intermedias en azul
            ),
          ),
        );
      }
    }

    setState(() {
      _markers = markers;
    });

    // Crear ruta usando Google Directions API directamente
    if (waypoints.length > 1) {
      await _createRoute(waypoints);
    }

    // Ajustar cámara para mostrar toda la ruta
    _zoomToFitRoute(waypoints);
  }

  Future<void> _createRoute(List<LatLng> waypoints) async {
    try {
      debugPrint('Creando ruta con ${waypoints.length} puntos...');
      
      if (waypoints.length < 2) return;
      
      final origin = waypoints.first;
      final destination = waypoints.last;
      
      // Crear waypoints intermedios para la URL
      String waypointsStr = '';
      if (waypoints.length > 2) {
        final intermediateWaypoints = waypoints.sublist(1, waypoints.length - 1);
        waypointsStr = '&waypoints=' + intermediateWaypoints
            .map((point) => '${point.latitude},${point.longitude}')
            .join('|');
      }

      final String url = 
        'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '$waypointsStr'
        '&key=$_googleMapsApiKey';

      debugPrint('URL de la API: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        debugPrint('Status de la API: ${data['status']}');
        
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final String encodedPolyline = data['routes'][0]['overview_polyline']['points'];
          final List<LatLng> polylinePoints = _decodePolyline(encodedPolyline);

          final Polyline routePolyline = Polyline(
            polylineId: const PolylineId('route'),
            color: Colors.blue,
            width: 6,
            points: polylinePoints,
          );

          setState(() {
            _polylines = {routePolyline};
          });
          
          debugPrint('Ruta creada exitosamente con ${polylinePoints.length} puntos');
        } else {
          debugPrint('Error de la API: ${data['error_message'] ?? data['status']}');
          _createFallbackRoute(waypoints);
        }
      } else {
        debugPrint('Error HTTP: ${response.statusCode}');
        _createFallbackRoute(waypoints);
      }
      
    } catch (e) {
      debugPrint('Error al crear ruta: $e');
      _createFallbackRoute(waypoints);
    }
  }

  // Decodificar polyline de Google (algoritmo estándar)
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polylineCoordinates = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polylineCoordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polylineCoordinates;
  }

  void _createFallbackRoute(List<LatLng> waypoints) {
    final Polyline fallbackPolyline = Polyline(
      polylineId: const PolylineId('fallback_route'),
      color: Colors.orange,
      width: 4,
      points: waypoints,
      patterns: [PatternItem.dash(15), PatternItem.gap(10)], // Línea punteada
    );

    setState(() {
      _polylines = {fallbackPolyline};
    });
  }
  
  Future<void> _zoomToFitRoute(List<LatLng> points) async {
    if (points.isEmpty) return;
    
    final controller = await _controller.future;

    if (points.length == 1) {
      controller.animateCamera(CameraUpdate.newLatLngZoom(points.first, 14));
    } else {
      double minLat = points.first.latitude;
      double maxLat = points.first.latitude;
      double minLng = points.first.longitude;
      double maxLng = points.first.longitude;

      for (final point in points) {
        minLat = math.min(minLat, point.latitude);
        maxLat = math.max(maxLat, point.latitude);
        minLng = math.min(minLng, point.longitude);
        maxLng = math.max(maxLng, point.longitude);
      }

      final LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100.0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_routeData == null ? 'Cargando Ruta...' : 'Ruta del ${_routeData!['route_date']}'),
        actions: [
          if (!_isLoading && _routeData != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _fetchRouteDetails(),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando ruta...'),
                ],
              ),
            )
          : Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(-12.0464, -77.0428), // Lima, Perú
                    zoom: 10,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    if (!_controller.isCompleted) {
                      _controller.complete(controller);
                    }
                  },
                  markers: _markers,
                  polylines: _polylines,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                ),
                if (_routeData != null)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Información de la Ruta',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Fecha: ${_routeData!['route_date']}'),
                            Text('Paradas: ${(_routeData!['route_stops'] as List).length}'),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}