import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'utils/app_routes.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Survey App',
      initialRoute: '/',
      routes: AppRoutes.routes,
    );
  }
}

class ExportToExcelButton extends StatelessWidget {
  const ExportToExcelButton({super.key});

  Future<void> exportDataToExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Survey Data'];

    // إضافة عناوين الأعمدة
    sheetObject.appendRow([
      TextCellValue("Collection"),
      TextCellValue("Document ID"),
      TextCellValue("Field"),
      TextCellValue("Value")
    ]);

    // 🟢 جلب جميع البيانات من Firestore
    await fetchAndAppendCollection("admins", sheetObject);
    await fetchAndAppendCollection("students", sheetObject);
    await fetchAndAppendCollection("students_responses", sheetObject);
    await fetchAndAppendCollection("surveys", sheetObject);

    // 🔹 حفظ الملف في الهاتف
    if (await _requestPermission()) {
      Directory? directory = await getExternalStorageDirectory();
      String filePath = "${directory!.path}/firestore_data.xlsx";

      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      print("✅ تم حفظ الملف في: $filePath");
    } else {
      print("❌ لم يتم منح الإذن لحفظ الملف.");
    }
  }

  // 🔹 دالة لجلب بيانات مجموعة معينة وإضافتها إلى ملف Excel
  Future<void> fetchAndAppendCollection(
      String collectionName, Sheet sheet) async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection(collectionName).get();

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>?;

      if (data != null && data.isNotEmpty) {
        data.forEach((key, value) {
          sheet.appendRow([
            TextCellValue(collectionName),
            TextCellValue(doc.id),
            TextCellValue(key),
            TextCellValue(value.toString())
          ]);
        });
      } else {
        sheet.appendRow([
          TextCellValue(collectionName),
          TextCellValue(doc.id),
          TextCellValue("No Data"),
          TextCellValue("")
        ]);
      }
    }
  }

  // 🔹 طلب إذن الوصول إلى التخزين
  Future<bool> _requestPermission() async {
    var status = await Permission.storage.request();
    return status.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await exportDataToExcel();
      },
      child: Text("📥 تحميل البيانات إلى Excel"),
    );
  }
}
