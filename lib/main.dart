import 'package:flutter/material.dart';
import 'screens/camera_screen.dart'; // 导入相机界面
import 'screens/gallery_screen.dart'; // 导入相册界面
import 'screens/settings_screen.dart'; // 导入设置界面
import 'package:camera/camera.dart'; // 导入camera包

List<CameraDescription> cameras = []; // 用于存储相机设备的列表

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras(); // 获取可用的相机设备列表
  } on CameraException catch (e) {
    print('获取相机设备时出错：$e');
  }
  runApp(MyApp()); // 启动应用程序
}

// 自定义的应用程序类
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // 构建应用程序界面
//     return MaterialApp(
//       title: 'Camera Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue, // 设置主题颜色为蓝色
//       ),
//       debugShowCheckedModeBanner: false, // 隐藏调试模式横幅
//       home: CameraScreen(), // 设置应用程序的初始页面为相机屏幕
//     );
//   }
// }

// 自定义的应用程序类
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Demo', // 应用程序标题
      theme: ThemeData(
        primarySwatch: Colors.blue, // 设置主题颜色为蓝色
      ),
      debugShowCheckedModeBanner: false, // 隐藏调试模式横幅
      home: MyCameraApp(), // 设置应用程序的初始页面为自定义相机应用类
    );
  }
}

// 自定义相机应用类
class MyCameraApp extends StatefulWidget {
  @override
  _MyCameraAppState createState() => _MyCameraAppState();
}

class _MyCameraAppState extends State<MyCameraApp> {
  int _currentIndex = 0; // 当前选中的页面索引

  final List<Widget> _pages = [
    CameraScreen(), // 相机界面部分
    GalleryScreen(), // 相册界面部分
    //SettingsScreen(), // 设置界面部分
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // 根据索引显示对应页面的内容
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // 切换选中的页面
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'gallery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'settings',
          ),
        ],
      ),
    );
  }
}