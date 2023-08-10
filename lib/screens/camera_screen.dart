import 'package:camera/camera.dart'; // 导入camera包
import 'package:flutter/material.dart'; // 导入Flutter核心包
import '../main.dart'; // 导入主应用程序入口
import 'dart:io'; // 导入File类使用
import 'package:path_provider/path_provider.dart'; // 导入获取应用程序文档目录方法的包

// 相机界面部分，StatefulWidget
class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

// 相机界面状态类，使用WidgetsBindingObserver以观察应用程序生命周期
class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? controller; // 相机控制器
  bool _isCameraInitialized = false; // 标记相机是否初始化完成

  final resolutionPresets = ResolutionPreset.values; // 支持的分辨率选项
  ResolutionPreset currentResolutionPreset = ResolutionPreset.high; // 当前选中的分辨率选项

  double _minAvailableZoom = 1.0; // 最小可用缩放级别
  double _maxAvailableZoom = 1.0; // 最大可用缩放级别
  double _currentZoomLevel = 1.0; // 当前缩放级别

  double _minAvailableExposureOffset = 0.0; // 最小可用曝光偏移量
  double _maxAvailableExposureOffset = 0.0; // 最大可用曝光偏移量
  double _currentExposureOffset = 0.0; // 当前曝光偏移量

  FlashMode? _currentFlashMode; // 当前闪光灯模式

  bool _isRearCameraSelected = true; // 是否选择后置摄像头
  File? _imageFile; // 图像文件，初始化为null
  List<File> allFileList = []; // 用于存储已捕获的所有文件列表

  // 刷新已捕获的图像列表
  refreshAlreadyCapturedImages() async {
    final directory = await getApplicationDocumentsDirectory(); // 获取应用程序文档目录
    List<FileSystemEntity> fileList = await directory.list().toList();
    allFileList.clear();
    List<Map<int, dynamic>> fileNames = [];

    // 寻找所有图像文件，并存储它们
    fileList.forEach((file) {
      if (file.path.contains('.jpg')) {
        allFileList.add(File(file.path));
        String name = file.path.split('/').last.split('.').first;
        fileNames.add({0: int.parse(name), 1: file.path.split('/').last});
      }
    });

    // 获取最近的文件
    if (fileNames.isNotEmpty) {
      final recentFile =
      fileNames.reduce((curr, next) => curr[0] > next[0] ? curr : next);
      String recentFileName = recentFile[1];

      _imageFile = File('${directory.path}/$recentFileName');
      setState(() {});
    }
  }

  // 选择新的相机设备
  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;
    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      currentResolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    // Dispose the previous controller
    await previousCameraController?.dispose();
    // Replace with the new controller
    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }
    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });
    // Initialize controller
    try {
      await cameraController.initialize();

      _currentFlashMode = controller!.value.flashMode;

      cameraController
          .getMaxZoomLevel()
          .then((value) => _maxAvailableZoom = value);
      cameraController
          .getMinZoomLevel()
          .then((value) => _minAvailableZoom = value);

      cameraController
          .getMinExposureOffset()
          .then((value) => _minAvailableExposureOffset = value);
      cameraController
          .getMaxExposureOffset()
          .then((value) => _maxAvailableExposureOffset = value);

    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }
    // Update the boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  // 监听应用程序生命周期状态的变化
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // 当相机不处于活跃状态时释放内存
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // 当应用程序恢复活动状态时重新初始化相机
      onNewCameraSelected(cameraController.description);
    }
  }

  // 拍照
  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController!.value.isTakingPicture) {
      // 正在拍照中，不做任何操作
      return null;
    }
    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      print('Error occured while taking picture: $e');
      return null;
    }
  }

  @override
  void initState() {
    // 初始化相机界面
    // 仅在 _imageFile 为空时初始化相机界面
    onNewCameraSelected(cameras[0]);
    if (_imageFile == null) {
      // 如果 _imageFile 为空，则设置为最近的图像文件
      refreshAlreadyCapturedImages();
    }
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // _isCameraInitialized
          //     ? AspectRatio(
          //   aspectRatio: 1 / controller!.value.aspectRatio,
          //   child: controller!.buildPreview(),
          // )
          //     : Container(),

          // 呈现相机预览
          _isCameraInitialized
              ? LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                double screenWidth = constraints.maxWidth;
                double screenHeight = constraints.maxHeight;
                double screenAspectRatio = screenWidth / screenHeight;

                return AspectRatio(
                  aspectRatio: screenAspectRatio,
                  child: controller!.buildPreview(),
                );
              }
          )
              : Container(),

          // 展示分辨率选项
          Positioned(
            top: 20, // Adjust the value to position the DropdownButton
            right: 20, // Adjust the value to position the DropdownButton
            child: DropdownButton<ResolutionPreset>(
              dropdownColor: Colors.black87,
              underline: Container(),
              value: currentResolutionPreset,
              items: [
                for (ResolutionPreset preset in resolutionPresets)
                  DropdownMenuItem(
                    child: Text(
                      preset.toString().split('.')[1].toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                    value: preset,
                  )
              ],
              onChanged: (value) {
                setState(() {
                  currentResolutionPreset = value!;
                  _isCameraInitialized = false;
                });
                onNewCameraSelected(controller!.description);
              },
              hint: Text("Select item"),
            ),
          ),

          // 显示缩放条
          Positioned(
            bottom: 100, // Adjust the value to position the Slider
            left: 20, // Adjust the value to position the Slider
            right: 20, // Adjust the value to position the Slider
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _currentZoomLevel,
                    min: _minAvailableZoom,
                    max: _maxAvailableZoom,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white30,
                    onChanged: (value) async {
                      setState(() {
                        _currentZoomLevel = value;
                      });
                      await controller!.setZoomLevel(value);
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _currentZoomLevel.toStringAsFixed(1) + 'x',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 显示曝光偏移量
          Positioned(
            bottom: 250, // Adjust the value to position the ExposureOffset Slider
            left: 20, // Adjust the value to position the ExposureOffset Slider
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _currentExposureOffset.toStringAsFixed(1) + 'x',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                RotatedBox(
                  quarterTurns: 3,
                  child: Container(
                    height: 30,
                    child: Slider(
                      value: _currentExposureOffset,
                      min: _minAvailableExposureOffset,
                      max: _maxAvailableExposureOffset,
                      activeColor: Colors.white,
                      inactiveColor: Colors.white30,
                      onChanged: (value) async {
                        setState(() {
                          _currentExposureOffset = value;
                        });
                        await controller!.setExposureOffset(value);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 显示闪光灯模式
          Positioned(
            top: 80, // Adjust the value to position the Flash Mode icons
            left: 20, // Adjust the value to position the Flash Mode icons
            right: 20, // Adjust the value to position the Flash Mode icons
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Flash Off
                InkWell(
                  onTap: () async {
                    setState(() {
                      _currentFlashMode = FlashMode.off;
                    });
                    await controller!.setFlashMode(FlashMode.off);
                  },
                  child: Icon(
                    Icons.flash_off,
                    color: _currentFlashMode == FlashMode.off
                        ? Colors.amber
                        : Colors.white,
                  ),
                ),
                // Flash Auto
                InkWell(
                  onTap: () async {
                    setState(() {
                      _currentFlashMode = FlashMode.auto;
                    });
                    await controller!.setFlashMode(FlashMode.auto);
                  },
                  child: Icon(
                    Icons.flash_auto,
                    color: _currentFlashMode == FlashMode.auto
                        ? Colors.amber
                        : Colors.white,
                  ),
                ),
                // Toggle Rear/Front Camera
                InkWell(
                  onTap: () async {
                    setState(() {
                      _currentFlashMode = FlashMode.always;
                    });
                    await controller!.setFlashMode(FlashMode.always);
                  },
                  child: Icon(
                    Icons.flash_on,
                    color: _currentFlashMode == FlashMode.always
                        ? Colors.amber
                        : Colors.white,
                  ),
                ),
                // Torch Mode
                InkWell(
                  onTap: () async {
                    setState(() {
                      _currentFlashMode = FlashMode.torch;
                    });
                    await controller!.setFlashMode(FlashMode.torch);
                  },
                  child: Icon(
                    Icons.highlight,
                    color: _currentFlashMode == FlashMode.torch
                        ? Colors.amber
                        : Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // 切换摄像头按钮
          Positioned(
            top: 20, // Adjust the value to position the Camera Switch button
            left: 20, // Adjust the value to position the Camera Switch button
            child: InkWell(
              onTap: () {
                setState(() {
                  _isCameraInitialized = false;
                });
                onNewCameraSelected(cameras[_isRearCameraSelected ? 0 : 1]);
                setState(() {
                  _isRearCameraSelected = !_isRearCameraSelected;
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.circle,
                    color: Colors.black38,
                    size: 60,
                  ),
                  Icon(
                    _isRearCameraSelected
                        ? Icons.camera_front
                        : Icons.camera_rear,
                    color: Colors.white,
                    size: 30,
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 20, // Adjust the value to position the Capture button
            left: 0,
            right: 0,
            child: Center(
              child: InkWell(
                onTap: () async {
                  XFile? rawImage = await takePicture();
                  File imageFile = File(rawImage!.path);
                  int currentUnix = DateTime.now().millisecondsSinceEpoch;
                  final directory = await getApplicationDocumentsDirectory();
                  String fileFormat = imageFile.path.split('.').last;
                  _imageFile = await imageFile.copy(
                    '${directory.path}/$currentUnix.$fileFormat',
                  );
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.circle, color: Colors.white38, size: 80),
                    Icon(Icons.circle, color: Colors.white, size: 65),
                  ],
                ),
              ),
            ),
          ),

          // 显示已捕获的图像
          Positioned(
            bottom: 30, // 调整值以定位 Capture 按钮
            right: 20, // 调整值以定位 Capture 按钮
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.white, width: 2),
                image: _imageFile != null
                    ? DecorationImage(
                  image: FileImage(_imageFile!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: Container(), // 已移除视频处理相关部分
            ),
          ),
        ],
      ),
    );
  }
}