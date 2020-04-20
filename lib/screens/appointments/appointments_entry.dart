import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import 'appointments_db_worker.dart';
import 'appointments_model.dart' show AppointmentsModel, appointmentsModel;

class AppointmentsEntry extends StatelessWidget {

  AppointmentsEntry() {
    _titleEditingController.addListener( () {
      appointmentsModel.entityBeingEdited.title = _titleEditingController.text;
    });
    _desctiptionEditingController.addListener( () {
      appointmentsModel.entityBeingEdited.desctiption = _desctiptionEditingController.text;
    });
  }

  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _desctiptionEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _titleEditingController.text = appointmentsModel?.entityBeingEdited?.title ?? '';
    _desctiptionEditingController.text = appointmentsModel?.entityBeingEdited?.desctiption ?? '';
    return ScopedModel(
      model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(
        builder: (BuildContext inContext, Widget child, AppointmentsModel model) {
          return Scaffold(
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: Row(
                children: <Widget>[
                  FlatButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      FocusScope.of(inContext).requestFocus(FocusNode());
                      model.setStackIndex(0);
                    },
                  ),
                  Spacer(),
                  FlatButton(
                    child: Text('Save'),
                    onPressed: () {
                      _save(inContext, appointmentsModel);
                    },
                  ),
                ],
              ),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.title),
                    title: TextFormField(
                      decoration: InputDecoration(
                        hintText: "Title",
                      ),
                      controller: _titleEditingController,
                      validator: (String inValue) {
                        if (inValue.isEmpty) {
                          return "Please enter a title";
                        }
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.content_paste),
                    title: TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: "Content",
                      ),
                      controller: _desctiptionEditingController,
                      validator: (String inValue) {
                        if (inValue == 0) {
                          return "Please enter content";
                        }
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.alarm),
                    title: Text("Time"),
                    subtitle: Text(
                      appointmentsModel.apptTime == null ? "" : appointmentsModel.apptTime
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () => _selectTime(inContext),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future _selectTime(BuildContext inContext) async {
    TimeOfDay initialTime = TimeOfDay.now();
    if (appointmentsModel.entityBeingEdited.apptTime != null) {
      List timeParts = appointmentsModel.entityBeingEdited.apptTime.split(',');
      initialTime = TimeOfDay(
        hour: int.parse(
          timeParts[0],
        ),
        minute: int.parse(
          timeParts[1]
        ),
      );
    }
    TimeOfDay picked = await showTimePicker(
      context: inContext,
      initialTime: initialTime,
    );
    if (picked != null) {
      appointmentsModel.entityBeingEdited.apptTime = '${picked.hour},${picked.minute}';
      appointmentsModel.setApptTime(picked.format(inContext));
    }
  }

  void _save(BuildContext inContext, AppointmentsModel inModel) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    if (inModel.entityBeingEdited.id == null) {
      await AppointmentsDBWorker.db.create(
        appointmentsModel.entityBeingEdited
      );
    } else {
      await AppointmentsDBWorker.db.update(
        appointmentsModel.entityBeingEdited
      );
    }
    appointmentsModel.loadData("appointments", AppointmentsDBWorker.db);
    inModel.setStackIndex(0);
    Scaffold.of(inContext).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text("Appointment saved"),
      ),
    );
  }

}