import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:path/path.dart';
import 'package:pim/utils.dart' as utils;

import 'contacts_db_worker.dart';
import 'contacts_model.dart' show ContactsModel, contactsModel;

class ContactsEntry extends StatelessWidget {

  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _phoneEditController = TextEditingController();
  final TextEditingController _emailEditController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _emailEditController.text = contactsModel?.entityBeingEdited?.email ?? '';
    _phoneEditController.text = contactsModel?.entityBeingEdited?.phone ?? '';
    _nameEditingController.text = contactsModel?.entityBeingEdited?.name ?? '';
    return ScopedModel(
      model: contactsModel,
      child: ScopedModelDescendant<ContactsModel>(
        builder: (BuildContext inContext, Widget child, ContactsModel model) {
          File avatarFile = File(join(utils.docsDir.path, "avatar"));
          if (avatarFile.existsSync() == false) {
            if (model.entityBeingEdited != null && model.entityBeingEdited.id != null) {
              avatarFile = File(
                join(utils.docsDir.path, model.entityBeingEdited.id.toString())
              );
            }
          }
          return Scaffold(
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: Row(
                children: <Widget>[
                  FlatButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      File avatarFile = File(
                        join(utils.docsDir.path, "avatar")
                      );
                      if (avatarFile.existsSync()) {
                        avatarFile.deleteSync();
                      }
                      FocusScope.of(inContext).requestFocus(FocusNode());
                      model.setStackIndex(0);
                    },
                  ),
                  Spacer(),
                  FlatButton(
                    child: Text('Save'),
                    onPressed: () {
                      _save(inContext, contactsModel);
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
                    leading: Icon(Icons.image),
                    title: avatarFile.existsSync() ? Image.file(avatarFile) : Text(
                      "No avatar image for this contact"
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () => _selectAvatar(inContext),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: TextFormField(
                      decoration: InputDecoration(
                        hintText:  "Name"
                      ),
                      controller: _nameEditingController,
                      validator: (String inValue) {
                        if (inValue?.isNotEmpty ?? false) {
                          return "Please enter a name";
                        }
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.phone
                    ),
                    title: TextFormField(
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: "Phone"
                      ),
                      controller: _phoneEditController,
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.email
                    ),
                    title: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Email"
                      ),
                      controller: _emailEditController,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.today),
                    title: Text("Birthday"),
                    subtitle: Text(
                      contactsModel.chosenDate == null ?
                      "" : contactsModel.chosenDate
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () async {
                        String chosenDate = await utils.selectDate(
                          inContext, 
                          model, 
                          contactsModel.entityBeingEdited.birthday,
                        );
                        if (chosenDate != null) {
                          contactsModel.entityBeingEdited.birthday = chosenDate;
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

  Future<void> _selectAvatar(BuildContext inContext) {
    return showDialog(
      context: inContext,
      builder: (BuildContext inBuildContext) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text("Take a picture"),
                  onTap: () async {
                    var cameraImage = await ImagePicker.pickImage(
                      source: ImageSource.camera
                    );
                    if (cameraImage != null) {
                      cameraImage.copySync(
                        join(utils.docsDir.path, "avatar")
                      );
                      contactsModel.triggerRebuild();
                    }
                    Navigator.of(inBuildContext).pop();
                  },
                ),
                Divider(
                  height: 25,
                ),
                GestureDetector(
                  child: Text("Select from Gallery"),
                  onTap: () async {
                    var galleryImage = await ImagePicker.pickImage(
                      source: ImageSource.gallery
                    );
                    if (galleryImage != null) {
                      galleryImage.copySync(
                        join(utils.docsDir.path, "avatar")
                      );
                      contactsModel.triggerRebuild();
                    }
                    Navigator.of(inBuildContext).pop();
                  },
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  void _save(BuildContext inContext, ContactsModel inModel) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    var id;

    if (inModel.entityBeingEdited.id == null) {

      id = await ContactsDBWorker.db.create(contactsModel.entityBeingEdited);

    } else {

      id = contactsModel.entityBeingEdited.id;
      await ContactsDBWorker.db.update(contactsModel.entityBeingEdited);

    }

    // If there is an avatar file, rename it using the ID.
    File avatarFile = File(join(utils.docsDir.path, "avatar"));
    if (avatarFile.existsSync()) {
      print("## ContactsEntry._save(): Renaming avatar file to id = $id");
      avatarFile.renameSync(join(utils.docsDir.path, id.toString()));
    }
    contactsModel.loadData("contacts", ContactsDBWorker.db);
    inModel.setStackIndex(0);
    Scaffold.of(inContext).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text("Contact saved"),
      ),
    );
  }

}