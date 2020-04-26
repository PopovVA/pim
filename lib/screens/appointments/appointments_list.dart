import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';

import 'appointments_db_worker.dart';
import 'appointments_model.dart' show Appointment, AppointmentsModel, appointmentsModel;

class AppointmentsList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    EventList<Event> _markedDateMap = EventList();
    for (
      int i = 0; i < appointmentsModel.entityList.length; i++
    ) {
      Appointment appointment = appointmentsModel.entityList[i];
      List dateParts = appointment.apptDate.split(',');
      DateTime apptDate = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );
      _markedDateMap.add(
        apptDate, 
        Event(
          date: apptDate, 
          icon: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
        ),
      );
    } 
    return ScopedModel<AppointmentsModel>(
      model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(
        builder: (BuildContext inContext, Widget child, AppointmentsModel model) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(
                Icons.add,
                color: Colors.white,
                ),
              onPressed: () async {
                appointmentsModel.entityBeingEdited = Appointment();
                DateTime now = DateTime.now();
                appointmentsModel.entityBeingEdited.apptDate = 
                "${now.year},${now.month},${now.day}";
                appointmentsModel.setChosenDate(
                  DateFormat.yMMMMd("en_US").format(now.toLocal())
                );
                appointmentsModel.setApptTime(null);
                appointmentsModel.setStackIndex(1);
              },
            ),
            body: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: CalendarCarousel(
                      inactiveWeekendTextStyle: TextStyle(
                        color: Colors.blue.withOpacity(0.6),
                        fontSize: 14.0,
                      ),
                      inactiveDaysTextStyle: TextStyle(
                        color: Colors.blue.withOpacity(0.6),
                        fontSize: 14.0,
                      ),
                      weekdayTextStyle: TextStyle(
                        color: Colors.blue,
                        fontSize: 14.0,
                      ),
                      weekendTextStyle: TextStyle(
                        color: Colors.blue,
                        fontSize: 14.0,
                      ),
                      markedDateMoreCustomDecoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(
                          Radius.circular(1000.0),
                        ),
                      ),
                      todayButtonColor: Colors.grey,
                      todayBorderColor: Colors.transparent,
                      daysHaveCircularBorder: false,
                      markedDatesMap: _markedDateMap,
                      onDayPressed: (DateTime inDate, List<Event> inEvents) {
                        _showAppointments(inDate, inContext);
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAppointments(DateTime inDate, BuildContext inContext) {
    showModalBottomSheet(
      context: inContext,
      builder: (BuildContext inContext) {
        return ScopedModel<AppointmentsModel>(
          model: appointmentsModel,
          child: ScopedModelDescendant<AppointmentsModel>(
            builder: (BuildContext inContext, Widget inChild, AppointmentsModel inModel) {
              return Scaffold(
                body: Container(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: GestureDetector(
                      child: Column(
                        children: <Widget>[
                          Text(
                            DateFormat.yMMMMd("en_US").format(inDate.toLocal()),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(inContext).accentColor,
                              fontSize: 24,
                            ),
                          ),
                          Divider(),
                          Expanded(
                            child: ListView.builder(
                              itemCount: appointmentsModel.entityList.length,
                              itemBuilder: (BuildContext inBuildContext, int inIndex) {
                                Appointment appointment = appointmentsModel.entityList[inIndex];
                                if (appointment.apptDate != "${inDate.year},${inDate.month},${inDate.day}") {
                                  return Container(
                                    height: 0,
                                  );
                                }
                                String apptTime = "";
                                if (appointment.apptTime != null) {
                                  List timeParts = appointment.apptTime.split(",");
                                  TimeOfDay at = TimeOfDay(
                                    hour: int.parse(timeParts[0]),
                                    minute: int.parse(timeParts[1])
                                  );
                                  apptTime = " (${at.format(inContext)})" ;
                                }
                                return Slidable(
                                  delegate: SlidableDrawerDelegate(),
                                  actionExtentRatio: .25,
                                  secondaryActions: <Widget>[
                                    IconSlideAction(
                                      icon: Icons.delete,
                                      caption: "Delete",
                                      color: Colors.red,
                                      onTap: () => _deleteAppointment(inBuildContext, appointment),
                                    ),
                                  ],
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 8),
                                    color: Colors.grey.shade300,
                                    child: ListTile(
                                      title: Text("${appointment.title}$apptTime"),
                                      subtitle: appointment.desctiption == null ? null : Text(
                                        '${appointment.desctiption}',
                                      ),
                                      onTap: () async {
                                        _editAppointment(inContext, appointment);
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      } 
    );
  }

  Future<void> _deleteAppointment(BuildContext context, Appointment inAppointment) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext alertContext) {
        return AlertDialog(
          title: Text('Delete appointment'),
          content: Text(
            'Are you sure you wanna delete ${inAppointment?.title ?? ''}'
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).maybePop();
              },
            ),
            FlatButton(
              child: Text("Delete"),
              onPressed: () async {
                await AppointmentsDBWorker.db.delete(inAppointment.id);
                Navigator.of(alertContext).pop();
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                    content: Text('Appointment deleted'),
                  ),
                );
                appointmentsModel.loadData("appointments", AppointmentsDBWorker.db);
              },
            ),
          ],
        );
      }
    );
  }

  void _editAppointment(BuildContext inBuildContext, Appointment inAppointment) async {
    appointmentsModel.entityBeingEdited = await AppointmentsDBWorker.db.get(inAppointment.id);
    if (appointmentsModel.entityBeingEdited.apptDate == null) {
      appointmentsModel.setChosenDate(null);
    } else {
      List dateParts = appointmentsModel.entityBeingEdited.apptDate.split(",");
      DateTime apptDate = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );
      appointmentsModel.setChosenDate(
        DateFormat.yMMMMd("en_US").format(apptDate.toLocal()),
      );
      if (appointmentsModel.entityBeingEdited.apptTime == null) {
        appointmentsModel.setApptTime(null);
      } else {
        List timeParts = appointmentsModel.entityBeingEdited.apptTime.split(",");
        TimeOfDay apptTime = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );
        appointmentsModel.setApptTime(apptTime.format(inBuildContext));
      }
      appointmentsModel.setStackIndex(1);
      Navigator.pop(inBuildContext);
    }
  }

}
