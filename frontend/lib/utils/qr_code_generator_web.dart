import 'package:qr_flutter/qr_flutter.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class QRCodeGeneratorWeb {
  // Generate QR code and return bytes
  static Future<Uint8List> generateQRCode(String data, String fileName) async {
    try {
      final qr = QrPainter(
        data: data,
        version: QrVersions.auto,
        gapless: false,
        color: Colors.black,
        emptyColor: Colors.white,
      );

      final painter = qr;
      final pic = painter.toPicture(200);
      final img = await pic.toImage(200, 200);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      
      return pngBytes;
    } catch (e) {
      print('Error generating QR code: $e');
      rethrow;
    }
  }

  // Generate QR code as PDF
  static Future<Uint8List> generateQRCodePDF(String data, String fileName, String title) async {
    try {
      // First generate the QR code image
      final qrImage = await generateQRCode(data, fileName);
      
      // Create a PDF document
      final pdf = pw.Document();
      
      // Add a page with the QR code
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    title,
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Image(
                    pw.MemoryImage(qrImage),
                    width: 200,
                    height: 200,
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Scan this QR code',
                    style: pw.TextStyle(fontSize: 16),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    data,
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          },
        ),
      );
      
      // Save the PDF
      final pdfBytes = await pdf.save();
      return pdfBytes;
    } catch (e) {
      print('Error generating PDF: $e');
      rethrow;
    }
  }

  // Generate Entry QR code (for visitor registration)
  static Future<Map<String, Uint8List>> generateEntryQR() async {
    final pngBytes = await generateQRCode(
      'https://kikaohomes.vercel.app/#/visitors/registration',
      'entry_qr',
    );
    
    final pdfBytes = await generateQRCodePDF(
      'https://kikaohomes.vercel.app/#/visitors/registration',
      'entry_qr',
      'Visitor Registration QR Code',
    );
    
    return {
      'png': pngBytes,
      'pdf': pdfBytes,
    };
  }

  // Generate Exit QR code (for visitor checkout)
  static Future<Map<String, Uint8List>> generateExitQR() async {
    final pngBytes = await generateQRCode(
      'https://kikaohomes.vercel.app/#/visitors/checkout',
      'exit_qr',
    );
    
    final pdfBytes = await generateQRCodePDF(
      'https://kikaohomes.vercel.app/#/visitors/checkout',
      'exit_qr',
      'Visitor Checkout QR Code',
    );
    
    return {
      'png': pngBytes,
      'pdf': pdfBytes,
    };
  }
  
  // Print PDF bytes
  static Future<void> printPDF(Uint8List pdfBytes) async {
    await Printing.layoutPdf(
      onLayout: (_) async => pdfBytes,
    );
  }
  
  // Share PDF bytes
  static Future<void> sharePDF(Uint8List pdfBytes, String filename) async {
    await Printing.sharePdf(bytes: pdfBytes, filename: filename);
  }
}