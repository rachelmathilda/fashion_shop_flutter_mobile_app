import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../models/address_model.dart';
import '../../repositories/address_repository.dart';
import '../../theme/app_theme.dart';

class AddressDetailScreen extends StatefulWidget {
  const AddressDetailScreen({super.key});

  @override
  State<AddressDetailScreen> createState() => _AddressDetailScreenState();
}

class _AddressDetailScreenState extends State<AddressDetailScreen> {
  final _mapController = MapController();
  final _detailCtrl = TextEditingController();
  final _dio = Dio();

  LatLng _center = const LatLng(-6.2088, 106.8456);
  String _addressText = 'Mencari lokasi...';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _detailCtrl.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() {
          _addressText = 'Izin lokasi ditolak, geser peta untuk memilih';
          _loading = false;
        });
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      _center = LatLng(position.latitude, position.longitude);
      _mapController.move(_center, 16);
      await _reverseGeocode(_center);
    } catch (_) {
      setState(() {
        _addressText = 'Gagal mendapat lokasi, geser peta untuk memilih';
        _loading = false;
      });
    }
  }

  Future<void> _reverseGeocode(LatLng point) async {
    setState(() => _loading = true);
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': point.latitude,
          'lon': point.longitude,
        },
        options: Options(headers: {'User-Agent': 'VaelysApp/1.0'}),
      );
      setState(() {
        _addressText = response.data['display_name'] ?? 'Lokasi terpilih';
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _addressText =
            '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
        _loading = false;
      });
    }
  }

  Future<void> _confirm() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Silakan login dulu')));
      return;
    }
    setState(() => _saving = true);
    final address = AddressModel(
      id: '',
      addressText: _detailCtrl.text.trim().isEmpty
          ? _addressText
          : '$_addressText, ${_detailCtrl.text.trim()}',
      lat: _center.latitude,
      lng: _center.longitude,
      isDefault: true,
    );
    await AddressRepository.instance.save(uid, address);
    if (!mounted) return;
    setState(() => _saving = false);
    context.pop(address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Address Detail',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.primary),
            onPressed: _saving ? null : _confirm,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: 16,
                    onPositionChanged: (position, hasGesture) {
                      if (hasGesture) {
                        _center = position.center;
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.vaelys',
                    ),
                  ],
                ),
                const Center(
                  child: Icon(
                    Icons.location_pin,
                    size: 44,
                    color: AppColors.primary,
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton.small(
                    backgroundColor: AppColors.white,
                    onPressed: () => _reverseGeocode(_center),
                    child: const Icon(
                      Icons.my_location,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _loading ? 'Mencari alamat...' : _addressText,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _detailCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Detail alamat, patokan, no rumah',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
