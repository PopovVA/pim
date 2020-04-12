import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import 'tasks_db_worker.dart';
import 'tasks_model.dart' show TasksModel, tasksModel;
import 'tasks_list.dart';
import 'tasks_entry.dart';

class Tasks extends StatelessWidget {

  Tasks() {
    tasksModel.loadData('tasks', TasksDBWorker.db);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: tasksModel,
      child: ScopedModelDescendant<TasksModel>(
        builder: (BuildContext context, Widget child, TasksModel model) {
          return IndexedStack(
            index: model.stackIndex,
            children: <Widget>[
              TasksList(), 
              TasksEntry(),
            ],
          );
        },
      ),
    );
  }

}
