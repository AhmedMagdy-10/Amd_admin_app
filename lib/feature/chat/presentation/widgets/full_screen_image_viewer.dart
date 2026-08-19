import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:typed_data';
import 'dart:io';

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageViewer({super.key, required this.imageUrl});

  Future<void> _downloadImage(BuildContext context) async {
    try {
      if (context.mounted) {
        Fluttertoast.showToast(msg: "جاري تحميل الصورة...");
      }
      var response = await http.get(Uri.parse(imageUrl));
      
      // Request permission using gal
      if (!await Gal.hasAccess()) {
        await Gal.requestAccess();
      }

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/chat_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(response.bodyBytes);

      // Save to gallery
      await Gal.putImage(tempFile.path);
      
      Fluttertoast.showToast(msg: "تم حفظ الصورة في المعرض بنجاح");
    } catch (e) {
      Fluttertoast.showToast(msg: "حدث خطأ: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadImage(context),
            tooltip: 'تحميل الصورة',
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            },
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.broken_image, color: Colors.white, size: 50),
            ),
          ),
        ),
      ),
    );
  }
}
