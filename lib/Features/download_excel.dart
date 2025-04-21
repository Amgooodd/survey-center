import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class expoFileScreen extends StatefulWidget {
  @override
  _UploadFileScreenState createState() => _UploadFileScreenState();
}

class _UploadFileScreenState extends State<expoFileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _exportToExcel() async {
    if (await Permission.storage.request().isDenied) {
      return;
    }

    QuerySnapshot snapshot = await _firestore.collection('students').get();

    var excel = Excel.createExcel();
    Sheet sheet = excel['Students'];

    sheet.appendRow([
      FormulaCellValue("Group"),
      FormulaCellValue("ID"),
      FormulaCellValue("Name"),
    ]);

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      sheet.appendRow([
        data['group'] ?? '',
        data['ID'] ?? '',
        data['name'] ?? '',
      ]);
    }

    final directory = await getExternalStorageDirectory();
    String filePath = "${directory!.path}/students.xlsx";
    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.encode()!);

    _showSuccessMessage('saved to $filePath');
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('downnnn')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _exportToExcel,
              child: Text('Excel'),
            ),
          ],
        ),
      ),
    );
  }
}
