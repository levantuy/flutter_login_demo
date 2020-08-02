import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_login_demo/models/category.dart';

class Calculator {
  String key;
  DateTime calDate;
  Category category;
  int count;
  String userId;

  Calculator(this.calDate, this.category, this.count, this.userId);

  Calculator.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,
        userId = snapshot.value["userId"],
        category = Category.fromJson(snapshot.value["category"]),
        count = snapshot.value["count"],
        calDate = new DateTime.fromMillisecondsSinceEpoch(snapshot.value["calDate"]);

  toJson() {
    return {
      "userId": userId,
      "category": category.toJson(),
      "count": count,
      "calDate": calDate.millisecondsSinceEpoch
    };
  }
}