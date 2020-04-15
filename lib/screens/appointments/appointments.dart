import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import 'appointments_db_worker.dart';
import 'appointments_list.dart';
import 'appointments_entry.dart';
import 'appointments_model.dart' show AppointmentsModel ,appointmentsModel;

class Appointments extends StatelessWidget {

  Notes() {
    appointmentsModel.loadData('appointments', AppointmentsDBWorker.db);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(
        builder: (BuildContext inContext, Widget child, AppointmentsModel model) {
          return IndexedStack(
            index: model.stackIndex,
            children: <Widget>[
              AppointmentsList(), 
              AppointmentsEntry(),
            ],
          );
        },
      ),
    );
  }

}
