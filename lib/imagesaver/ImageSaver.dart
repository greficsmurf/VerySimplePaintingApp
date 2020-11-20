
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;

import 'package:permission_handler/permission_handler.dart';

class ImageSaver extends ChangeNotifier{

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<String> get _localPath async {
    final dir = await getExternalStorageDirectory();
    return dir.path;
  }

  Future<Null> saveImage(String imageName, ui.Image image) async {
    _isLoading = true;
    notifyListeners();

    final imageBytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final buffer = imageBytes.buffer;
    final intList = buffer.asUint8List(imageBytes.offsetInBytes, imageBytes.lengthInBytes);

    if(await Permission.storage.request().isGranted){
      final result = await ImageGallerySaver.saveImage(
          intList,
          name: imageName);
    }


    _isLoading = false;
    notifyListeners();
  }
}