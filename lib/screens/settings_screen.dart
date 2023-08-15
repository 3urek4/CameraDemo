import 'package:flutter/material.dart';
import 'dart:io';
import '../globals.dart' as globals;
import 'package:path_provider/path_provider.dart';

// 定义一个异步函数，用于将密码写入文件
Future<void> writePwdToFile(String password) async {
  globals.password = password; // 更新全局变量中的密码
  final directory = await getApplicationDocumentsDirectory(); // 获取应用程序的文档目录
  File file = File('${directory.path}/usr_pwd.txt'); // 在文档目录中创建一个文件
  await file.writeAsString(globals.password); // 将密码写入文件
}

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    // 构建设置页面的UI
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'), // 设置标题栏的标题为Settings
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person), // 在列表项前面添加一个人物图标
            title: Text('Profile'), // 列表项的标题为Profile
            onTap: () {
              // 当列表项被点击时执行的操作
              // Todo
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications), // 在列表项前面添加一个通知图标
            title: Text('Notifications'), // 列表项的标题为Notifications
            onTap: () {
              // 当列表项被点击时执行的操作
              // Todo
            },
          ),
          ListTile(
            leading: Icon(Icons.security), // 在列表项前面添加一个安全图标
            title: Text('Privacy'), // 列表项的标题为Privacy
            onTap: () {
              showDialog(
                // 弹出对话框
                context: context,
                builder: (BuildContext context) {
                  if (globals.password == "") {
                    // 如果全局变量中的密码为空
                    String password = ""; // 定义一个空的密码字符串变量
                    return AlertDialog(
                      // 弹出一个对话框
                      title: Text('Set your password'), // 对话框的标题为Set your password
                      content: Container(
                        height: 60,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 60,
                              child: TextField(
                                onChanged: (value) {
                                  password = value;
                                  // 当输入框中的值发生变化时，更新密码变量的值
                                },
                                obscureText: true, // 输入的文本内容显示为密文形式
                                decoration: InputDecoration(
                                  hintText: 'Please enter your password',
                                  // 输入框的提示文本为Please enter your password
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cancel'), // 取消按钮的文本为Cancel
                          onPressed: () {
                            Navigator.pop(context);
                            // 点击取消按钮时关闭对话框
                          },
                        ),
                        TextButton(
                          child: Text('Confirm'), // 确认按钮的文本为Confirm
                          onPressed: () async {
                            globals.password = password;
                            // 更新全局变量中的密码
                            await writePwdToFile(password);
                            // 将密码写入文件
                            Navigator.pop(context);
                            // 关闭对话框
                          },
                        ),
                      ],
                    );
                  } else {
                    String password = ""; // 定义一个空的密码字符串变量
                    String new_pwd = ""; // 定义一个空的新密码字符串变量
                    print(globals.password);
                    return AlertDialog(
                      title: Text('Change Password'), // 对话框的标题为Change Password
                      content: Container(
                        height: 140,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 60,
                              child: TextField(
                                onChanged: (value) {
                                  password = value;
                                  // 当输入框中的值发生变化时，更新密码变量的值
                                },
                                obscureText: true, // 输入的文本内容显示为密文形式
                                decoration: InputDecoration(
                                  hintText: 'Please enter the original password',
                                  // 输入框的提示文本为Please enter the original password
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              height: 60,
                              child: TextField(
                                onChanged: (value) {
                                  new_pwd = value;
                                  // 当输入框中的值发生变化时，更新新密码变量的值
                                },
                                obscureText: true, // 输入的文本内容显示为密文形式
                                decoration: InputDecoration(
                                  hintText: 'Please enter the new password',
                                  // 输入框的提示文本为Please enter the new password
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cancel'), // 取消按钮的文本为Cancel
                          onPressed: () {
                            Navigator.pop(context);
                            // 点击取消按钮时关闭对话框
                          },
                        ),
                        TextButton(
                          child: Text('Confirm'), // 确认按钮的文本为Confirm
                          onPressed: () async {
                            if (password == globals.password) {
                              // 如果输入的原密码与全局变量中的密码一致
                              if (new_pwd != "") {
                                // 如果新密码不为空
                                globals.password = new_pwd;
                                // 更新全局变量中的密码
                                await writePwdToFile(new_pwd);
                                // 将新密码写入文件
                              }
                              Navigator.pop(context);
                              // 关闭对话框
                            } else {
                              showDialog(
                                // 弹出对话框
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Origin password is wrong!'),
                                    // 对话框的标题为Origin password is wrong!
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ],
                    );
                  }
                },
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.menu_book), // 在列表项前面添加一个菜单书图标
            title: Text('Readme'), // 列表项的标题为Readme
            onTap: () {
              // 当列表项被点击时执行的操作
              // Todo
            },
          ),
          ListTile(
            leading: Icon(Icons.login), // 在列表项前面添加一个登录图标
            title: Text('Login'), // 列表项的标题为Login
            onTap: () {
              // 当列表项被点击时执行的操作
              // Todo
            },
          ),
          ListTile(
            leading: Icon(Icons.logout), // 在列表项前面添加一个登出图标
            title: Text('Logout'), // 列表项的标题为Logout
            onTap: () {
              // 当列表项被点击时执行的操作
              // Todo
            },
          ),
        ],
      ),
    );
  }
}
