import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'tasks_db_worker.dart';
import 'tasks_model.dart' show Task, TasksModel, tasksModel;

class TasksList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: tasksModel,
      child: ScopedModelDescendant<TasksModel> (
        builder: (BuildContext context, Widget child, TasksModel model) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                tasksModel.entityBeingEdited = Task();
                tasksModel.setStackIndex(1);
              },
            ),
            body: ListView.builder(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              itemCount: tasksModel.entityList.length,
              itemBuilder: (BuildContext inBuildContext, int inIndex) {
                Task task = tasksModel.entityList[inIndex];
                String sDueDate;
                if (task.dueDate != null) {
                  List dateParts = task.dueDate.split(',');
                  DateTime dueDate = DateTime(
                    int.parse(dateParts[0]), 
                    int.parse(dateParts[1]),
                    int.parse(dateParts[2])
                    );
                  sDueDate = DateFormat.yMMMMd(
                    'en_US'
                  ).format(dueDate.toLocal());
                }
                return Slidable(
                  delegate: SlidableDrawerDelegate(),
                  actionExtentRatio: .25,
                  child: ListTile(
                    title: Text(
                      '${task?.description ?? ''}',
                      style: task.completed == "true" ?
                      TextStyle(
                        color: Theme.of(inBuildContext).disabledColor,
                        decoration: TextDecoration.lineThrough,
                      ) : 
                      TextStyle(
                        color: Theme.of(inBuildContext).textTheme.title.color,
                      ),
                    ),
                    subtitle: task.dueDate == null ? null :
                    Text(
                      sDueDate,
                      style: task.completed == "true" ?
                      TextStyle(
                        color: Theme.of(inBuildContext).disabledColor,
                        decoration: TextDecoration.lineThrough,
                      ) : 
                      TextStyle(
                        color: Theme.of(inBuildContext).textTheme.title.color
                      ),
                    ),
                    onTap: () async {
                      if (task.completed == "true") {
                        return;
                      }
                      tasksModel.entityBeingEdited = await TasksDBWorker.db.get(task.id);
                      if (tasksModel.entityBeingEdited.dueDate == null) {
                        tasksModel.setChosenDate(null);
                      } else {
                        tasksModel.setChosenDate(sDueDate);
                      }
                      tasksModel.setStackIndex(1);
                    },
                    leading: Checkbox(
                      value: task.completed == "true" ? true : false,
                      onChanged: (bool inValue) async {
                        task.completed = inValue.toString();
                        await TasksDBWorker.db.update(task);
                        tasksModel.loadData('tasks', TasksDBWorker.db);
                      },
                    ),
                  ),
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      caption: "Delete",
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () => _deleteTask(inBuildContext, task),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteTask(BuildContext context, Task inTask) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext alertContext) {
        return AlertDialog(
          title: Text('Delete Task'),
          content: Text(
            'Are you sure you wanna delete ${inTask?.description ?? ''}'
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
                await TasksDBWorker.db.delete(inTask.id);
                Navigator.of(alertContext).pop();
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                    content: Text('Task deleted'),
                  ),
                );
                tasksModel.loadData("tasks", TasksDBWorker.db);
              },
            ),
          ],
        );
      }
    );
  }

}