import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import 'contacts_db_worker.dart';
import 'contacts_list.dart';
import 'contacts_entry.dart';
import 'contacts_model.dart' show ContactsModel , contactsModel;

class Contacts extends StatelessWidget {

  Notes() {
    contactsModel.loadData('contacts', ContactsDBWorker.db);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: contactsModel,
      child: ScopedModelDescendant<ContactsModel>(
        builder: (BuildContext inContext, Widget child, ContactsModel model) {
          return IndexedStack(
            index: model.stackIndex,
            children: <Widget>[
              ContactsList(), 
              ContactsEntry(),
            ],
          );
        },
      ),
    );
  }

}
