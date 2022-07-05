import 'package:athletic_community/UIHelp/MyAppBar.dart';
import 'package:athletic_community/UIHelp/SideMenuDrawer.dart';
import 'package:flutter/material.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  late double scWidth;
  late double scHeight;

  @override
  Widget build(BuildContext context) {
    scWidth = MediaQuery.of(context).size.width;
    scHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white10,
      drawer: SideMenuDrawer(),
      appBar: MyAppBar(),
      body: Container(
        width: scWidth,
        height: scHeight,
        decoration: BoxDecoration(
            // gradient: LinearGradient(colors: [
            //   Colors.white,
            //   Colors.green,
            //   Colors.white,
            // ], begin: Alignment.bottomLeft, end: Alignment.topRight)
            color: Colors.white
        ),

        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                  'Athletic Community is an application where you can gather a team easily to play a match of your'
                      ' favourite sport (football, basketball, etc.) at the available clubs in.\n\n',
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(Icons.email, color: Colors.black87,),
                  Text('hodazainelabden67@gmail.com', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),),
                ],
              ),
            )

          ],
        ),
      ),
    );
  }
}
