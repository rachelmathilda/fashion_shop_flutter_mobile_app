import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../models/address_model.dart';
import '../../models/order_draft.dart';
import '../../theme/app_theme.dart';
import '../../widgets/delivery_fee.dart';
import '../../widgets/step_indicator.dart';

class ShippingScreen extends StatefulWidget {
  const ShippingScreen({super.key, required this.draft});

  final OrderDraft draft;

  @override
  State<ShippingScreen> createState() => _ShippingScreenState();
}

class _ShippingScreenState extends State<ShippingScreen> {
  AddressModel? _address;

  Future<void> _pickAddress() async {
    final result = await context.push<AddressModel>('/order-address');
    if (result == null) return;
    setState(() {
      _address = result;
      widget.draft.addressText = result.addressText;
      widget.draft.addressLat = result.lat;
      widget.draft.addressLng = result.lng;
      widget.draft.deliveryFee = calculateDeliveryFee(result.lat, result.lng);
    });
  }

  void _continue() {
    if (_address == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih alamat pengiriman dulu')),
      );
      return;
    }
    context.push('/payment', extra: widget.draft);
  }

  @override
  Widget build(BuildContext context) {
    final center = _address != null
        ? LatLng(_address!.lat, _address!.lng)
        : const LatLng(-6.2088, 106.8456);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          SafeArea(child: const StepIndicator(current: 1)),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 220,
                    child: Stack(
                      children: [
                        FlutterMap(
                          options: MapOptions(
                            initialCenter: center,
                            initialZoom: 14,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.vaelys',
                            ),
                            if (_address != null)
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: center,
                                    width: 40,
                                    height: 40,
                                    child: const Icon(
                                      Icons.location_pin,
                                      color: AppColors.primary,
                                      size: 36,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        if (_address == null)
                          GestureDetector(
                            onTap: _pickAddress,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.08,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'Find your location',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                  ),
                                ),
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
                        GestureDetector(
                          onTap: _pickAddress,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Address',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.edit_outlined,
                                      color: AppColors.grey,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _address?.addressText ?? 'Add detail',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _feeRow(
                          context,
                          'Delivery Fee',
                          '\$ ${widget.draft.deliveryFee.toStringAsFixed(2)}',
                        ),
                        _feeRow(
                          context,
                          'Total Price',
                          '\$ ${widget.draft.total.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: ElevatedButton(
              onPressed: _continue,
              child: const Text('Go To Payment'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _feeRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
