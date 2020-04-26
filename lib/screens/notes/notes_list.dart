import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'notes_db_worker.dart';
import 'notes_model.dart' show Note, NotesModel, notesModel;

class NotesList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: notesModel,
      child: ScopedModelDescendant<NotesModel> (
        builder: (BuildContext context, Widget child, NotesModel model) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                notesModel.entityBeingEdited = Note();
                notesModel.setColor(null);
                notesModel.setStackIndex(1);
              },
            ),
            body: ListView.builder(
              itemCount: notesModel.entityList.length,
              itemBuilder: (BuildContext buildContext, int index) {
                Note note = notesModel.entityList[index];
                Color color = Colors.yellow;
                switch (note.color) {
                  case "red" : color = Colors.red; break;
                  case "green" : color = Colors.green; break;
                  case "blue" : color = Colors.blue; break;
                  case "yellow" : color = Colors.yellow; break;
                  case "grey" : color = Colors.grey; break;
                  case "purple" : color = Colors.purple; break;
                }
                return Container(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Slidable(
                    delegate: SlidableDrawerDelegate(),
                    actionExtentRatio: .25,
                    secondaryActions: <Widget>[
                      IconSlideAction(
                        caption: "Delete",
                        color: Colors.red,
                        icon: Icons.delete,
                        onTap: () => _deleteNote(buildContext, note),
                      ),
                    ],
                    child: Card(
                      elevation: 8,
                      color: color,
                      child: ListTile(
                        title: Text(
                          '${note?.title ?? ''}'
                        ),
                        subtitle: Text(
                          '${note?.content ?? ''}'
                        ),
                        onTap: () async {
                          notesModel.entityBeingEdited = await NotesDBWorker.db.get(note.id);
                          notesModel.setColor(notesModel.entityBeingEdited.color);
                          notesModel.setStackIndex(1);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteNote(BuildContext context, Note inNote) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext alertContext) {
        return AlertDialog(
          title: Text('Delete Note'),
          content: Text(
            'Are you sure you wanna delete ${inNote?.title ?? ''}'
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
                await NotesDBWorker.db.delete(inNote.id);
                Navigator.of(alertContext).pop();
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                    content: Text('Note deleted'),
                  ),
                );
                notesModel.loadData("notes", NotesDBWorker.db);
              },
            ),
          ],
        );
      }
    );
  }

}