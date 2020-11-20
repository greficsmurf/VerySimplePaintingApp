
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:orbi_test/models/TouchPoint.dart';
import 'package:orbi_test/painter/PainterController.dart';

class Painter extends CustomPainter
{

  final PainterController controller;
  Painter(this.controller);

  @override
  void paint(Canvas canvas, Size size) {
    controller.draw(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  // Future<ui.Image> getImage() async {
  //   final recorder = ui.PictureRecorder();
  //   final canvas = Canvas(recorder);
  //   paint(canvas, Size(image.width.toDouble(), image.height.toDouble()));
  //   return await recorder.endRecording().toImage(size.width.toInt(), size.height.toInt());
  // }

}

