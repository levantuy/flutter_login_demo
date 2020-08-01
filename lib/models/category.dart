import 'package:firebase_database/firebase_database.dart';

class Category {
  String key;
  String name;
  bool isActive;
  String userId;
  DateTime modifiedDate;

  Category(this.name, this.isActive, this.userId);

  Category.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,
        userId = snapshot.value["userId"],
        name = snapshot.value["name"],
        isActive = snapshot.value["isActive"],
        modifiedDate = new DateTime.fromMillisecondsSinceEpoch(snapshot.value["modifiedDate"]);

  toJson() {
    return {
      "userId": userId,
      "name": name,
      "isActive": isActive,
      "modifiedDate": DateTime.now().millisecondsSinceEpoch
    };
  }
}