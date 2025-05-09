import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// Class to represent a file in web environment
class WebFile {
  final Uint8List bytes;
  final String name;
  
  WebFile(this.bytes, this.name);
  
  // Methods to mimic File class behavior
  Future<Uint8List> readAsBytes() async {
    return bytes;
  }
}

class QRCodeGenerator {
  
  // Generate QR code and return either a File (mobile) or WebFile (web)
  static Future<dynamic> generateQRCode(String data, String fileName) async {
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

      if (kIsWeb) {
        // For web, return a WebFile object
        return WebFile(pngBytes, '$fileName.png');
      } else {
        // For mobile, use File system
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName.png');
        await file.writeAsBytes(pngBytes);
        return file;
      }
    } catch (e) {
      print('Error generating QR code: $e');
      rethrow;
    }
  }

  // Generate QR code as PDF
  static Future<dynamic> generateQRCodePDF(String data, String fileName, String title) async {
    try {
      // First generate the QR code image
      final qrFile = await generateQRCode(data, fileName);
      final Uint8List qrImage = await qrFile.readAsBytes();
      
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
      
      if (kIsWeb) {
        // For web, return a WebFile object
        return WebFile(pdfBytes, '$fileName.pdf');
      } else {
        // For mobile, use File system
        final directory = await getApplicationDocumentsDirectory();
        final pdfFile = File('${directory.path}/$fileName.pdf');
        await pdfFile.writeAsBytes(pdfBytes);
        return pdfFile;
      }
    } catch (e) {
      print('Error generating PDF: $e');
      rethrow;
    }
  }

  // Generate Entry QR code (for visitor registration)
  static Future<Map<String, dynamic>> generateEntryQR() async {
    final pngFile = await generateQRCode(
      'https://kikaohomes.vercel.app/visitors/registration',
      'entry_qr',
    );
    
    final pdfFile = await generateQRCodePDF(
      'https://kikaohomes.vercel.app/visitors/registration',
      'entry_qr',
      'Visitor Registration QR Code',
    );
    
    return {
      'png': pngFile,
      'pdf': pdfFile,
    };
  }

  // Generate Exit QR code (for visitor checkout)
  static Future<Map<String, dynamic>> generateExitQR() async {
    final pngFile = await generateQRCode(
      'https://kikaohomes.vercel.app/visitors/checkout',
      'exit_qr',
    );
    
    final pdfFile = await generateQRCodePDF(
      'https://kikaohomes.vercel.app/visitors/checkout',
      'exit_qr',
      'Visitor Checkout QR Code',
    );
    
    return {
      'png': pngFile,
      'pdf': pdfFile,
    };
  }
  
  // Print PDF file
  static Future<void> printPDF(dynamic pdfFile) async {
    await Printing.layoutPdf(
      onLayout: (_) async => await pdfFile.readAsBytes(),
    );
  }
  
  // Share PDF file
  static Future<void> sharePDF(dynamic pdfFile) async {
    final bytes = await pdfFile.readAsBytes();
    String filename;
    
    if (kIsWeb) {
      if (pdfFile is WebFile) {
        filename = pdfFile.name;
      } else {
        filename = 'document.pdf';
      }
    } else {
      if (pdfFile is File) {
        filename = pdfFile.path.split('/').last;
      } else {
        filename = 'document.pdf';
      }
    }
    
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }
}
