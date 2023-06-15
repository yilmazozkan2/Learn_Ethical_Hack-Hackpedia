import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

// ignore: must_be_immutable
class ImageButtons extends StatefulWidget {
  ImageButtons({super.key, required this.output, required this.category});

  final auth = FirebaseAuth.instance;
  var output;
  String category;

  @override
  State<ImageButtons> createState() => _ImageButtonsState();
}

class _ImageButtonsState extends State<ImageButtons> {
  File? file;
  String imageUrl = '';
  var image;
  final _picker = ImagePicker();
  final db = FirebaseFirestore.instance;

  uploadImage(String uid, category) async {
    Reference reference = FirebaseStorage.instance
        .ref()
        .child('profileImage/${basename(file!.path)}}');
    UploadTask uploadTask = reference.putFile(File(file!.path));
    TaskSnapshot snapshot = await uploadTask;
    await uploadTask.whenComplete(() async {
      imageUrl = await snapshot.ref.getDownloadURL();
      if (imageUrl.isNotEmpty) {
        var db = FirebaseFirestore.instance;
        DocumentReference ref =
            db.collection('Kullanicilar').doc(widget.auth.currentUser!.email);
        ref.update({
          'images': FieldValue.arrayUnion([
            {'url': imageUrl, 'kategori': category}
          ])
        });
      }
    });
  }

  void _showPicker(context) async {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
              child: Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.photo_library),
                    title: new Text('gallery'.tr),
                    onTap: () {
                      _pickImageGallery();
                      Navigator.of(context).pop();
                    }),
              ],
            ),
          ));
        });
  }

  Future _pickImageGallery() async {
    image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        file = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: GestureDetector(
            onTap: () => _showPicker(context),
            child: Container(
              height: 50,
              width: 100,
              color: Colors.red,
              child: Center(
                child: Text('selectfromgallery'.tr,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        ?.copyWith(color: Colors.blue)),
              ),
            ),
          ),
        ),
        SizedBox(width: 5),
        GestureDetector(
          onTap: () => uploadImage(
            widget.auth.currentUser!.uid,
            widget.category,
          ),
          child: Container(
            height: 50,
            width: 100,
            color: Colors.yellow,
            child: Center(
              child: Text('saveselectedimage'.tr,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      ?.copyWith(color: Colors.blue)),
            ),
          ),
        ),
      ],
    );
  }
}
