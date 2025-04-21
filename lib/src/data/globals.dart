library data;
import 'package:flutter_dotenv/flutter_dotenv.dart';

String token = '';
bool LoggedIn = false;
String id = '';
String premium_flow_shown= 'true';
String fcmToken = '';
final String baseUrl = dotenv.env['BASE_URL'] ?? '';
String subscriptionType = 'free';
