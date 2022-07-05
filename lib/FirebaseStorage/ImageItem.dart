import 'dart:typed_data';

import 'package:athletic_community/Services/UserData.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ImageItem extends StatefulWidget {
  double iconSize;
  double imageSize;
  String imageName;
  ImageItem(this.iconSize, this.imageSize, this.imageName);
  @override
  _ImageItemState createState() => _ImageItemState();
}

class _ImageItemState extends State<ImageItem> {
  var photosRef = FirebaseStorage.instance.ref("Images");
  Future? picFuture;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      picFuture = getImageFromStorage();
    });

  }

  Future getImageFromStorage()async{
    return photosRef.child(widget.imageName).getData(7*1024*1024).then((value){
      if(widget.imageName == UserData.email){
        setState(() {
          UserData.profileImageBytes = value!; //to prevent loading profile pic every time I open the menu drawer or my account page
        });
      }
      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    double scWidth = MediaQuery.of(context).size.width;
    return FutureBuilder(
      future: picFuture,
      builder: (BuildContext context, snap){

        if(snap.connectionState == ConnectionState.waiting){
          return  CircularProgressIndicator();
        }
        else if(snap.connectionState == ConnectionState.active||
            snap.connectionState == ConnectionState.done){

          if(snap.hasData){
            return CircleAvatar(radius: widget.imageSize,
              backgroundColor: Colors.white,
              backgroundImage: Image.memory(snap.data as Uint8List, fit: BoxFit.fill,).image,);
          }
          else{
            return Icon(Icons.account_circle, color: Colors.white, size: widget.iconSize,);
          }
        }
        else{
          return Text('error');
        }
      },
    );
  }
}
