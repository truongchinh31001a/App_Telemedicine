// 📁 capture_image_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'camera_overlay.dart';

class CaptureImageScreen extends StatefulWidget {
  const CaptureImageScreen({super.key});

  @override
  State<CaptureImageScreen> createState() => _CaptureImageScreenState();
}

class _CaptureImageScreenState extends State<CaptureImageScreen> {
  CameraController? _controller;
  bool _isFlashOn = false;
  bool _isLoading = false;
  String? _blurResult;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras.first, ResolutionPreset.max, enableAudio: false);
    await _controller!.initialize();
    setState(() {});
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;
    _isFlashOn = !_isFlashOn;
    await _controller!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
    setState(() {});
  }

  Future<void> _takePicture() async {
    setState(() {
      _isLoading = true;
      _blurResult = null;
    });

    final file = await _controller!.takePicture();
    final bytes = await File(file.path).readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded != null) {
      final blurScore = _calculateSharpness(decoded);
      final isBlur = blurScore < 10.0;

      setState(() {
        _blurResult = isBlur ? 'Ảnh có thể bị mờ. Vui lòng chụp lại.' : 'Ảnh rõ nét.';
        _isLoading = false;
      });

      if (!isBlur) Navigator.of(context, rootNavigator: true).pop(file);
    } else {
      setState(() {
        _blurResult = 'Không thể đọc ảnh.';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Navigator.of(context, rootNavigator: true).pop(pickedFile);
    }
  }

  double _calculateSharpness(img.Image image) {
    double sum = 0;
    for (int y = 1; y < image.height - 1; y++) {
      for (int x = 1; x < image.width - 1; x++) {
        final gx = _sobelX(image, x, y);
        final gy = _sobelY(image, x, y);
        sum += (gx * gx + gy * gy);
      }
    }
    return sum / (image.width * image.height);
  }

  int _sobelX(img.Image image, int x, int y) {
    return (img.getLuminance(image.getPixel(x + 1, y - 1)) +
            2 * img.getLuminance(image.getPixel(x + 1, y)) +
            img.getLuminance(image.getPixel(x + 1, y + 1)) -
            img.getLuminance(image.getPixel(x - 1, y - 1)) -
            2 * img.getLuminance(image.getPixel(x - 1, y)) -
            img.getLuminance(image.getPixel(x - 1, y + 1)))
        .toInt();
  }

  int _sobelY(img.Image image, int x, int y) {
    return (img.getLuminance(image.getPixel(x - 1, y + 1)) +
            2 * img.getLuminance(image.getPixel(x, y + 1)) +
            img.getLuminance(image.getPixel(x + 1, y + 1)) -
            img.getLuminance(image.getPixel(x - 1, y - 1)) -
            2 * img.getLuminance(image.getPixel(x, y - 1)) -
            img.getLuminance(image.getPixel(x + 1, y - 1)))
        .toInt();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          const CameraOverlay(),
          if (_blurResult != null)
            Positioned(
              bottom: 160,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  _blurResult!,
                  style: TextStyle(
                    color: _blurResult!.contains('mờ') ? Colors.red : Colors.green,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          Positioned(
            top: 32,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(null),
            ),
          ),
          Positioned(
            top: 32,
            right: 16,
            child: IconButton(
              icon: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
              ),
              onPressed: _toggleFlash,
            ),
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _pickFromGallery,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: const Text("Chọn ảnh từ thư viện"),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _isLoading ? null : _takePicture,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, size: 30),
                ),
              ),
            ),
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      ),
    );
  }
}