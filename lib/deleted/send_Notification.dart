/*import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> sendNotificationToDepartments(
    List<String> departments, String surveyName) async {
  // Replace with your Firebase Cloud Messaging server key from Firebase Console
  const String serverKey = 'YOUR_SERVER_KEY';
  const String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

  final Map<String, dynamic> notification = {
    'title': 'New Survey Available',
    'body': 'A new survey "$surveyName" has been added for your department!',
    'sound': 'default'
  };

  final Map<String, dynamic> data = {
    'click_action': 'FLUTTER_NOTIFICATION_CLICK',
    'survey_name': surveyName,
    'type': 'new_survey'
  };

  try {
    for (String department in departments) {
      final Map<String, dynamic> body = {
        'to': '/topics/$department',
        'notification': notification,
        'data': data,
        'priority': 'high',
      };

      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        print('✅ Successfully sent notification to $department department');
      } else {
        print('❌ Failed to send notification to $department: ${response.body}');
      }
    }
  } catch (e) {
    print('❌ Error sending notification: $e');
  }
}
*/
