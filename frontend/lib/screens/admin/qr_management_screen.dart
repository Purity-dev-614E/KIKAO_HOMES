import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:printing/printing.dart';
import '../../utils/qr_code_generator_web.dart';

class QRManagementScreen extends StatefulWidget {
  const QRManagementScreen({super.key});

  @override
  State<QRManagementScreen> createState() => _QRManagementScreenState();
}

class _QRManagementScreenState extends State<QRManagementScreen> {
  bool _isLoading = false;
  Uint8List? _entryQRPdf;
  Uint8List? _exitQRPdf;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _generateQRCodes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Generate QR codes
      final entryQRFiles = await QRCodeGeneratorWeb.generateEntryQR();
      final exitQRFiles = await QRCodeGeneratorWeb.generateExitQR();
      
      setState(() {
        _entryQRPdf = entryQRFiles['pdf'];
        _exitQRPdf = exitQRFiles['pdf'];
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR codes generated successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating QR codes: $e')),
        );
      }
    }
  }

  Future<void> _printPDF(Uint8List pdfBytes) async {
    try {
      await QRCodeGeneratorWeb.printPDF(pdfBytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error printing PDF: $e')),
        );
      }
    }
  }

  Future<void> _sharePDF(Uint8List pdfBytes) async {
    try {
      await QRCodeGeneratorWeb.sharePDF(pdfBytes, 'qr_code.pdf');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Management'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(_errorMessage!),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'QR Code Management',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A6B5D),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Generate QR codes for visitor registration and checkout. These QR codes can be printed and displayed at the gate for visitors to scan.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _generateQRCodes,
                        icon: const Icon(Icons.qr_code),
                        label: const Text('Generate QR Codes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A6B5D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (_entryQRPdf != null && _exitQRPdf != null) ...[
                        const Divider(),
                        const SizedBox(height: 16),
                        const Text(
                          'Generated QR Codes',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A6B5D),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildQRCodeCard(
                          title: 'Visitor Registration QR Code',
                          description: 'Visitors can scan this QR code to register their visit.',
                          pdfBytes: _entryQRPdf!,
                        ),
                        const SizedBox(height: 16),
                        _buildQRCodeCard(
                          title: 'Visitor Checkout QR Code',
                          description: 'Visitors can scan this QR code to check out when leaving.',
                          pdfBytes: _exitQRPdf!,
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildQRCodeCard({
    required String title,
    required String description,
    required Uint8List pdfBytes,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A6B5D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: PdfPreview(
                build: (format) => pdfBytes,
                allowPrinting: false,
                allowSharing: false,
                canChangeOrientation: false,
                canChangePageFormat: false,
                canDebug: false,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _printPDF(pdfBytes),
                  icon: const Icon(Icons.print),
                  label: const Text('Print'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4A6B5D),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _sharePDF(pdfBytes),
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A6B5D),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}