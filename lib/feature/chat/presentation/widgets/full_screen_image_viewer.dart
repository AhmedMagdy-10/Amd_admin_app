import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:typed_data';

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageViewer({super.key, required this.imageUrl});

  Future<void> _downloadImage(BuildContext context) async {
    try {
      if (context.mounted) {
        Fluttertoast.showToast(msg: "جاري تحميل الصورة...");
      }
      var response = await http.get(Uri.parse(imageUrl));
      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.bodyBytes),
        quality: 100,
        name: "chat_image_${DateTime.now().millisecondsSinceEpoch}"
      );
      if (result['isSuccess'] == true) {
        Fluttertoast.showToast(msg: "تم حفظ الصورة في المعرض");
      } else {
        Fluttertoast.showToast(msg: "فشل حفظ الصورة");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "حدث خطأ أثناء تحميل الصورة");
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
