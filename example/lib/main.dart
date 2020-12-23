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
      "oBq1g3XfJwIoDr08eUMd8uDesH8hqexM_HKuEerb:Kbs_4ZURZn4fxyGI_vDx53Dws30=:eyJjYWxsYmFja0JvZHlUeXBlIjoiYXBwbGljYXRpb24vanNvbiIsInNjb3BlIjoiZG9jcy1kZXY6bHpiLzIwMjAxMjIzL2JRUWVJMlNQLzEyMy5wbmciLCJkZWFkbGluZSI6MTYwODcyMjUxOCwiY2FsbGJhY2tCb2R5Ijoie1wia2V5XCI6XCIkKGtleSlcIixcImhhc2hcIjpcIiQoZXRhZylcIixcImJ1Y2tldFwiOlwiJChidWNrZXQpXCIsXCJmaWxlU2l6ZVwiOiQoZnNpemUpfSJ9");
  var _keyController = TextEditingController(text: "lzb/20201223/bQQeI2SP/123.png");

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
                  OutlineButton(onPressed: () => _selectFileAndAsyncUpload(), child: Text("Select file & async upload")),
                  VerticalDivider(),
                  OutlineButton(onPressed: () => _cancelUpload(), child: Text("Cancel")),
                ],
              ),
              Divider(),
              Row(
                children: <Widget>[
                  OutlineButton(onPressed: () => _selectFileAndSyncUpload(), child: Text("Select file & sync upload")),
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

  void _selectFileAndAsyncUpload() async {
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

  void _selectFileAndSyncUpload() async {
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
    setState(() {
      _filename = filepath.substring(filepath.lastIndexOf("/") + 1);
      _state = "上传中";
    });
    await QiNiu.syncPut(key, token, filepath, onProgress: (String key, double percent) {
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
  }

  _cancelUpload() async {
    await cancelable?.cancel();
    setState(() => _state = "取消上传");
  }
}
