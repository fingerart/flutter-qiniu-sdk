import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qiniu_sdk/flutter_qiniu_sdk.dart';
import 'package:flutter_qiniu_sdk/models.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _tokenController = TextEditingController(
      text:
      "oBq1g3XfJwIoDr08eUMd8uDesH8hqexM_HKuEerb:vNLGUWlG-zN9g6Fq4ddz0pppHdI=:eyJjYWxsYmFja0JvZHlUeXBlIjoiYXBwbGljYXRpb24vanNvbiIsInNjb3BlIjoiZGFoZW5nLXl0OjQvWVRfSU0vMjAxOTA5MjUvTGJFWXVaekkvbmltYW1haW1hLnBpIiwiY2FsbGJhY2tVcmwiOiJodHRwOi8vamN0ZXN0LmZyZWUuaWRjZmVuZ3llLmNvbS9pbXMvY2FsbCIsImRlYWRsaW5lIjoxNTY5MzgxNjg5LCJjYWxsYmFja0JvZHkiOiJ7XCJrZXlcIjpcIiQoa2V5KVwiLFwiaGFzaFwiOlwiJChldGFnKVwiLFwiYnVja2V0XCI6XCIkKGJ1Y2tldClcIixcImZzaXplXCI6JChmc2l6ZSl9In0=");
  var _keyController = TextEditingController(text: "4/YT_IM/20190925/LbEYuZzI/nimamaima.pi");

  String _logs;
  String _filename;
  double _progress;
  String _state;

  UpCancellation cancelable;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if (!mounted) return;
    var config = ConfigBuilder()
      ..enableRecord = true
      ..zone = Zone.autoZone
      ..useHttps = true;
    QiNiu.config(config);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('QiNiu SDK plugin'),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Token:"),
                  Padding(padding: EdgeInsets.only(left: 10)),
                  Expanded(
                    child: TextField(
                      controller: _tokenController,
                      minLines: 2,
                      maxLines: 2,
                      decoration: InputDecoration.collapsed(hintText: null),
                    ),
                  )
                ],
              ),
              Divider(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Key:"),
                  Padding(padding: EdgeInsets.only(left: 10)),
                  Expanded(
                    child: TextField(
                      controller: _keyController,
                      minLines: 2,
                      maxLines: 2,
                      decoration: InputDecoration.collapsed(hintText: null),
                    ),
                  )
                ],
              ),
              Divider(),
              Row(
                children: <Widget>[
                  OutlineButton(onPressed: () => _selectFileAndUpload(), child: Text("Select file & Upload")),
                  VerticalDivider(),
                  OutlineButton(onPressed: () => _cancelUpload(), child: Text("Cancel")),
                ],
              ),
              Divider(),
              Text("file: ${_filename ?? ""}"),
              Divider(),
              Row(children: <Widget>[
                Text("progress: ${((_progress ?? 0) * 100).toInt()}%"),
                VerticalDivider(),
                Text("state: ${_state ?? ""}"),
              ]),
              Divider(),
              Expanded(child: Text(_logs ?? ""))
            ],
          ),
        ),
      ),
    );
  }

  void _selectFileAndUpload() async {
    var key = _keyController.text;
    if (key.isEmpty) {
      return;
    }
    var token = _tokenController.text;
    if (token.isEmpty) {
      return;
    }
    var filepath = await FilePicker.getFilePath();
    if (filepath == null) {
      return;
    }
    cancelable = await QiNiu.put(key, token, filepath, onProgress: (String key, double percent) {
      debugPrint("onProgress: $key, $percent");
      setState(() {
        _progress = percent;
      });
    }, onComplete: (String key, ResponseInfo info, String response) {
      debugPrint("onComplete: $key, $info, $response");
      setState(() {
        _logs = info.toString();
        _state = info.isOK() ? "上传完成" : info.error;
      });
    });
    setState(() {
      _filename = filepath.substring(filepath.lastIndexOf("/") + 1);
      _state = "上传中";
    });
  }

  _cancelUpload() async {
    await cancelable?.cancel();
    setState(() => _state = "取消上传");
  }
}
