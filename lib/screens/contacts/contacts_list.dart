import 'dart:io';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:path/path.dart';

import 'package:pim/utils.dart' as utils;

import 'contacts_db_worker.dart';
import 'contacts_model.dart' show Contact, ContactsModel, contactsModel;

class ContactsList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ContactsModel>(
      model: contactsModel,
      child: ScopedModelDescendant<ContactsModel>(
        builder: (BuildContext inContext, Widget child, ContactsModel model) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(
                Icons.add,
                color: Colors.white,
                ),
              onPressed: () async {
                File avatarFile = File(
                  join(utils.docsDir.path,"avatar")
                );
                contactsModel.entityBeingEdited = Contact();
                contactsModel.setChosenDate(null);
                contactsModel.setStackIndex(1);
              },
            ),
            body: ListView.builder(
              itemCount: contactsModel.entityList.length,
              itemBuilder: (BuildContext inContext, int inIndex) {
                Contact contact = contactsModel.entityList[inIndex];
                File avatarFile = File(join(utils.docsDir.path, contact.id.toString()));
                bool avatarFileExists = avatarFile.existsSync();
                return Column(
                  children: <Widget>[
                    Slidable(
                      delegate: SlidableDrawerDelegate(),
                      actionExtentRatio: .25,
                      secondaryActions: <Widget>[
                        IconSlideAction(
                          icon: Icons.delete,
                          caption: "Delete",
                          color: Colors.red,
                          onTap: () => _deleteContact(inContext, contact),
                        ),
                      ],
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigoAccent,
                          foregroundColor: Colors.white,
                          backgroundImage: avatarFileExists ?
                            FileImage(avatarFile) : null,
                          child: avatarFileExists ? null :
                            Text(
                              contact.name.substring(0, 1).toUpperCase(),
                            ),
                        ),
                        title: Text(
                          "${contact.name}"
                        ),
                        subtitle: contact.phone == null ?
                        null : Text(
                          "${contact.phone}"
                        ),  
                        onTap: () async {
                          File avatarFile = File(join(utils.docsDir.path, "avatar"));
                          if (avatarFile.existsSync()) {
                            avatarFile.deleteSync();
                          }
                          contactsModel.entityBeingEdited = await ContactsDBWorker.db.get(contact.id);
                          if (contactsModel.entityBeingEdited.birthday == null) {
                            contactsModel.setChosenDate(null);
                          } else {
                            List dateParts = contactsModel.entityBeingEdited.birthday.split(',');
                            DateTime birthday = DateTime(
                              int.parse(dateParts[0]),
                              int.parse(dateParts[1]),
                              int.parse(dateParts[2]),
                            );
                            contactsModel.setChosenDate(
                              DateFormat.yMMMMd("en_US").format(birthday.toLocal()),
                            );
                          }
                          contactsModel.setStackIndex(1);
                        },
                      ),
                    ),
                    Divider(),
                  ]
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteContact(BuildContext context, Contact inContact) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext alertContext) {
        return AlertDialog(
          title: Text('Delete contact'),
          content: Text(
            'Are you sure you wanna delete ${inContact?.name ?? ''}'
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
                File avatarFile = File(
                  join(utils.docsDir.path, inContact.id.toString())
                );
                if (avatarFile.existsSync()) {
                  avatarFile.deleteSync();
                }
                await ContactsDBWorker.db.delete(inContact.id);
                Navigator.of(alertContext).pop();
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                    content: Text('Contact deleted'),
                  ),
                );
                contactsModel.loadData("contacts", ContactsDBWorker.db);
              },
            ),
          ],
        );
      }
    );
  }

}
