import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:image_picker/image_picker.dart';

class TryOnValidationResult {
  final bool isValid;
  final String message;

  TryOnValidationResult(this.isValid, this.message);
}

class TryOnService {
  TryOnService._();
  static final TryOnService instance = TryOnService._();

  static const _replicateToken = String.fromEnvironment('REPLICATE_API_TOKEN');
  static const _modelVersion =
      'c871bb9b046607b680449ecbae55fd8c6d945e0a1948644bf2361b3d021d3aa';

  final _dio = Dio(BaseOptions(baseUrl: 'https://api.replicate.com/v1'));

  final _picker = ImagePicker();
  final _poseDetector = PoseDetector(
    options: PoseDetectorOptions(mode: PoseDetectionMode.single),
  );
  final _segmenter = SelfieSegmenter(
    mode: SegmenterMode.single,
    enableRawSizeMask: false,
  );

  Future<File?> pickPersonPhoto({required bool fromCamera}) async {
    final xfile = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      preferredCameraDevice: CameraDevice.front,
    );
    if (xfile == null) return null;
    return File(xfile.path);
  }

  Future<TryOnValidationResult> validatePersonPhoto(File file) async {
    final inputImage = InputImage.fromFile(file);

    final poses = await _poseDetector.processImage(inputImage);
    if (poses.isEmpty) {
      return TryOnValidationResult(
        false,
        'Tidak ada orang yang terdeteksi, coba foto lagi dengan pencahayaan lebih terang.',
      );
    }

    final landmarks = poses.first.landmarks;
    final requiredPoints = [
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.rightKnee,
    ];
    final missing = requiredPoints.where((p) => landmarks[p] == null).toList();
    if (missing.isNotEmpty) {
      return TryOnValidationResult(
        false,
        'Pastikan seluruh tubuh dari bahu sampai lutut terlihat di frame.',
      );
    }

    final mask = await _segmenter.processImage(inputImage);
    if (mask == null) {
      return TryOnValidationResult(
        false,
        'Gagal memisahkan orang dari background, coba foto dengan latar lebih polos.',
      );
    }

    return TryOnValidationResult(true, 'Foto valid');
  }

  Future<String> _uploadPersonPhoto(File file, String uid) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('try_on')
        .child(uid)
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<String> generateTryOn({
    required File personPhoto,
    required String garmentImageUrl,
    required String uid,
  }) async {
    if (_replicateToken.isEmpty) {
      throw Exception(
        'REPLICATE_API_TOKEN belum diset. Jalankan dengan --dart-define=REPLICATE_API_TOKEN=xxx',
      );
    }

    final personImageUrl = await _uploadPersonPhoto(personPhoto, uid);

    final createResponse = await _dio.post(
      '/predictions',
      options: Options(headers: {'Authorization': 'Token $_replicateToken'}),
      data: {
        'version': _modelVersion,
        'input': {
          'human_img': personImageUrl,
          'garm_img': garmentImageUrl,
          'garment_des': 'clothing item',
        },
      },
    );

    final predictionId = createResponse.data['id'] as String;
    return _pollUntilDone(predictionId);
  }

  Future<String> _pollUntilDone(String predictionId) async {
    final deadline = DateTime.now().add(const Duration(minutes: 2));

    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(seconds: 2));

      final response = await _dio.get(
        '/predictions/$predictionId',
        options: Options(headers: {'Authorization': 'Token $_replicateToken'}),
      );

      final data = response.data as Map<String, dynamic>;
      final status = data['status'] as String;

      if (status == 'succeeded') {
        final output = data['output'];
        if (output is String) return output;
        if (output is List && output.isNotEmpty) return output.first as String;
        throw Exception('Format output try-on tidak dikenali.');
      }

      if (status == 'failed' || status == 'canceled') {
        throw Exception('Try-on gagal diproses: ${data['error']}');
      }
    }

    throw TimeoutException('Try-on butuh waktu terlalu lama, coba lagi.');
  }

  void dispose() {
    _poseDetector.close();
    _segmenter.close();
  }
}
