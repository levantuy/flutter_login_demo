import 'package:firebase_database/firebase_database.dart';

class Calculator {
  String key;
  DateTime calDate;
  String categoryId;
  int count;
  String userId;

  Calculator(this.calDate, this.categoryId, this.count, this.userId);

  Calculator.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,
        userId = snapshot.value["userId"],
        categoryId = snapshot.value["categoryId"],
        count = snapshot.value["count"],
        calDate = new DateTime.fromMillisecondsSinceEpoch(snapshot.value["calDate"]);

  toJson() {
    return {
      "userId": userId,
      "categoryId": categoryId,
      "count": count,
      "calDate": calDate.millisecondsSinceEpoch
    };
  }
}