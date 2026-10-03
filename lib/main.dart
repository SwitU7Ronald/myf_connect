import 'package:flutter/material.dart';
import 'package:myf_connect/core/bootstrap/bootstrapper.dart';
import 'package:myf_connect/core/app.dart';

void main() async {
  await Bootstrapper.init();
  runApp(const MYFConnectApp());
}
