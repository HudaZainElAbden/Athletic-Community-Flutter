
class BookedTraining{
  String? clubName, sportName, date, time, price, id;
  String? startTimeMinusOneHour; //to compare between currentTime and (startTime - 2 hours) while cancelling reservation time

  //id --> //used while deleting reservation time
  BookedTraining(this.clubName, this.sportName, this.date, this.time, this.price);
}