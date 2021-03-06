# Flutter personal information manager (PIM)

[![support](https://img.shields.io/badge/platform-flutter%7Cdart%20vm-ff69b4.svg?style=flat-square)](https://github.com/asjqkkkk/todo-list-app)

Flutter sample project with [Scoped-model architecture](https://pub.dev/packages/scoped_model).

## Dependencies

* [![support](https://img.shields.io/badge/scoped__model-1.0.1-brightgreen?style=flat-square)](https://pub.dev/packages/scoped_model)
* [![support](https://img.shields.io/badge/flutter__calendar__carousel-1.3.15%2B3-brightgreen?style=flat-square)](https://pub.dev/packages/flutter_calendar_carousel/versions/1.3.15+3)
* [![support](https://img.shields.io/badge/sqflite-%5E1.3.0-brightgreen?style=flat-square)](https://pub.dev/packages/sqflite/versions/1.3.0)
* [![support](https://img.shields.io/badge/path__provider-%5E1.6.5-brightgreen?style=flat-square)](https://pub.dev/packages/path_provider/versions/1.6.5)
* [![support](https://img.shields.io/badge/flutter__slidable-0.4.9-brightgreen?style=flat-square)](https://pub.dev/packages/flutter_slidable/versions/0.4.9)
* [![support](https://img.shields.io/badge/intl-0.15.7-brightgreen?style=flat-square)](https://pub.dev/packages/intl/versions/0.15.7)
* [![support](https://img.shields.io/badge/image__picker-%5E0.6.5-brightgreen?style=flat-square)](https://pub.dev/packages/image_picker/versions/0.6.5)


## Project structure

The project has 4 main tabs: **Appointments**, **Contacts**, **Notes**, **Tasks**

<img src="https://raw.githubusercontent.com/PopovVA/repo_images/master/tabs.jpg" height="100">

These components have next file structure:
1. **component.dart** - depending on the changes in the model file, render a new view .
2. **component_db_worker.dart** - initializing database connection and all queries to database.
3. **component_entry.dart** - view for adding and editing values.
4. **component_list.dart** - view with list of data.
5. **component_model.dart** - contains classes for describing data fields.

[Example - contacts component structure](https://github.com/PopovVA/pim/tree/master/lib/screens/contacts)

## Screenshots

<img src="https://raw.githubusercontent.com/PopovVA/repo_images/master/app_calendar.jpg" height="500">
<img src="https://raw.githubusercontent.com/PopovVA/repo_images/master/app_notes.jpg" height="500">
<img src="https://raw.githubusercontent.com/PopovVA/repo_images/master/app_tasks.jpg" height="500">
<img src="https://raw.githubusercontent.com/PopovVA/repo_images/master/edit_note.jpg" height="500">

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
