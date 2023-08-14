import 'package:flutter/material.dart';
import 'dart:io'; // 导入File类使用
import 'globals.dart' as globals; // 导入全局变量
import 'package:path_provider/path_provider.dart'; // 提供一种平台无关的方式以一致的方式访问设备的文件位置系统

Future<void> writePwdToFile(String password) async {
  globals.password = password;
  final directory = await getApplicationDocumentsDirectory();
  File file = File('${directory.path}/usr_pwd.txt');

  await file.writeAsString(globals.password);
}

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            onTap: () {
            },
          ),
          ListTile(
            leading: Icon(Icons.security),
            title: Text('Privacy'),
            onTap: () { // 用于修改密码
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  if(globals.password == ""){
                    String password = "";
                    return AlertDialog(
                      title: Text('Set your password'),
                      content: Container(
                        height: 60, // 调整对话框内容的高度
                        child: Column(
                          children: [
                            SizedBox(
                              height: 60, // 调整每个文本框的高度
                              child: TextField(
                                onChanged: (value) {
                                  password = value;
                                },
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Please enter your password',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.pop(context); // 关闭对话框
                          },
                        ),
                        TextButton(
                          child: Text('Confirm'),
                          onPressed: () async{
                            globals.password = password;
                            await writePwdToFile(password);
                            Navigator.pop(context); // 关闭对话框
                          },
                        ),
                      ],
                    );
                  }
                  else {
                    String password = ""; // 用于保存用户输入的密码
                    String new_pwd = "";
                    print(globals.password); // 防止开发的时候忘记密码了
                    return AlertDialog(
                      title: Text('Change Password'),
                      content: Container(
                        height: 140, // 调整对话框内容的高度
                        child: Column(
                          children: [
                            SizedBox(
                              height: 60, // 调整每个文本框的高度
                              child: TextField(
                                onChanged: (value) {
                                  password = value;
                                },
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Please enter the original password',
                                ),
                              ),
                            ),
                            SizedBox(height: 20), // 调整文本框之间的间距
                            SizedBox(
                              height: 60, // 调整每个文本框的高度
                              child: TextField(
                                onChanged: (value) {
                                  new_pwd = value;
                                },
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Please enter the new password',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.pop(context); // 关闭对话框
                          },
                        ),
                        TextButton(
                          child: Text('Confirm'),
                          onPressed: () async{
                            // 在这里判断用户输入的密码是否正确
                            if (password == globals.password) {
                              if (new_pwd != "") {
                                globals.password = new_pwd;
                                await writePwdToFile(new_pwd);
                              }
                              Navigator.pop(context); // 关闭对话框
                            } else {
                              // 密码错误，可以显示提示信息
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                      title: Text('Origin password is wrong!')
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
            leading: Icon(Icons.menu_book),
            title: Text('Readme'),
            onTap: () {
            },
          ),
          ListTile(
            leading: Icon(Icons.login),
            title: Text('Login'),
            onTap: () {
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
            },
          ),
        ],
      ),
    );
  }
}

