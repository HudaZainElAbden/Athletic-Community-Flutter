import 'package:athletic_community/Pages/Booking.dart';
import 'package:athletic_community/Services/Firestore.dart';
import 'package:athletic_community/UIHelp/MyAppBar.dart';
import 'package:athletic_community/UIHelp/SideMenuDrawer.dart';
import 'package:flutter/material.dart';

class AvailableSports extends StatefulWidget {
  String? _clubName;
  AvailableSports(this._clubName);

  @override
  _AvailableSportsState createState() => _AvailableSportsState();
}

class _AvailableSportsState extends State<AvailableSports> {
  late double scWidth, scHeight;
  Database _db = new Database();

  Stream? sportsStream;
  getSportsNames()async{
    return _db.getSportsNames(widget._clubName!).then((value){
      setState(() {
        sportsStream = value;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSportsNames();
  }
  @override
  Widget build(BuildContext context) {
    scWidth = MediaQuery.of(context).size.width;
    scHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white70,
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

        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              //Available Sports
              Text('Available Sports:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 20)),
              SizedBox(height: scHeight/20,),

              StreamBuilder(
                stream: sportsStream,
                builder: (context, AsyncSnapshot snap){

                  if(snap.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator(),);
                  else if(snap.connectionState == ConnectionState.active || snap.connectionState == ConnectionState.done){
                    if (snap.hasError)
                      return Center(child: Text('Error!', style: TextStyle(color: Colors.white),));
                    else if (snap.hasData == false)
                      return Center(child: Text('Empty Data', style: TextStyle(color: Colors.white)));
                    else{
                      return Expanded(
                        child: ListView.separated(
                            itemCount: snap.data.docs.length,
                            itemBuilder: (BuildContext context, int index){
                              Map _sportMap = snap.data.docs[index].data();
                              String imagePath;
                              if(_sportMap['sportName'] == 'Basketball')
                                imagePath = 'assets/images/basketballIcon.png';
                              else if(_sportMap['sportName'] == 'Football')
                                imagePath = 'assets/images/footballIcon.png';
                              else
                                imagePath = 'assets/images/handballIcon.png';

                              return GestureDetector(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Booking(widget._clubName!, _sportMap['sportName'], _sportMap['membersNum'], _sportMap['bookingPrice'])));
                                },
                                child: sportIcon(_sportMap['sportName'], imagePath),
                              );
                            }, separatorBuilder: (BuildContext context, int index)=>Divider()),
                      );
                    }
                  }
                  else
                    return Center(child: Text('Error!', style: TextStyle(color: Colors.white)));

                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget sportIcon(String _sportName, String _imagePath){
    return Container(
      height: scHeight/8,
      width: scWidth * 0.9,
      decoration: BoxDecoration(border: Border.all(color: Colors.blue, width: 2), borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('$_imagePath'),
              radius: 40,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text('$_sportName', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 18),),
            )
          ],
        ),
      ),
    );
  }
}
