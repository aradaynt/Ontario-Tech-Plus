import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ontario_tech_plus/QRcodes/qr_cipher.dart'; // Adjust this import if your path is different
import 'package:screenshot/screenshot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';


class GenerateQRPage extends StatefulWidget {
  const GenerateQRPage({super.key});

  @override
  State<GenerateQRPage> createState() => _GenerateQRPageState();
}

class _GenerateQRPageState extends State<GenerateQRPage> {
  final TextEditingController _controller = TextEditingController();
  final ScreenshotController _screenshotController = ScreenshotController();
  String _qrData = '';
  bool _isSaving = false;

  void _generateSecureQR() {
    if (_controller.text.isNotEmpty) {
      // Hide the keyboard when generating
      FocusScope.of(context).unfocus(); 
      setState(() {
        _qrData = QRCipher.encryptData(_controller.text);
      });
    }
  }

  Future<void> _saveQRToGallery() async {
    setState(() => _isSaving = true);

    try {
      // 1. Request Storage/Photos Permission
      // On older Android this uses Storage, on newer it uses Photos/Images
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        // Fallback for Android 13+
        status = await Permission.photos.request(); 
      }

      // 2. Capture the QR code if permission is granted
      if (status.isGranted) {
        final Uint8List? imageBytes = await _screenshotController.capture();
        
        if (imageBytes != null) {
          // 3. Save to the Android Gallery
          final result = await ImageGallerySaverPlus.saveImage(
            imageBytes,
            quality: 100,
            name: "OntarioTechPlus_QR_${DateTime.now().millisecondsSinceEpoch}",
          );

          if (result['isSuccess'] && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('QR Code successfully saved to Gallery!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission denied. Cannot save to gallery.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving image: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Generate Secure QR")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter data to share securely',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generateSecureQR,
              child: const Text('Generate QR Code'),
            ),
            const SizedBox(height: 32),
            
            // Only show this block if the QR Code has been generated
            if (_qrData.isNotEmpty) ...[
              const Text("Scan this with the Ontario Tech Plus App:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              // Wrap the QR Code in a Screenshot widget
              Screenshot(
                controller: _screenshotController,
                child: Container(
                  color: Colors.white, // Ensure the saved image has a white background
                  padding: const EdgeInsets.all(16.0),
                  child: QrImageView(
                    data: _qrData,
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Save Button
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveQRToGallery,
                icon: _isSaving 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : const Icon(Icons.save_alt),
                label: const Text('Save to Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}