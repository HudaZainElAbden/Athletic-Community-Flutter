
class Account{

  String? username, email, password, gender, age, mobile, punishmentDate;


  Account(this.username, this.email, this.password, this.gender, this.age,
      this.mobile, this.punishmentDate);

  Map<String, dynamic> toMap(){
    Map<String, dynamic> x={
      "username": this.username,
      "email": this.email,
      "password": this.password,
      "gender": this.gender,
      "age": this.age,
      "mobile": this.mobile,
      "punishmentDate": this.punishmentDate
    };
    return x;
  }
}