import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ontario_tech_plus/QRcodes/qr_cipher.dart';

class GenerateQRPage extends StatefulWidget {
  const GenerateQRPage({super.key});

  @override
  State<GenerateQRPage> createState() => _GenerateQRPageState();
}

class _GenerateQRPageState extends State<GenerateQRPage> {
  final TextEditingController _controller = TextEditingController();
  String _qrData = '';

  void _generateSecureQR() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _qrData = QRCipher.encryptData(_controller.text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Generate Secure QR")),
      body: Padding(
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
            if (_qrData.isNotEmpty) ...[
              const Text("Scan this with the Ontario Tech Plus App:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              QrImageView(
                data: _qrData,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
            ]
          ],
        ),
      ),
    );
  }
}