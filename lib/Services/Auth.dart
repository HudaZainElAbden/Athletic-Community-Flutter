import 'package:athletic_community/Services/UserData.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future signIn(String email, String password) async {
    try {
      UserCredential res = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      UserData.email = res.user!.email!;
      return true;
    } on FirebaseAuthException catch (e) {
      print(e.code);
      return false;
    }
  }

  Future signUp(String email, String password) async {
    try {
      UserCredential res = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      UserData.email = email;
      return true;
    } on FirebaseAuthException catch (e) {
      print(e.code);
      return false;
    }
  }

  Future resetPassword(String _newPass)async{
    var firebaseUser = _auth.currentUser;
    //old credential
    firebaseUser!.updatePassword(_newPass).then((value){
      print("Successfully changed password");
    }).catchError((error){
      print("Password can't be changed!" + error.toString());
    });
  }
}
