import 'dart:io';

import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';

import 'utils.dart' as utils;
import 'pim.dart';

void main() {

  Future<void> startMeUp() async {
    Directory docsDir = await getApplicationDocumentsDirectory();
    utils.docsDir = docsDir;
    runApp(PIM());
  }
  WidgetsFlutterBinding.ensureInitialized();
  startMeUp();
}
