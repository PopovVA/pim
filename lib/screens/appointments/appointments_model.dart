import 'package:pim/base_model.dart';

class Appointment {

  int id;
  String title;
  String desctiption;
  String apptDate;
  String apptTime;

  String toString() {
    return '{ id=$id, title=$title,'
    'desctiption=$desctiption, apptDate=$apptDate, ' 
    'apptTime=$apptTime }';
  }

}

class AppointmentsModel extends BaseModel {

  String apptTime;

  void setApptTime(String inApptTime) {
    apptTime = inApptTime;
    notifyListeners();
  }

}

AppointmentsModel appointmentsModel = AppointmentsModel();