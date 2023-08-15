import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'edit_screen.dart';

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<File> galleryImages = []; // 存储图库中的图片文件列表
  Set<File> selectedImages = Set<File>(); // 添加一个Set来跟踪选中的图片
  bool isSelectionMode = false; // 新变量用于跟踪选择模式
  bool isAllImagesSelected = false; // 添加全选状态变量

  @override
  void initState() {
    super.initState();
    _refreshGalleryImages(); // 初始化时刷新图库中的图片
  }

  Future<void> _refreshGalleryImages() async {
    List<File> images = await _getGalleryImages(); // 获取图库中的图片列表
    setState(() {
      galleryImages = images; // 更新图库图片列表
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery'),
        actions: <Widget>[
          if (isSelectionMode)
            IconButton(
              icon: Icon(Icons.select_all),
              onPressed: () {
                setState(() {
                  if (isAllImagesSelected) {
                    selectedImages.clear(); // 取消选中所有图片
                  } else {
                    selectedImages = Set.from(galleryImages); // 全选所有图片
                  }
                  isAllImagesSelected = !isAllImagesSelected; // 切换全选状态
                });
              },
            ),
          if (isSelectionMode && selectedImages.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                bool confirmDelete = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Delete Images'),
                      content: Text('Are you sure you want to delete the selected images?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false); // 不删除
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true); // 删除
                          },
                          child: Text('Delete'),
                        ),
                      ],
                    );
                  },
                );

                if (confirmDelete == true) {
                  for (var file in selectedImages) {
                    try {
                      await file.delete(); // 删除选中的图片文件
                      print('Deleted file: $file');
                    } catch (e) {
                      print('Failed to delete file: $file, Error: $e');
                    }
                  }
                  await _refreshGalleryImages(); // 删除后刷新图库中的图片
                  setState(() {
                    isSelectionMode = false; // 删除后退出选择模式
                  });
                }
              },
            ),
          IconButton(
            icon: Icon(isSelectionMode ? Icons.cancel : Icons.check),
            onPressed: () {
              setState(() {
                if (isSelectionMode) {
                  selectedImages.clear(); // 清除选中的图片
                }
                isSelectionMode = !isSelectionMode; // 切换选择模式
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<File>>(
        future: _getGalleryImages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // 显示加载指示器
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}'); // 显示错误信息
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text('No images found in the gallery.'); // 显示图库中没有图片的消息
          } else {
            List<File> galleryImages = snapshot.data!; // 获取图库中的图片列表
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 每行显示3张图片
              ),
              itemCount: galleryImages.length,
              itemBuilder: (context, index) {
                File imageFile = galleryImages[index]; // 当前索引处的图片文件
                return GestureDetector(
                  onTap: () {
                    if (isSelectionMode) {
                      setState(() {
                        if (selectedImages.any((file) => file.path == imageFile.path)) {
                          selectedImages.removeWhere((file) => file.path == imageFile.path); // 取消选中
                        } else {
                          selectedImages.add(imageFile); // 选中图片
                        }
                      });
                    } else {
                      // 在这里处理正常的点击行为，比如进入编辑模式
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditScreen(imageFile: imageFile, refreshGallery: _refreshGalleryImages),
                        ),
                      );
                    }
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        imageFile,
                        fit: BoxFit.cover,
                      ),
                      if (isSelectionMode && selectedImages.any((file) => file.path == imageFile.path))
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: () {
                              return Icon(Icons.check_circle, color: Colors.green, size: 20); // 显示选中图标
                            }(),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<File>> _getGalleryImages() async {
    final directory = await getApplicationDocumentsDirectory(); // 获取应用文档目录
    List<FileSystemEntity> fileList = await directory.list().toList(); // 获取目录中的文件列表
    List<File> imageFiles = [];

    fileList.forEach((file) {
      if (file.path.contains('.jpg')) {
        imageFiles.add(File(file.path)); // 将以.jpg为后缀的文件添加到图片文件列表中
      }
    });

    imageFiles.sort((a, b) {
      return b.lastModifiedSync().compareTo(a.lastModifiedSync()); // 根据最后修改时间排序图片文件列表
    });
    return imageFiles; // 返回图片文件列表
  }
}
