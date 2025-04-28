import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class SurveyExporter {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> exportSurveyResponses(String surveyId) async {
    // 1. Load survey questions
    final surveyDoc =
        await _firestore.collection('surveys').doc(surveyId).get();
    final surveyData = surveyDoc.data() as Map<String, dynamic>;
    final surveyName = surveyData['name'] ?? 'Unnamed_Survey';
    // Remove special characters from survey name to make it file-system friendly
    final safeFileName =
        surveyName.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');

    final questions = List<Map<String, dynamic>>.from(surveyDoc['questions']);
    final questionTitles = questions.map((q) => q['title'].toString()).toList();

    // 2. Load student responses
    final responsesSnapshot = await _firestore
        .collection('students_responses')
        .where('surveyId', isEqualTo: surveyId)
        .get();

    // 3. Prepare workbook and worksheet
    final workbook = xlsio.Workbook();
    final sheet = workbook.worksheets[0];

    // 4. Prepare headers
    final headers = [
      'Student ID',
      'Student Name',
      'Student Group',
      ...questionTitles
    ];
    sheet.importList(headers, 1, 1, false); // row 1

    // 5. Fill responses
    int rowIndex = 2; // Excel rows are 1-indexed
    for (var doc in responsesSnapshot.docs) {
      final data = doc.data();
      final studentId = data['studentId'].toString();

      // Fetch student name and group from students collection
      final studentDoc =
          await _firestore.collection('students').doc(studentId).get();
      final studentData = studentDoc.data();
      final studentName = studentDoc.exists && studentData != null
          ? studentData['name'].toString()
          : 'Unknown';
      final studentGroup = studentDoc.exists && studentData != null
          ? studentData['group'].toString()
          : 'Unknown';

      final answers = Map<String, dynamic>.from(data['answers']);
      final row = [
        studentId,
        studentName,
        studentGroup,
        ...questionTitles.map((q) => answers[q]?.toString() ?? '')
      ];
      sheet.importList(row, rowIndex, 1, false);
      rowIndex++;
    }

    // 6. Allow the user to pick a location to save the file
    String? directoryPath = await FilePicker.platform.getDirectoryPath();

    String? savePath;

    if (directoryPath != null) {
      savePath = '$directoryPath/$safeFileName.xlsx';
    } else {
      final dir = await getExternalStorageDirectory();
      savePath = '${dir!.path}/$safeFileName.xlsx';
    }

    // 3. Now save
    final file = File(savePath);
    final bytes = workbook.saveAsStream();
    workbook.dispose();
    await file.writeAsBytes(bytes, flush: true);

    print('✅ Excel file saved at: ${file.path}');
  }
}
