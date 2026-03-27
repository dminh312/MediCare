import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

class PharmacyDetails {
  final String id;
  final String name;
  final String address;
  final LatLng position;
  final double rating;
  final bool? openNow;
  final double distanceInMeters;

  PharmacyDetails({
    required this.id,
    required this.name,
    required this.address,
    required this.position,
    required this.rating,
    this.openNow,
    this.distanceInMeters = 0.0,
  });
}

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  GoogleMapController? mapController;
  bool _locationPermissionGranted = false;
  bool _isLoading = true;
  LatLng? _initialPosition;
  Set<Marker> _pharmacyMarkers = {};
  PharmacyDetails? _selectedPharmacy;
  final List<PharmacyDetails> _pharmaciesList = [];
  BitmapDescriptor? _customIconRed;
  BitmapDescriptor? _customIconBlue;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _checkLocationPermission();

    if (_initialPosition != null) {
      await _fetchNearbyPharmacies(_initialPosition!);
    }

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<BitmapDescriptor> _getMarkerBitmap(int size, bool isSelected) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Paint paintMain = Paint()..color = isSelected ? Colors.blue : const Color(0xFFff5252);
    final Paint paintWhite = Paint()..color = Colors.white;

    final double radius = size / 2;
    // Add a simple drop shadow
    canvas.drawShadow(
      Path()..addOval(Rect.fromCircle(center: Offset(radius, radius), radius: radius)),
      Colors.black,
      4,
      true,
    );
    canvas.drawCircle(Offset(radius, radius), radius, paintWhite);
    canvas.drawCircle(Offset(radius, radius), radius * 0.8, paintMain);
    canvas.drawCircle(Offset(radius, radius), radius * 0.3, paintWhite);

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(data!.buffer.asUint8List());
  }

  void _updateMarkers() {
    if (_customIconRed == null || _customIconBlue == null) return;

    Set<Marker> markers = {};
    for (var details in _pharmaciesList) {
      final isSelected = _selectedPharmacy?.id == details.id;
      markers.add(
        Marker(
          markerId: MarkerId(details.id),
          position: details.position,
          icon: isSelected ? _customIconBlue! : _customIconRed!,
          zIndexInt: isSelected ? 1 : 0,
          onTap: () {
            setState(() {
              _selectedPharmacy = details;
              _updateMarkers();
            });
            mapController?.animateCamera(CameraUpdate.newLatLng(details.position));
          },
        ),
      );
    }
    _pharmacyMarkers = markers;
  }

  Future<void> _fetchNearbyPharmacies(LatLng location) async {
    final apiKey = dotenv.env['MAPS_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      debugPrint("Google API key is missing");
      return;
    }

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=${location.latitude},${location.longitude}'
        '&radius=3000'
        '&type=pharmacy'
        '&key=$apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>? ?? [];

        _pharmaciesList.clear();
        _customIconRed ??= await _getMarkerBitmap(36, false);
        _customIconBlue ??= await _getMarkerBitmap(42, true);

        for (var place in results) {
          final baseGeometry = place['geometry'];
          if (baseGeometry != null) {
            final locationData = baseGeometry['location'];
            final lat = locationData['lat'] as double;
            final lng = locationData['lng'] as double;
            final name = place['name'] ?? 'Pharmacy';
            final address = place['vicinity'] ?? '';
            final placeId = place['place_id'] as String;
            final rating = (place['rating'] as num?)?.toDouble() ?? 4.5;
            
            final openingHours = place['opening_hours'];
            final openNow = openingHours != null ? openingHours['open_now'] as bool? : null;

            final distance = Geolocator.distanceBetween(
              location.latitude,
              location.longitude,
              lat,
              lng,
            );

            _pharmaciesList.add(
              PharmacyDetails(
                id: placeId,
                name: name,
                address: address,
                position: LatLng(lat, lng),
                rating: rating,
                openNow: openNow,
                distanceInMeters: distance,
              )
            );
          }
        }
        
        _pharmaciesList.sort((a, b) => a.distanceInMeters.compareTo(b.distanceInMeters));

        if (mounted) {
          setState(() {
            if (_pharmaciesList.isNotEmpty) {
              _selectedPharmacy = _pharmaciesList.first;
              mapController?.animateCamera(CameraUpdate.newLatLng(_pharmaciesList.first.position));
            }
            _updateMarkers();
          });
        }
      }
    } catch (e) {
      debugPrint("Failed to fetch nearby pharmacies: $e");
    }
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    if (mounted) {
      setState(() {
        _locationPermissionGranted = true;
      });
    }

    try {
      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _initialPosition = LatLng(position.latitude, position.longitude);
    } catch (e) {
      debugPrint("Could not fetch location: $e");
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    if (mounted) {
      mapController = controller;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF020617) : const Color(0xFFfffbfb);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: _isLoading
          ? _buildLoadingState(isDarkMode)
          : _initialPosition == null
              ? _buildNoLocationState(isDarkMode)
              : _buildMapInterface(isDarkMode),
    );
  }

  Widget _buildLoadingState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            "Locating you...",
            style: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNoLocationState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 64, color: isDarkMode ? Colors.grey[700] : Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "Unable to determine your location.",
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.grey[900],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Please enable location services to find nearby pharmacies.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapInterface(bool isDarkMode) {
    return Stack(
      children: [
        // Map Canvas Area
        Positioned.fill(
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialPosition!,
              zoom: 15.0,
            ),
            myLocationEnabled: _locationPermissionGranted,
            myLocationButtonEnabled: false, // hide default button, we can add custom if needed
            zoomControlsEnabled: false, // cleaner UI
            mapToolbarEnabled: false,
            markers: _pharmacyMarkers,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 120,
              bottom: _selectedPharmacy != null ? 220 : 0,
            ),
          ),
        ),

        // Custom Top Bar overlay
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _buildCustomTopBar(isDarkMode),
        ),

        // Quick Filters Overlay
        Positioned(
          top: MediaQuery.of(context).padding.top + 60,
          left: 0,
          right: 0,
          child: _buildQuickFilters(isDarkMode),
        ),

        // Floating Action Button for Location
        Positioned(
          bottom: _selectedPharmacy != null ? 240 : 24,
          right: 16,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: isDarkMode ? const Color(0xFF1a1111) : Colors.white,
            foregroundColor: const Color(0xFFff5252),
            onPressed: () {
              if (_initialPosition != null) {
                mapController?.animateCamera(CameraUpdate.newLatLngZoom(_initialPosition!, 15));
              }
            },
            child: const Icon(Icons.my_location),
          ),
        ),

        // Bottom Detail Card
        if (_selectedPharmacy != null)
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: _buildBottomDetailCard(_selectedPharmacy!, isDarkMode),
          ),
      ],
    );
  }

  Widget _buildCustomTopBar(bool isDarkMode) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: MediaQuery.of(context).padding.top + 50,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 8, right: 16),
          color: isDarkMode ? Colors.black.withValues(alpha: 0.5) : const Color(0xFFfffbfb).withValues(alpha: 0.8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.notifications_none, color: isDarkMode ? Colors.grey[400] : Colors.grey[500]),
                onPressed: () {},
              )
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildQuickFilters(bool isDarkMode) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFilterChip("Open Now", true, isDarkMode),
          const SizedBox(width: 8),
          _buildFilterChip("Home Delivery", false, isDarkMode),
          const SizedBox(width: 8),
          _buildFilterChip("Insurance Accepted", false, isDarkMode),
          const SizedBox(width: 8),
          _buildFilterChip("24/7 Service", false, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isPrimary, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFFff5252) : (isDarkMode ? const Color(0xFF1a1111) : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: isPrimary ? null : Border.all(color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!),
        boxShadow: isPrimary
            ? [BoxShadow(color: const Color(0xFFff5252).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isPrimary ? Colors.white : (isDarkMode ? Colors.grey[300] : Colors.grey[700]),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildBottomDetailCard(PharmacyDetails pharmacy, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1a1111) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFff5252).withValues(alpha: 0.12),
            blurRadius: 32,
            offset: const Offset(0, 8),
          )
        ],
        border: Border.all(color: const Color(0xFFff5252).withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFFff5252).withValues(alpha: 0.15) : const Color(0xFFffebee),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_pharmacy, color: Color(0xFFff5252), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pharmacy.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, leadingDistribution: TextLeadingDistribution.even, height: 1.2, color: isDarkMode ? Colors.white : Colors.black),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(pharmacy.address, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text("${pharmacy.rating}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDarkMode ? Colors.white : Colors.black)),
                        const SizedBox(width: 8),
                        Text(
                          pharmacy.distanceInMeters < 1000 
                            ? "• ${(pharmacy.distanceInMeters).toStringAsFixed(0)}m away" 
                            : "• ${(pharmacy.distanceInMeters / 1000).toStringAsFixed(1)}km away", 
                          style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        if (pharmacy.openNow != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            pharmacy.openNow! ? "• Open Now" : "• Closed",
                            style: TextStyle(
                              color: pharmacy.openNow! ? Colors.green : Colors.red,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPharmacy = null;
                    _updateMarkers();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: isDarkMode ? Colors.grey[400] : Colors.grey[600], size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: Icon(Icons.call, size: 18, color: isDarkMode ? Colors.white : Colors.grey[800]),
                  label: Text("Call", style: TextStyle(color: isDarkMode ? Colors.white : Colors.grey[800], fontWeight: FontWeight.bold)),
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.near_me, size: 18),
                  label: const Text("Directions", style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    final lat = pharmacy.position.latitude;
                    final lng = pharmacy.position.longitude;
                    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
                    try {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } catch (e) {
                      debugPrint('Could not launch maps: $e');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFFff5252),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 4,
                    shadowColor: const Color(0xFFff5252).withValues(alpha: 0.4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
