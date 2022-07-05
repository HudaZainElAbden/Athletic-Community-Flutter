import 'package:athletic_community/Models/Account.dart';
import 'package:athletic_community/Models/BookedTraining.dart';
import 'package:athletic_community/Services/UserData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Database{
  //create collections
  CollectionReference accountRef = FirebaseFirestore.instance.collection('Accounts');
  CollectionReference clubsRef = FirebaseFirestore.instance.collection('Clubs');

  // saveClubsInfo()async{
  //
  //   await clubsRef.doc('El Shams').collection('Sports').doc('Football').collection('Date').doc('10-09-2021')
  //       .set({
  //     'date': '2021-09-10',
  //   });
  //   await clubsRef.doc('El Shams').collection('Sports').doc('Football').collection('Date').doc('11-09-2021')
  //       .set({
  //     'date': '2021-09-11',
  //   });
  //   await clubsRef.doc('El Shams').collection('Sports').doc('Football').collection('Date').doc('12-09-2021')
  //       .set({
  //     'date': '2021-09-12',
  //   });
  //   await clubsRef.doc('El Shams').collection('Sports').doc('Football').collection('Date').doc('13-09-2021')
  //       .set({
  //     'date': '2021-09-13',
  //   });
  //
  //   await clubsRef.doc('El Shams').collection('Sports').doc('Football').collection('Date').doc('10-09-2021').collection('Time').doc('07:00-08:30')
  //       .set({
  //     'startTime': '07:00',
  //     'endTime': '08:30'
  //   });
  //
  //   await clubsRef.doc('El Shams').collection('Sports').doc('Football').collection('Date').doc('10-09-2021').collection('Time').doc('08:30-10:00')
  //       .set({
  //     'startTime': '08:30',
  //     'endTime': '10:00'
  //   });
  //
  //   await clubsRef.doc('El Shams').collection('Sports').doc('Football').collection('Date').doc('10-09-2021').collection('Time').doc('11:30-13:00')
  //       .set({
  //     'startTime': '11:30',
  //     'endTime': '13:00'
  //   });
  //
  //   await clubsRef.doc('El Shams').collection('Sports').doc('Football').collection('Date').doc('10-09-2021').collection('Time').doc('20:30-22:00')
  //       .set({
  //     'startTime': '20:30',
  //     'endTime': '22:00'
  //   });
  //
  //   await clubsRef.doc('El Shams').collection('Sports').doc('Football').collection('Date').doc('11-09-2021').collection('Time').doc('07:00-08:30')
  //       .set({
  //     'startTime': '07:00',
  //     'endTime': '08:30'
  //   });
  //
  //   await clubsRef.doc('El Shams').collection('Sports').doc('Football').collection('Date').doc('11-09-2021').collection('Time').doc('11:30-13:00')
  //       .set({
  //     'startTime': '11:30',
  //     'endTime': '13:00'
  //   });
  //
  //   await clubsRef.doc('El Shams').collection('Sports').doc('Football').collection('Date').doc('11-09-2021').collection('Time').doc('20:30-22:00')
  //       .set({
  //     'startTime': '20:30',
  //     'endTime': '22:00'
  //   });
  //
  //   await clubsRef.doc('El Shams').collection('Sports').doc('Football').collection('Date').doc('12-09-2021').collection('Time').doc('07:00-08:30')
  //       .set({
  //     'startTime': '07:00',
  //     'endTime': '08:30'
  //   });
  //
  //   await clubsRef.doc('El Shams').collection('Sports').doc('Football').collection('Date').doc('12-09-2021').collection('Time').doc('20:30-22:00')
  //       .set({
  //     'startTime': '20:30',
  //     'endTime': '22:00'
  //   });
  //
  //   await clubsRef.doc('El Shams').collection('Sports').doc('Football').collection('Date').doc('13-09-2021').collection('Time').doc('20:30-22:00')
  //       .set({
  //     'startTime': '20:30',
  //     'endTime': '22:00'
  //   });
  //
  // }


  saveAccount(Account acc)async{
    await accountRef.doc(acc.email).set(acc.toMap());
  }

  getAccountInfo()async{
    return accountRef.doc(UserData.email).snapshots();
  }

  getUserInfo()async{
    return accountRef.doc(UserData.email).get();//used .get() bec it does not need stream builder
  }

  updateAccount(String username, String mobile, String age, String password)async{

    await accountRef.doc(UserData.email).update({
      "username": username,
      "mobile": mobile,
      "age": age,
      "password": password
    });
  }

  getReservationTime()async{
    return accountRef.doc(UserData.email).collection('ReservationTime').snapshots();
  }

  checkingBusyReservationTime()async{
    return accountRef.doc(UserData.email).collection('ReservationTime').get(); //used .get() bec it does not need stream builder
  }

  addReservationTime(BookedTraining _bookedTraining)async{
    await accountRef.doc(UserData.email).collection('ReservationTime').doc().set({
      'clubName': _bookedTraining.clubName,
      'sportName': _bookedTraining.sportName,
      'date': _bookedTraining.date,
      'time': _bookedTraining.time,
      'price': _bookedTraining.price,
      'startTimeMinusOneHour': _bookedTraining.startTimeMinusOneHour
    });
  }

  deleteReservationTime(BookedTraining _bookedTraining)async{
   await accountRef.doc(UserData.email).collection('ReservationTime').doc(_bookedTraining.id).delete();
   await clubsRef.doc(_bookedTraining.clubName).collection('Sports').doc(_bookedTraining.sportName).collection('Date').
   doc(_bookedTraining.date).collection('Time').doc(_bookedTraining.time).collection('Members').doc(UserData.email).delete();
  }

  setPunishmentDate(String _punishmentDate)async{
  await accountRef.doc(UserData.email).update({
    'punishmentDate': _punishmentDate
  });
  }

  getClubsNames()async{
    return clubsRef.snapshots();
  }

  getSportsNames(String _clubName)async{
    return clubsRef.doc(_clubName).collection('Sports').snapshots();
  }

  getDateList(String _clubName, String _sportName)async{
    return clubsRef.doc(_clubName).collection('Sports').doc(_sportName).collection('Date').orderBy('date').snapshots();
  }

  removeDate(String _clubName, String _sportName, String _dateID)async{
    await clubsRef.doc(_clubName).collection('Sports').doc(_sportName).collection('Date').doc(_dateID).delete();
  }

  getTimeSlotList(String _clubName, String _sportName, String _dateID)async{
    return clubsRef.doc(_clubName).collection('Sports').doc(_sportName).collection('Date').doc(_dateID).collection('Time').orderBy('startTime').snapshots();
  }

  removeTimeSlot(String _clubName, String _sportName, String _dateID, String _timeId)async{
    await clubsRef.doc(_clubName).collection('Sports').doc(_sportName).collection('Date').doc(_dateID).collection('Time').doc(_timeId).delete();
  }

  isUserBookedThis(BookedTraining _bookedTraining)async{
    return clubsRef.doc(_bookedTraining.clubName).collection('Sports').doc(_bookedTraining.sportName).collection('Date').
    doc(_bookedTraining.date).collection('Time').doc(_bookedTraining.time).
    collection('Members').doc(UserData.email).get();
  }

  getTeamMembers(String _clubName, String _sportName, String _dateID, String _timeId)async{
    return clubsRef.doc(_clubName).collection('Sports').doc(_sportName).collection('Date').doc(_dateID).collection('Time').doc(_timeId).collection('Members').snapshots();
  }

  saveTeamMember(String _clubName, String _sportName, String _dateID, String _timeId, String _skill)async{
    await clubsRef.doc(_clubName).collection('Sports').doc(_sportName).collection('Date').doc(_dateID).collection('Time').doc(_timeId).
    collection('Members').doc(UserData.email).set({
      'email':UserData.email,
      'skill': _skill
    });
  }

}