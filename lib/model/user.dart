import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class User {
  static final User _instance = new User._internal();
  static final String _collection = "users";
  String id = "";
  String name = "";
  DateTime birthDate = DateTime.now();
  String gender = "";
  String email = "";
  String phone = "";
  double height = 0.0;
  double weight = 0.0;
  List<dynamic> diets = [];
  List<dynamic> allergies = [];
  List<dynamic> complications = [];
  bool onMedication = false;
  bool recentSurgery = false;
  String fitnessGoal = "";
  String fitnessLevel = "";
  String activityLevel = "";
  bool smoking = false;
  bool drinkingAlcohol = false;
  String sleepPerDay = "";
  String planDuration = "";
  String preferredTime = "";
  
  User._internal();

  factory User() {
    return _instance;
  }

  Future<User> getData() async {
    try {
      await FirebaseFirestore.instance.collection(_collection).doc(id).get().then((data) {
        if (data.exists) {
          name = data.get("name");
          birthDate = (data.get("birthDate") as Timestamp).toDate();
          gender = data.get("gender");
          email = data.get("email");
          phone = data.get("phone");
          height = data.get("height");
          weight = data.get("weight");
          diets = data.get("diets");
          allergies = data.get("allergies");
          complications = data.get("complications");
          onMedication = data.get("onMedication");
          recentSurgery = data.get("recentSurgery");
          fitnessGoal = data.get("fitnessGoal");
          fitnessLevel = data.get("fitnessLevel");
          activityLevel = data.get("activityLevel");
          smoking = data.get("smoking");
          drinkingAlcohol = data.get("drinkingAlcohol");
          sleepPerDay = data.get("sleepPerDay");
          planDuration = data.get("planDuration");
          preferredTime = data.get("preferredTime");
          debugPrint("User retrieved: ${data.data()}");
        }
        else {
          throw("User not retrieved.");
        }
        
      }).catchError((error) {
        throw error;
      });
    } catch (error) {
      rethrow;
    }
    return this;
  }

  Future<void> saveUser(bool newUser) async {
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection(_collection);

    final Map<String, dynamic> userData = {
      "name": name,
      "birthDate": birthDate,
      "gender": gender,
      "email": email,
      "phone": phone,
      "height": height,
      "weight": weight,
      "diets": diets,
      "allergies": allergies,
      "complications": complications,
      "onMedication": onMedication,
      "recentSurgery": recentSurgery,
      "fitnessGoal": fitnessGoal,
      "fitnessLevel": fitnessLevel,
      "activityLevel": activityLevel,
      "smoking": smoking,
      "drinkingAlcohol": drinkingAlcohol,
      "sleepPerDay": sleepPerDay,
      "planDuration": planDuration,
      "preferredTime": preferredTime,
      "updatedAt": FieldValue.serverTimestamp(),
    };

    if (newUser) {
      userData.addAll({
        "createdAt": FieldValue.serverTimestamp(),
      });
    }

    usersCollection.doc(id).set(userData).then((_) async {
      debugPrint("User saved: $userData");
    }).catchError((error) {
      throw error;
    });
  }

  Future<void> signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize();
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      id = userCredential.user!.uid;
      debugPrint("Credential: $credential");
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signUpWithEmail(emailAddress, password) async {
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      id = userCredential.user!.uid;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signInWithEmail(emailAddress, password) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAddress,
        password: password
      );
      id = userCredential.user!.uid;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (error) {
      rethrow;
    }
  }
}