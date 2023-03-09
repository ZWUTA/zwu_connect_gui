import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    String? font;
    if (Platform.isWindows && Platform.localeName == "zh_CN") {
      font = "Microsoft YaHei";
    }

    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: font,
      ),
      home: const MyHomePage(title: 'ZWU Connect GUI'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool useTwfid = false;
  bool isRunning = false;
  late Process? _process;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        // 左右padding 24
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 16.0),
                //服务器地址
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '服务器地址',
                    icon: Icon(Icons.computer),
                  ),
                  initialValue: "webvpn.zwu.edu.cn",
                ),
                const SizedBox(height: 16.0),
                //服务器端口
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '服务器端口',
                    icon: Icon(Icons.portable_wifi_off),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  initialValue: "443",
                ),
                const SizedBox(height: 16.0),
                //用户名
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '用户名',
                    icon: Icon(Icons.person),
                  ),
                  enabled: !useTwfid,
                ),
                const SizedBox(height: 16.0),
                //密码
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '密码',
                    icon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  enabled: !useTwfid,
                ),
                const SizedBox(height: 16.0),
                //使用twf-id登录
                CheckboxListTile(
                  title: const Text('使用twf-id登录'),
                  value: useTwfid,
                  onChanged: (bool? value) {
                    setState(() {
                      useTwfid = value ?? false;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                //twf-id
                TextFormField(
                  enabled: useTwfid,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'twf-id',
                    icon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16.0),
                //socks5代理端口
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'SOCKS5代理端口',
                    icon: Icon(Icons.portable_wifi_off),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  initialValue: "1080",
                ),
                const SizedBox(height: 16.0),
                //http代理端口
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'HTTP代理端口(TODO)',
                    icon: Icon(Icons.portable_wifi_off),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  initialValue: "1081",
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 修改按钮Icon为Icons.airplanemode_on
          setState(() {
            isRunning = !isRunning;
          });

          if (isRunning) {
            var fileName = "./zwu_connect";
            if (Platform.isWindows) {
              fileName += ".exe";
            }

            // 如果./zwu_connect不存在，弹窗提示
            if (!File(fileName).existsSync()) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("错误"),
                    content: const Text("zwu_connect文件不存在"),
                    actions: <Widget>[
                      TextButton(
                        child: const Text("确定"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
              setState(() {
                isRunning = false;
              });
              return;
            }

            // 执行./zwu_connect
            Process.start(fileName, []).then((Process process) {
              _process = process;
              process.stdout.transform(utf8.decoder).listen((data) {
                print(data);
              });
            });
          } else {
            // 杀死zwu_connect进程
            _process?.kill();
          }
        },
        child: Icon(isRunning ? Icons.airplanemode_on : Icons.airplanemode_off),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
