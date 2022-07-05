import 'package:athletic_community/Pages/UpcomingTraining.dart';
import 'package:athletic_community/Services/UserData.dart';
import 'package:athletic_community/UIHelp/UpcomingTrainingIcon.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget{

  @override
  Widget build(BuildContext context) {
    double scWidth = MediaQuery.of(context).size.width;
    double scHeight = MediaQuery.of(context).size.height;

    return AppBar(
      iconTheme: IconThemeData(color: Colors.black87),
      elevation: 20, //shadow of the appBar
      //centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
            // gradient: LinearGradient(colors: [
            //   Colors.white,
            //   Colors.green,
            //   Colors.white,
            // ], begin: Alignment.bottomLeft, end: Alignment.topRight)
            color: Colors.blue
        ),
      ),

      actions: [
        UpcomingTrainingIcon()
      ],
      title: Row(
        children: [
          Hero(
            tag: 'apps_icon',
            child: Image(
              width: scWidth * 0.1,
                image: AssetImage('assets/images/appIcon.png')
            ),
          ),
          Text(
            'Athletic Community',
            style: GoogleFonts.arsenal(
              textStyle:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(60);
  
}