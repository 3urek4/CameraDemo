import 'package:flutter/material.dart'; // Flutter的UI库
import 'package:path_provider/path_provider.dart'; // 文件路径提供库
import 'screens/camera_screen.dart'; // 相机界面
import 'screens/gallery_screen.dart'; // 相册界面
import 'screens/settings_screen.dart'; // 设置界面
import 'package:camera/camera.dart'; // 相机库
import 'dart:io'; // 输入输出库
import 'globals.dart' as globals; // 全局变量库

List<CameraDescription> cameras = []; // 存储相机设备的列表

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized(); // 初始化Flutter绑定
    cameras = await availableCameras(); // 获取可用相机设备
  } on CameraException catch (e) {
    print('获取相机设备时出错：$e');
  }
  await loadUsrPwd(); // 加载用户密码
  runApp(MyApp()); // 运行Flutter应用
}

// 异步函数，用于加载用户密码
Future<void> loadUsrPwd() async{
  try{
    final directory = await getApplicationDocumentsDirectory(); // 获取应用文档目录
    File file = File('${directory.path}/usr_pwd.txt'); // 创建文件对象
    if(await file.exists()){
      print('File exists');
    }
    else{
      print('File does not exist. Creating file...');
      await file.create();
      print('File created');
    }
    globals.password = await file.readAsString(); // 读取文件中的密码并存储到全局变量中
    print(globals.password);
  }catch(e){
    print('读取文件时出现错误：$e');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Demo', // 应用标题
      theme: ThemeData(
        primarySwatch: Colors.blue, // 主题颜色
      ),
      debugShowCheckedModeBanner: false, // 不显示调试模式横幅
      home: MyCameraApp(), // 应用的主界面
    );
  }
}

class MyCameraApp extends StatefulWidget {
  @override
  _MyCameraAppState createState() => _MyCameraAppState();
}

class _MyCameraAppState extends State<MyCameraApp> {
  int _currentIndex = 0; // 当前显示页面的索引

  final List<Widget> _pages = [
    CameraScreen(), // 相机界面部分
    GalleryScreen(), // 相册界面部分
    SettingsScreen(), // 设置界面部分
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // 根据索引显示对应的页面
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // 当前选中的底部导航栏项的索引
        onTap: (index) {
          setState(() {
            _currentIndex = index; // 更新索引，切换页面
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
