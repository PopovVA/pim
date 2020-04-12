import 'package:scoped_model/scoped_model.dart';

class BaseModel extends Model {

  int stackIndex = 0;
  List entityList = [];
  var entityBeingEdited;
  String chosenDate;

  void setChosenDate(String date) {
    chosenDate = date;
    notifyListeners();
  }

  void loadData(String entityType, dynamic database) async {
    entityList = await database.getAll();
    notifyListeners();
  }

  void setStackIndex(int index) {
    stackIndex = index;
    notifyListeners();
  }

}