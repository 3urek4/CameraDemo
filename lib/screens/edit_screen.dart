import 'package:flutter/material.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'dart:typed_data';
import 'dart:io';

class EditScreen extends StatelessWidget {
  final File imageFile;
  final VoidCallback refreshGallery;

  EditScreen({required this.imageFile, required this.refreshGallery});

  Future<File> saveEditedImageToLocal(Uint8List editedImageData, String originalImagePath) async {
    // 获取当前的时间戳（毫秒级）
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    // 生成新的文件名，使用时间戳确保唯一性
    String editedImagePath = originalImagePath.replaceFirst('.jpg', '_edited_$timestamp.jpg');
    //String editedImagePath = originalImagePath.replaceFirst('.jpg', '_edited.jpg');

    // 保存编辑后的图片到新的文件路径
    File editedImageFile = File(editedImagePath);
    await editedImageFile.writeAsBytes(editedImageData);
    return editedImageFile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Image'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.file(
              imageFile,
              width: 300,
              height: 300,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                Uint8List? editedImage = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageEditor(
                      image: File(imageFile.path).readAsBytesSync(),
                    ),
                  ),
                );

                if (editedImage != null) {
                  // 在这里处理编辑后的图片数据
                  // 保存编辑后的图片到本地
                  File editedImageFile = await saveEditedImageToLocal(editedImage, imageFile.path);
                  // 调用回调函数以刷新相册
                  refreshGallery();
                  //print("666666666666");
                }
              },
              child: Text('Edit Image'),
            ),
          ],
        ),
      ),
    );
  }
}