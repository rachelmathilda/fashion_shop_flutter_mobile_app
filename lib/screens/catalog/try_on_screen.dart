import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/cart_item_model.dart';
import '../../models/product_model.dart';
import '../../repositories/cart_repository.dart';
import '../../services/try_on_service.dart';
import '../../theme/app_theme.dart';

enum _TryOnStage { idle, validating, ready, processing, done, error }

class TryOnScreen extends StatefulWidget {
  const TryOnScreen({super.key, required this.product});

  final ProductModel product;

  @override
  State<TryOnScreen> createState() => _TryOnScreenState();
}

class _TryOnScreenState extends State<TryOnScreen> {
  final _tryOnService = TryOnService.instance;

  _TryOnStage _stage = _TryOnStage.idle;
  File? _personPhoto;
  String? _resultImageUrl;
  String? _errorMessage;
  bool _isAddingToCart = false;

  @override
  void dispose() {
    _tryOnService.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto({required bool fromCamera}) async {
    final file = await _tryOnService.pickPersonPhoto(fromCamera: fromCamera);
    if (file == null) return;

    setState(() {
      _personPhoto = file;
      _stage = _TryOnStage.validating;
      _errorMessage = null;
    });

    final validation = await _tryOnService.validatePersonPhoto(file);
    if (!mounted) return;

    if (!validation.isValid) {
      setState(() {
        _stage = _TryOnStage.error;
        _errorMessage = validation.message;
      });
      return;
    }

    setState(() => _stage = _TryOnStage.ready);
    _generate();
  }

  Future<void> _generate() async {
    if (_personPhoto == null) return;
    setState(() {
      _stage = _TryOnStage.processing;
      _errorMessage = null;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
      final resultUrl = await _tryOnService.generateTryOn(
        personPhoto: _personPhoto!,
        garmentImageUrl: widget.product.imageUrl,
        uid: uid,
      );
      if (!mounted) return;
      setState(() {
        _resultImageUrl = resultUrl;
        _stage = _TryOnStage.done;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _stage = _TryOnStage.error;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _stage = _TryOnStage.idle;
      _personPhoto = null;
      _resultImageUrl = null;
      _errorMessage = null;
    });
  }

  Future<void> _addToCart() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Silakan login dulu')));
      return;
    }

    final size = await _pickSizeDialog();
    if (size == null) return;

    setState(() => _isAddingToCart = true);
    await CartRepository.instance.addItem(
      uid,
      CartItem(product: widget.product, selectedSize: size),
    );
    if (!mounted) return;
    setState(() => _isAddingToCart = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} ditambahkan ke keranjang'),
      ),
    );
  }

  Future<String?> _pickSizeDialog() {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih ukuran',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: widget.product.sizes.map((s) {
                  return GestureDetector(
                    onTap: () => Navigator.pop(context, s),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Text(s)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Ambil Foto'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(fromCamera: true);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(fromCamera: false);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Try-On',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
      ),
      body: SizedBox.expand(
        child: Stack(
          children: [
            _buildPreview(),
            if (_stage == _TryOnStage.idle)
              Positioned(
                bottom: 32,
                left: 24,
                right: 24,
                child: ElevatedButton.icon(
                  onPressed: _showPickerSheet,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Upload Photo'),
                ),
              ),
            if (_stage == _TryOnStage.done) ...[
              Positioned(
                bottom: 32,
                left: 24,
                right: 24,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _reset,
                        child: const Text('Coba Foto Lain'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isAddingToCart ? null : _addToCart,
                        child: _isAddingToCart
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : const Text('Add to Cart'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_stage == _TryOnStage.error)
              Positioned(
                bottom: 32,
                left: 24,
                right: 24,
                child: ElevatedButton.icon(
                  onPressed: _showPickerSheet,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    switch (_stage) {
      case _TryOnStage.idle:
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.greyLight,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_outline, size: 100, color: AppColors.grey),
                SizedBox(height: 12),
                Text(
                  'Upload your photo\nto try on the outfit',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );

      case _TryOnStage.validating:
      case _TryOnStage.processing:
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.greyLight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_personPhoto != null)
                Image.file(_personPhoto!, fit: BoxFit.cover),
              Container(color: Colors.black.withValues(alpha: 0.35)),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: AppColors.white),
                    const SizedBox(height: 16),
                    Text(
                      _stage == _TryOnStage.validating
                          ? 'Memeriksa foto...'
                          : 'Memasangkan outfit...',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: AppColors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case _TryOnStage.ready:
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.greyLight,
          child: _personPhoto != null
              ? Image.file(_personPhoto!, fit: BoxFit.cover)
              : null,
        );

      case _TryOnStage.done:
        return Image.network(
          _resultImageUrl!,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Center(child: Text('Gagal memuat hasil try-on')),
        );

      case _TryOnStage.error:
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.greyLight,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: AppColors.grey,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage ?? 'Terjadi kesalahan',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: AppColors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}
