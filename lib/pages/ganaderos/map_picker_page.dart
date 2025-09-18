// lib/pages/ganaderos/map_picker_page.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class MapPickerPage extends StatefulWidget {
  final LatLng? initialLocation;

  const MapPickerPage({super.key, this.initialLocation});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentPosition;
  final TextEditingController _searchController = TextEditingController();
  final Uuid _uuid = const Uuid();
  String _sessionToken = '';
  List<dynamic> _placePredictions = [];

  @override
  void initState() {
    super.initState();
    _sessionToken = _uuid.v4();
    _currentPosition = widget.initialLocation ?? const LatLng(-12.046374, -77.042793); // Lima, Peru
    if (widget.initialLocation == null) {
      _getUserLocation();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition();
      final newPosition = LatLng(position.latitude, position.longitude);
      
      if(mounted) {
        setState(() { _currentPosition = newPosition; });
        final controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newLatLng(newPosition));
      }
    } catch (e) { /* Manejar error */ }
  }

  Future<void> _onSearchChanged(String input) async {
    if (input.isEmpty) {
      if (mounted) setState(() => _placePredictions = []);
      return;
    }
    
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;
    final url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&sessiontoken=$_sessionToken&language=es&region=pe';
    
    final response = await http.get(Uri.parse(url), headers: await const GoogleApiHeaders().getHeaders());
    if (response.statusCode == 200 && mounted) {
      setState(() {
        _placePredictions = json.decode(response.body)['predictions'];
      });
    }
  }

  Future<void> _getPlaceDetails(String placeId) async {
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;
    final url = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey&sessiontoken=$_sessionToken&language=es';
    
    final response = await http.get(Uri.parse(url), headers: await const GoogleApiHeaders().getHeaders());
    if (response.statusCode == 200 && mounted) {
      final location = json.decode(response.body)['result']['geometry']['location'];
      final latLng = LatLng(location['lat'], location['lng']);
      
      final controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
      setState(() {
        _placePredictions = [];
        _searchController.clear();
        _sessionToken = _uuid.v4();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(target: _currentPosition!, zoom: 14),
            onMapCreated: (GoogleMapController controller) {
              if (!_controller.isCompleted) {
                _controller.complete(controller);
              }
            },
            onCameraMove: (CameraPosition position) {
              _currentPosition = position.target;
            },
            zoomControlsEnabled: false,
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40.0),
              child: Icon(Icons.location_pin, size: 40.0, color: Colors.red),
            ),
          ),
          Positioned(
            top: 40,
            left: 15,
            right: 15,
            child: Column(
              children: [
                Material(
                  borderRadius: BorderRadius.circular(8.0),
                  elevation: 4.0,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar dirección o ciudad...',
                      prefixIcon: const Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(15),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _placePredictions = []);
                        },
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                if (_placePredictions.isNotEmpty)
                  Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(8.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _placePredictions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_placePredictions[index]['description']),
                          onTap: () => _getPlaceDetails(_placePredictions[index]['place_id']),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Confirmar Ubicación'),
                onPressed: () {
                  Navigator.of(context).pop(_currentPosition);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}