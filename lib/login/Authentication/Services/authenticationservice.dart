import 'package:Turfease/home_screen.dart';
import 'package:Turfease/login/admin_client.dart';
import 'package:Turfease/client/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:firebase_auth/firebase_auth.dart";
import 'package:flutter/material.dart';

class Authenticate {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final CollectionReference usercollect =
      FirebaseFirestore.instance.collection("Users");

  Future<void> signinwithEmail(
      {required context,
      required String email,
      required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print("signed in");
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signupwithEmail({
    required context,
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      try {
        final uid = _auth.currentUser!.uid;
        await usercollect.doc(uid).set({'Name': name, 'Email': email});
      } catch (e) {
        print(e);
      }

      print("signed up");
    } catch (e) {
      rethrow;
    }
  }

  Future<void> siginOut(context) async {
    await _auth.signOut();
    print("signout");
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OptionPage(),
        ));
  }

  Future<void> passwordReset({required context, required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  signInWithEmailAndPassword(String text, String text2) {}
}
