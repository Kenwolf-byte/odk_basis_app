import 'package:flutter/material.dart';

import 'package:odk_basis_app/login_page.dart';

void main() => runApp(const ODKApp());

class ODKApp extends StatelessWidget {
  const ODKApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ODK Central Integration',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
    );
  }
}
