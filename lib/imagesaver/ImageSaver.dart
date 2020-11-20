
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;

class ImageSaver extends ChangeNotifier{

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<String> get _localPath async {
    final dir = await getExternalStorageDirectory();
    return dir.path;
  }

  Future<File> _getSaveFile(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName.png');
  }

  Future<Null> saveImage(String imageName, ui.Image image) async {
    _isLoading = true;
    notifyListeners();
    final saveFile = await _getSaveFile(imageName);
    final imageBytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final buffer = imageBytes.buffer;
    final intList = buffer.asUint8List(imageBytes.offsetInBytes, imageBytes.lengthInBytes);
    await saveFile.writeAsBytes(intList);
    _isLoading = false;
    notifyListeners();
  }
}