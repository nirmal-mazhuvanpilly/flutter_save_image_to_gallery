import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Save Image to Gallery'),
    );
  }
}

/*
<--- Note --->
//Make Changes in Android Side

### Give Permission in AndroidManifest.xml ###
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<application
android:requestLegacyExternalStorage="true">

### android>app>build.gradle ###
compileSdkVersion 31
minSdkVersion 16
targetSdkVersion 30

### android>gradle.properties ###
android.useAndroidX=true
android.enableJetifier=true
*/

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ImagePicker _picker = ImagePicker();

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      final PermissionStatus status = await permission.request();
      if (status == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  void pickImage() async {
    if (await _requestPermission(Permission.storage)) {

      // ignore: avoid_print
      print("Permission Granted");

      final XFile? img = await _picker.pickImage(source: ImageSource.camera);

      if (Platform.isAndroid) {
        // ignore: avoid_print
        print("---Android---");

        final directory = await getExternalStorageDirectory();

        String newPath = "";

        List<String> paths = directory!.path.split("/");
        for (int i = 1; i < paths.length; i++) {
          String folder = paths[i];
          if (folder != "Android") {
            newPath = newPath + "/" + folder;
          } else {
            break;
          }
        }
        newPath = newPath + "/ImageSaver";

        // ignore: unused_local_variable
        final myDir = await Directory(newPath).create();

        final bytes = File(img!.path).readAsBytesSync();

        final save = File("$newPath/image.jpg");
        save.writeAsBytesSync(bytes);
      }
    } else {
      // ignore: avoid_print
      print("Permission Denied");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: pickImage,
          child: const Text("Click Image"),
        ),
      ),
    );
  }
}
