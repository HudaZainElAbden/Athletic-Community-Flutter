import 'package:athletic_community/Models/BookedTraining.dart';
import 'package:athletic_community/Pages/UpcomingTraining.dart';
import 'package:athletic_community/Services/Firestore.dart';
import 'package:athletic_community/Services/UserData.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UpcomingTrainingIcon extends StatefulWidget {
  const UpcomingTrainingIcon({Key? key}) : super(key: key);

  @override
  _UpcomingTrainingIconState createState() => _UpcomingTrainingIconState();
}

class _UpcomingTrainingIconState extends State<UpcomingTrainingIcon> {
  Database _db = new Database();

  Stream? reservationTimeStream;
  getReservationTimeList()async{
    _db.getReservationTime().then((value){
      setState(() {
        reservationTimeStream = value;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getReservationTimeList();
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: reservationTimeStream,
      builder: (context, AsyncSnapshot snap){
        if(snap.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator(),);
        else if(snap.connectionState == ConnectionState.active || snap.connectionState == ConnectionState.done) {
          if (snap.hasError)
            return Center(
                child: Text('Error!', style: TextStyle(color: Colors.white),));
          else if (snap.hasData == false)
            return Center(child: Text('Empty Data', style: TextStyle(color: Colors.white)));
          else{

            DateTime _now = DateTime.now();
            String _currentTime = DateFormat('HH:mm').format(_now);
            String _currentDate = DateFormat('yyyy-MM-dd').format(_now);

            for(int i=0; i<snap.data.docs.length; i++){
              Map _bookedTrainingMap = snap.data.docs[i].data();
              BookedTraining _currentBookedTraining = new BookedTraining(_bookedTrainingMap['clubName'], _bookedTrainingMap['sportName'],
                  _bookedTrainingMap['date'], _bookedTrainingMap['time'], _bookedTrainingMap['price']);
              _currentBookedTraining.id = snap.data.docs[i].id;//used as code of this reservation
              _currentBookedTraining.startTimeMinusOneHour = _bookedTrainingMap['startTimeMinusOneHour'];//used while cancelling reservation time

              var splitDate = _currentBookedTraining.date!.split('-');
              String bookedTrainingReversedDate=""; //'yyyy-MM-dd'
              for(int i=2; i>=0 ;i--)
              {
                bookedTrainingReversedDate += splitDate[i];
                if(i!=0)
                  bookedTrainingReversedDate += '-';
              }

              DateTime punishmentDate = DateFormat('yyyy-MM-dd').parse(bookedTrainingReversedDate);
              punishmentDate = punishmentDate.add(Duration(days: 3));
              String _punishmentDate = DateFormat('yyyy-MM-dd').format(punishmentDate);

              //if the reserved day before today
              if(_currentDate.compareTo(bookedTrainingReversedDate) == 1){
                _db.deleteReservationTime(_currentBookedTraining);
                _db.setPunishmentDate(_punishmentDate);
                UserData.punishmentDate = _punishmentDate;
              }
              //if today is the reserved day comparing current time with start time
              else if(_currentDate.compareTo(bookedTrainingReversedDate) == 0 && _currentTime.compareTo(_currentBookedTraining.time!.substring(0,5)) == 1){
                _db.deleteReservationTime(_currentBookedTraining);
                _db.setPunishmentDate(_punishmentDate);
                UserData.punishmentDate = _punishmentDate;
              }

            }

            return Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.calendar_today, color: Colors.black87,),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => UpcomingTraining()));
                  },
                ),
                snap.data.docs.length==0?SizedBox():
                Positioned(
                    left: 6,
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle
                      ),
                      child: Text(
                        snap.data.docs.length.toString(),
                      ),
                    ))
              ],
            );
          }
        }
        else
          return Center(child: Text('Error!', style: TextStyle(color: Colors.white)));
      },
    );

  }
}
