import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:printing/printing.dart';
import '../../utils/qr_code_generator_web.dart';
import 'admin_theme.dart';

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
      body: SafeArea(
        child: Column(
          children: [
            AdminTheme.header(
              context: context,
              title: 'QR Code Management',
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              _errorMessage!,
                              style: AdminTheme.subtitleTextStyle,
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'QR Code Management',
                                style: AdminTheme.titleTextStyle.copyWith(fontSize: 24),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Generate QR codes for visitor registration and checkout. These QR codes can be printed and displayed at the gate for visitors to scan.',
                                style: AdminTheme.subtitleTextStyle.copyWith(fontSize: 16),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _generateQRCodes,
                                icon: const Icon(Icons.qr_code),
                                label: const Text('Generate QR Codes'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AdminTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              if (_entryQRPdf != null && _exitQRPdf != null) 
                                Column(
                                  children: [
                                    const Divider(),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Generated QR Codes',
                                      style: AdminTheme.titleTextStyle.copyWith(fontSize: 20),
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
                                ),
                            ],
                          ),
                        ),
            ),
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
    return AdminTheme.card(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AdminTheme.titleTextStyle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AdminTheme.subtitleTextStyle,
          ),
          const SizedBox(height: 16),
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: PdfPreview(
              build: (format) => pdfBytes,
              allowPrinting: false,
              allowSharing: false,
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              pdfFileName: 'qr_code.pdf',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _printPDF(pdfBytes),
                icon: const Icon(Icons.print, size: 20),
                label: const Text('Print'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => _sharePDF(pdfBytes),
                icon: const Icon(Icons.share, size: 20),
                label: const Text('Share'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AdminTheme.primaryColor,
                  side: BorderSide(color: AdminTheme.primaryColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}