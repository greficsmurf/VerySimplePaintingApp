
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:animated_floatactionbuttons/animated_floatactionbuttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:orbi_test/imagesaver/ImageSaver.dart';
import 'package:orbi_test/models/DrawingPageArgs.dart';
import 'package:orbi_test/models/TouchPoint.dart';
import 'package:orbi_test/painter/Painter.dart';
import 'package:orbi_test/painter/PainterController.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class DrawingPage extends StatelessWidget{
  static const String routeName = '/image';

  final _painterController = PainterController();
  final _imageSaver = ImageSaver();
  DrawingPageArgs _args;

  @override
  Widget build(BuildContext context) {
    _args = ModalRoute.of(context).settings.arguments;
    _painterController.setBackgroundImageByPath(_args.imagePath);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Title"
        ),
      ),
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider<PainterController>(create: (context) => _painterController),
          ChangeNotifierProvider<ImageSaver>(create: (context) => _imageSaver),
        ],
        child: GestureDetector(
          child: Consumer2<PainterController, ImageSaver>(
            builder: (context, controller, saver, widget){
              final painter = controller.buildPainter(context, Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height - Scaffold.of(context).appBarMaxHeight));
              if(!saver.isLoading && !controller.isLoading){
                return painter;
              }else{
                return Stack(
                  children: <Widget>[
                    IgnorePointer(
                      child: painter,
                    ),
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                  ],
                );
              }
            },
          ),
          onPanStart: _painterController.onPanStart,
          onPanUpdate:  _painterController.onPanUpdate,
          onPanEnd:  _painterController.onPanEnd,
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return AnimatedFloatingActionButton(
            fabButtons: _buildFabOptions(context),
            animatedIconData: AnimatedIcons.menu_close,
          );
        },
      ),
    );
  }

  List<Widget> _buildFabOptions(BuildContext context){
    return <Widget>[
      FloatingActionButton(
        heroTag: "Cancel",
        onPressed: () {
          _painterController.undo();
        },
        tooltip: "Cancel last action",
        child: Icon(Icons.arrow_back),
      ),
      FloatingActionButton(
        heroTag: "Clear",
        onPressed: () {
          _painterController.clear();
        },
        tooltip: "Clear drawing",
        child: Icon(Icons.restore),
      ),
      FloatingActionButton(
        heroTag: "Save",
        onPressed: () async {
          if(!_imageSaver.isLoading){
            final image = await _painterController.getImage();
            await _imageSaver.saveImage(_args.imageName, image);
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text("Image saved as ${_args.imageName}"),
            ));
          }
        },
        tooltip: "Save drawing",
        child: Icon(Icons.save_alt),
      ),
    ];
  }


}
