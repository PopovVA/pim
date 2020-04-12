import 'dart:io';

import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import 'base_model.dart';

Directory docsDir;

Future<String> selectDate(
  BuildContext context, 
  BaseModel model,
  String dateString,
) async {
  DateTime initialDate = DateTime.now();
  if (dateString?.isNotEmpty ?? false) {
    List<String> dateParts = dateString.split(',');
    initialDate = DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
    );
  }
  DateTime picked = await showDatePicker(
    context: context,
    firstDate: DateTime(1900), 
    lastDate: DateTime(2100),
    initialDate: initialDate,
  );
  if (picked != null) {
    model.setChosenDate(
      DateFormat.yMMMMd('en_US').format(picked.toLocal())
    );
    return '${picked.year},${picked.month},${picked.day}';
  }
  return null;
}