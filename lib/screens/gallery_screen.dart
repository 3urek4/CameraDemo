import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'camera_screen.dart'; // 导入相机界面

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery'),
      ),
      body: FutureBuilder<List<File>>(
        future: _getGalleryImages(), // 创建一个异步函数以获取画廊图像列表
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text('No images found in the gallery.');
          } else {
            List<File> galleryImages = snapshot.data!;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 调整列数
              ),
              itemCount: galleryImages.length,
              itemBuilder: (context, index) {
                File imageFile = galleryImages[index];
                return Image.file(imageFile, fit: BoxFit.cover);
              },
            );
          }
        },
      ),
    );
  }

  // 异步函数以获取应用程序文档目录中的所有图像文件
  Future<List<File>> _getGalleryImages() async {
    final directory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> fileList = await directory.list().toList();
    List<File> imageFiles = [];

    // 寻找所有图像文件，并存储它们
    fileList.forEach((file) {
      if (file.path.contains('.jpg')) {
        imageFiles.add(File(file.path));
      }
    });
    return imageFiles;
  }
}