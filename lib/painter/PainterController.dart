
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:orbi_test/models/PathDetails.dart';
import 'dart:ui' as ui;
import 'Painter.dart';

class PainterController extends ChangeNotifier{
  List<PathDetails> _paths = [];

  ui.Image _backgroundImage;
  String _backgroundImagePath;
  bool _isDrawing = false;
  Size _canvasSize;
  bool _isLoading = false;


  get isLoading => _isLoading;

  void onPanStart(DragStartDetails details){
    if(!_isDrawing)
    {
      _paths.add(
        PathDetails(Path()..moveTo(details.localPosition.dx, details.localPosition.dy), Paint()..style = PaintingStyle.stroke..strokeWidth = 2.5)
      );
      _isDrawing = true;
      notifyListeners();
    }
  }

  void onPanUpdate(DragUpdateDetails details){
    if(_isDrawing)
    {
      _paths.last.path.lineTo(details.localPosition.dx, details.localPosition.dy);
      notifyListeners();
    }
  }
  void onPanEnd(DragEndDetails details){
    _isDrawing = false;
    notifyListeners();
  }

  void undo(){
    _paths.removeLast();
  }

  void clear(){
    _paths.clear();
  }

  // Shouldn't be called directly, used by Painter
  void draw(Canvas canvas, Size size){
    _canvasSize = size;
    if(_backgroundImage != null)
      paintImage(
          canvas: canvas,
          image: _backgroundImage,
          fit: BoxFit.fill,
          rect: ui.Rect.fromLTRB(0, 0, size.width, size.height)
      );

    _paths.forEach((element) {
      canvas.drawPath(element.path, element.paint);
    });
  }

  // Redrawing with _backgroundImage size, to preserve its size
  void drawForRecorder(Canvas canvas, Size size){
    if(_backgroundImage != null)
    {
      paintImage(
          canvas: canvas,
          image: _backgroundImage,
          fit: BoxFit.fill,
          rect: ui.Rect.fromLTRB(0, 0, size.width, size.height)
      );
      canvas.scale(
          size.width / _canvasSize.width,
          size.height / _canvasSize.height
      );
    }

    _paths.forEach((element) {
      canvas.drawPath(element.path, element.paint);
    });
  }

  Future<ui.Image> getImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    drawForRecorder(canvas, Size(_backgroundImage.width.floorToDouble(), _backgroundImage.height.floorToDouble()));
    return await recorder.endRecording().toImage(_backgroundImage.width.floor(), _backgroundImage.height.floor());
  }

  set backgroundImage(ui.Image image){
    _backgroundImage = image;
    notifyListeners();
  }

  void setBackgroundImageByPath(String imagePath) async {
    if(_backgroundImagePath != imagePath)
    {
      _isLoading = true;
      notifyListeners();
      backgroundImage = await _loadImage(imagePath);
      _backgroundImagePath = imagePath;

      _isLoading = false;
      notifyListeners();
    }
  }

  void forceNotifyListeners() {
    notifyListeners();
  }

  Future<ui.Image> _loadImage(String path) async {
    Completer completer = Completer<ui.Image>();
    final Uint8List bytes = await File(path).readAsBytes();
    ui.decodeImageFromList(bytes, (ui.Image img) {
      return completer.complete(img);
    });

    return completer.future;
  }

  Widget buildPainter(BuildContext context, Size drawingSpaceSize){
    Size paintSize;
    if(_backgroundImage != null){
      paintSize = scaleDown(drawingSpaceSize);
    }

    final Widget painter = CustomPaint(
      size: paintSize != null ? paintSize : Size.infinite,
      painter: Painter(
        this
      ),
    );
    return painter;
  }

  Size scaleDown(Size outputSize){
    Size destinationSize = Size(_backgroundImage.width.toDouble(), _backgroundImage.height.toDouble());
    final double aspectRatio = destinationSize.width / destinationSize.height;
    if (destinationSize.height > outputSize.height)
      destinationSize = Size(outputSize.height * aspectRatio, outputSize.height);
    if (destinationSize.width > outputSize.width)
      destinationSize = Size(outputSize.width, outputSize.width / aspectRatio);

    return destinationSize;
  }
}