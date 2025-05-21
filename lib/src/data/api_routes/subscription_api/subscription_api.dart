import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itcc/src/data/globals.dart';
import 'package:itcc/src/data/models/subscription_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;

part 'subscription_api.g.dart';

class SubscriptionApiService {
  static final _baseUrl = Uri.parse('$baseUrl/payment/parent-subscription');

  static Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'accept': '*/*',
      };

  /// Fetch Subscriptions
  static Future<List<SubscriptionModel>> fetchSubscriptions() async {
    try {
      final response = await http.get(_baseUrl, headers: _headers());
      final decoded = json.decode(response.body);

      if (response.statusCode == 200) {
        final List data = decoded['data'];
        return data.map((item) => SubscriptionModel.fromJson(item)).toList();
      } else {
        throw Exception(decoded['message'] ?? 'Failed to fetch subscriptions');
      }
    } catch (e) {
      log('Exception in fetching subscriptions: $e');
      throw Exception('Failed to fetch subscriptions');
    }
  }
}

@riverpod
Future<List<SubscriptionModel>> fetchSubscriptions(Ref ref) {
  return SubscriptionApiService.fetchSubscriptions();
} 