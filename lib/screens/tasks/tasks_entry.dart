import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import 'package:pim/utils.dart' as utils;

import 'tasks_db_worker.dart';
import 'tasks_model.dart' show TasksModel, tasksModel;

class TasksEntry extends StatelessWidget {

  TasksEntry() {
    _desctiptionEditingController.addListener( () {
      tasksModel.entityBeingEdited.description = _desctiptionEditingController.text;
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _desctiptionEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _desctiptionEditingController.text = tasksModel?.entityBeingEdited?.description ?? '';
    return ScopedModel(
      model: tasksModel,
      child: ScopedModelDescendant<TasksModel>(
        builder: (BuildContext inContext, Widget child, TasksModel model) {
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
                      _save(inContext, tasksModel);
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
                    leading: Icon(Icons.description),
                    title: TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: "Description",
                      ),
                      controller: _desctiptionEditingController,
                      validator: (String inValue) {
                        if (inValue.isEmpty) {
                          return "Please enter a description";
                        }
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.today),
                    title: Text(
                      "Due Date",
                    ),
                    subtitle: Text(
                      tasksModel.chosenDate == null ? '' : tasksModel.chosenDate,
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () async {
                        String chosenDate = await utils.selectDate(
                          inContext, 
                          model, 
                          tasksModel.entityBeingEdited.dueDate,
                        );
                        if (chosenDate != null) {
                          tasksModel.entityBeingEdited.dueDate = chosenDate;
                        }
                      },
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

  void _save(BuildContext inContext, TasksModel inModel) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    if (inModel.entityBeingEdited.id == null) {
      await TasksDBWorker.db.create(
        tasksModel.entityBeingEdited
      );
    } else {
      await TasksDBWorker.db.update(
        tasksModel.entityBeingEdited
      );
    }
    tasksModel.loadData("tasks", TasksDBWorker.db);
    inModel.setStackIndex(0);
    Scaffold.of(inContext).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text("Task saved"),
      ),
    );
  }

}