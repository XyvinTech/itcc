import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:itcc/src/data/globals.dart';
import 'package:itcc/src/data/models/enquiries_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'get_enquiries.g.dart';

class EnquiriesApiService {
  static final _baseUrl = Uri.parse('$baseUrl/user/enquiry');

  static Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'accept': '*/*',
      };

  /// Fetch Enquiries
  static Future<List<EnquiriesModel>> fetchEnquiries() async {
    try {
      log('Fetching enquiries from: $_baseUrl');
      final response = await http.get(_baseUrl, headers: _headers());

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        List data = jsonResponse['data'];
        return data.map((data) => EnquiriesModel.fromJson(data)).toList();
      } else {
        final decoded = json.decode(response.body);
        throw Exception(decoded['message'] ?? 'Failed to fetch enquiries');
      }
    } catch (e) {
      log('Error fetching enquiries: $e');
      throw Exception('Error: $e');
    }
  }
}

@riverpod
Future<List<EnquiriesModel>> getEnquiries(Ref ref) {
  return EnquiriesApiService.fetchEnquiries();
}
