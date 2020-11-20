import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orbi_test/models/DrawingPageArgs.dart';

import 'DrawingPage.dart';

class HomePage extends StatelessWidget {

  final String title = "Title";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                var image = await ImagePicker().getImage(source: ImageSource.gallery);
                if(image != null)
                  Navigator.pushNamed(context, DrawingPage.routeName, arguments: DrawingPageArgs(image.path, image.path.split('/').last));
              },
              child: Text('Select image'),
            )
          ],
        ),
      ),
    );
  }

}
