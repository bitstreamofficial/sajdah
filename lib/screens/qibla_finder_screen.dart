import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';

class QiblaFinderScreen extends StatefulWidget {
  @override
  _QiblaFinderScreenState createState() => _QiblaFinderScreenState();
}

class _QiblaFinderScreenState extends State<QiblaFinderScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  double _qiblaDirection = 0.0;
  double _deviceHeading = 0.0;
  double _qiblaBearing = 0.0;
  Position? _currentPosition;
  bool _isLoading = true;
  String _statusMessage = 'Initializing...';

  // Kaaba coordinates
  static const double kaabaLat = 21.4225;
  static const double kaabaLng = 39.8262;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _initializeQiblaFinder();
  }

  Future<void> _initializeQiblaFinder() async {
    try {
      // Request permissions
      await _requestPermissions();
      
      // Get current location
      await _getCurrentLocation();
      
      // Calculate Qibla bearing
      _calculateQiblaBearing();
      
      // Start compass listening
      _startCompassListening();
      
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermissions() async {
    // Request location permission
    var locationStatus = await Permission.location.request();
    if (locationStatus != PermissionStatus.granted) {
      throw Exception('Location permission required');
    }

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _statusMessage = 'Getting your location...';
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _statusMessage = 'Location found!';
      });
    } catch (e) {
      throw Exception('Failed to get location: ${e.toString()}');
    }
  }

  void _calculateQiblaBearing() {
    if (_currentPosition == null) return;

    // Convert degrees to radians
    double lat1 = _currentPosition!.latitude * math.pi / 180;
    double lng1 = _currentPosition!.longitude * math.pi / 180;
    double lat2 = kaabaLat * math.pi / 180;
    double lng2 = kaabaLng * math.pi / 180;

    // Calculate bearing using great circle formula
    double dLng = lng2 - lng1;
    double y = math.sin(dLng) * math.cos(lat2);
    double x = math.cos(lat1) * math.sin(lat2) - 
               math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
    
    double bearing = math.atan2(y, x);
    
    // Convert to degrees and normalize to 0-360
    _qiblaBearing = (bearing * 180 / math.pi + 360) % 360;
    
    setState(() {
      _statusMessage = 'Qibla direction calculated!';
    });
  }

  void _startCompassListening() {
    FlutterCompass.events?.listen((CompassEvent event) {
      if (event.heading != null) {
        setState(() {
          _deviceHeading = event.heading!;
          // Calculate relative direction from device to Qibla
          _qiblaDirection = (_qiblaBearing - _deviceHeading + 360) % 360;
          _isLoading = false;
          _statusMessage = 'Compass active';
        });
      }
    });
  }

  String _getDirectionInstruction() {
    if (_qiblaDirection < 5 || _qiblaDirection > 355) {
      return 'Perfect! You\'re facing Qibla';
    } else if (_qiblaDirection <= 180) {
      return 'Turn ${_qiblaDirection.toStringAsFixed(0)}° to the right';
    } else {
      return 'Turn ${(360 - _qiblaDirection).toStringAsFixed(0)}° to the left';
    }
  }

  Color _getDirectionColor() {
    if (_qiblaDirection < 5 || _qiblaDirection > 355) {
      return Colors.green;
    } else if (_qiblaDirection < 30 || _qiblaDirection > 330) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5E6D3), Color(0xFFE8D5C4)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      'QIBLA FINDER',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown[800],
                      ),
                    ),
                    Spacer(),
                    if (_currentPosition != null)
                      Text(
                        '📍 ${_currentPosition!.latitude.toStringAsFixed(2)}, ${_currentPosition!.longitude.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.brown[600],
                        ),
                      ),
                  ],
                ),
              ),

              if (_isLoading) ...[
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.brown[700]!),
                        ),
                        SizedBox(height: 20),
                        Text(
                          _statusMessage,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.brown[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                SizedBox(height: 20),

                // Status message
                Text(
                  _statusMessage,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.brown[600],
                  ),
                ),

                SizedBox(height: 30),

                // Compass
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Kaaba direction indicator
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getDirectionColor(),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.mosque, color: Colors.white, size: 20),
                        ),

                        SizedBox(height: 20),

                        // Compass Circle
                        Container(
                          width: 300,
                          height: 300,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Compass background
                              Container(
                                width: 300,
                                height: 300,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.9),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                              ),

                              // Cardinal directions (these rotate with device)
                              Transform.rotate(
                                angle: _deviceHeading * math.pi / 180,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Positioned(
                                      top: 10,
                                      child: Text(
                                        'N',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.brown[800],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 10,
                                      child: Text(
                                        'S',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.brown[800],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 10,
                                      child: Text(
                                        'W',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.brown[800],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 10,
                                      child: Text(
                                        'E',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.brown[800],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Qibla direction needle (always points to Qibla)
                              Transform.rotate(
                                angle: _qiblaDirection * math.pi / 180,
                                child: Container(
                                  width: 4,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [_getDirectionColor(), Colors.orange],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),

                              // North indicator (device's north)
                              Transform.rotate(
                                angle: -_deviceHeading * math.pi / 180,
                                child: Container(
                                  width: 2,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.blue[700],
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                              ),

                              // Center dot
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.brown[800],
                                  shape: BoxShape.circle,
                                ),
                              ),

                              // Compass markings
                              Transform.rotate(
                                angle: -_deviceHeading * math.pi / 180,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: List.generate(72, (index) {
                                    final angle = (index * 5) * math.pi / 180;
                                    final isMainDirection = index % 18 == 0;
                                    return Transform.rotate(
                                      angle: angle,
                                      child: Container(
                                        width: 2,
                                        height: isMainDirection ? 20 : 10,
                                        margin: EdgeInsets.only(
                                          top: isMainDirection ? 0 : 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.brown[300],
                                          borderRadius: BorderRadius.circular(1),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 40),

                        // Direction info
                        Text(
                          '${_qiblaDirection.toStringAsFixed(0)}°',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: _getDirectionColor(),
                          ),
                        ),

                        SizedBox(height: 8),

                        Text(
                          'Angle to Qibla',
                          style: TextStyle(fontSize: 14, color: Colors.brown[600]),
                        ),

                        SizedBox(height: 20),

                        // Bearing info
                        Text(
                          'Qibla Bearing: ${_qiblaBearing.toStringAsFixed(0)}°',
                          style: TextStyle(fontSize: 12, color: Colors.brown[500]),
                        ),

                        SizedBox(height: 30),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: _getDirectionColor().withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getDirectionColor(),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _getDirectionInstruction(),
                            style: TextStyle(
                              fontSize: 14,
                              color: _getDirectionColor(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}