import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:itcc/src/data/services/snackbar_service.dart';
import 'package:http/http.dart' as http;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:itcc/src/data/globals.dart';

Future<Map<String, String>> submitPhoneNumber(
    String countryCode, BuildContext context, String phone) async {
  FirebaseAuth auth = FirebaseAuth.instance;
  Completer<String> verificationIdcompleter = Completer<String>();
  Completer<String> resendTokencompleter = Completer<String>();
  log('phone:+$countryCode$phone');
  await auth.verifyPhoneNumber(
    phoneNumber: '+$countryCode$phone',
    verificationCompleted: (PhoneAuthCredential credential) async {
      // Handle automatic verification completion if needed
    },
    verificationFailed: (FirebaseAuthException e) {
      print(e.message.toString());
      verificationIdcompleter.complete(''); // Verification failed
      resendTokencompleter.complete('');
    },
    codeSent: (String verificationId, int? resendToken) {
      log(verificationId);

      verificationIdcompleter.complete(verificationId);
      resendTokencompleter.complete(resendToken.toString());
    },
    codeAutoRetrievalTimeout: (String verificationID) {
      if (!verificationIdcompleter.isCompleted) {
        verificationIdcompleter.complete(''); 
      }
    },
  );

  return {
    "verificationId": await verificationIdcompleter.future,
    "resendToken": await resendTokencompleter.future
  };
}

void resendOTP(String phoneNumber, String verificationId, String resendToken) {
  FirebaseAuth auth = FirebaseAuth.instance;
  auth.verifyPhoneNumber(
    phoneNumber: '+91$phoneNumber',
    forceResendingToken: int.parse(resendToken),
    timeout: const Duration(seconds: 60),
    verificationCompleted: (PhoneAuthCredential credential) {
      // Auto-retrieval or instant verification
    },
    verificationFailed: (FirebaseAuthException e) {
      // Handle error
      print("Resend verification failed: ${e.message}");
    },
    codeSent: (String verificationId, int? resendToken) {
      resendToken = resendToken;
      print("Resend verification Sucess");
    },
    codeAutoRetrievalTimeout: (String verificationId) {
      verificationId = verificationId;
    },
  );
}

Future<Map<String, dynamic>> verifyOTP(
    {required String verificationId,
    required String fcmToken,
    required String smsCode,
    required BuildContext context}) async {
  SnackbarService snackbarService = SnackbarService();
  FirebaseAuth auth = FirebaseAuth.instance;
  PhoneAuthCredential credential = PhoneAuthProvider.credential(
    verificationId: verificationId,
    smsCode: smsCode,
  );

  try {
    UserCredential userCredential = await auth.signInWithCredential(credential);
    User? user = userCredential.user;
    if (user != null) {
      String? idToken = await user.getIdToken();
      log("ID Token: $idToken");
      log("fcm token:$fcmToken");
      log("Verification ID:$verificationId");
      final Map<String, dynamic> tokenMap =
          await verifyUserDB(idToken!, fcmToken, context);
      log(tokenMap.toString());
      return tokenMap;
    } else {
      print("User signed in, but no user information was found.");
      return {};
    }
  } catch (e) {
    snackbarService.showSnackBar('Wrong OTP');
    print("Failed to sign in: ${e.toString()}");
    return {};
  }
}
Future<Map<String, dynamic>> verifyUserDB(
    String idToken, String fcmToken, BuildContext context) async {
  SnackbarService snackbarService = SnackbarService();

  final Uri url = Uri.parse('$baseUrl/user/login');
  final Map<String, String> headers = {"Content-Type": "application/json"};
  final Map<String, dynamic> body = {"clientToken": idToken, "fcm": fcmToken};

  try {
    log('Sending POST request to $url', name: 'VERIFY_USER_DB');
    log('Request headers: $headers', name: 'VERIFY_USER_DB');
    log('Request body: ${jsonEncode(body)}', name: 'VERIFY_USER_DB');

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    log('Received response: ${response.statusCode}', name: 'VERIFY_USER_DB');

    final Map<String, dynamic> responseBody = jsonDecode(response.body);
    log('Response body: $responseBody', name: 'VERIFY_USER_DB');

    if (response.statusCode == 200) {
      snackbarService.showSnackBar(responseBody['message'] ?? 'Login successful');
      return responseBody['data'] ?? {};
    } else if (response.statusCode == 400) {
      snackbarService.showSnackBar(responseBody['message'] ?? 'Invalid request');
      return {};
    } else {
      snackbarService.showSnackBar(responseBody['message'] ?? 'Something went wrong');
      return {};
    }
  } catch (e, stackTrace) {
    log('Exception during verifyUserDB: $e', name: 'VERIFY_USER_DB', error: e, stackTrace: stackTrace);
    snackbarService.showSnackBar('Unexpected error occurred. Please try again.');
    return {};
  }
}
