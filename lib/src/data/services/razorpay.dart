import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:itcc/src/data/api_routes/user_api/user_data/user_data.dart';
import 'package:itcc/src/data/constants/color_constants.dart';
import 'package:itcc/src/data/globals.dart';
import 'package:itcc/src/data/notifiers/user_notifier.dart';
import 'package:itcc/src/data/services/snackbar_service.dart';
import 'package:itcc/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayScreen extends ConsumerStatefulWidget {
  final double amount;
  final String category;

  const RazorpayScreen({
    super.key,
    required this.amount,
    required this.category,
  });

  @override
  ConsumerState<RazorpayScreen> createState() => _RazorpayScreenState();
}

class _RazorpayScreenState extends ConsumerState<RazorpayScreen> {
  late Razorpay _razorpay;
  SnackbarService snackbarService = SnackbarService();
  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    initiatePayment();
  }

  String? payment_id;
  void initiatePayment() async {
    final url = Uri.parse('$baseUrl/payment/make-payment');
    log('requesting url:$url');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'amount': widget.amount,
        'category': widget.category,
      }),
    );

    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final payment = responseData['data'];
      payment_id = payment['_id'];
      var options = {
        'key': dotenv.env['RZP_KEY'] ?? '',
        'amount': widget.amount,
        'currency': 'INR',
        'name': 'ITCC CONNECT',
        'description': 'Payment for ${widget.category}',
        'order_id': payment['gatewayId'],
        // 'external': {
        //   'wallets': ['paytm', 'phonepe', 'amazonpay']
        // }
        // 'prefill': {
        //   'contact': '1234567890',
        //   'email': 'test@example.com',
        // }
      };

      try {
        _razorpay.open(options);
      } catch (e) {
        debugPrint('Error: $e');
      }
    } else {
      log(response.body);
      snackbarService.showSnackBar('Error: ${responseData['message']}');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    log("SUCCESS RESPONSE:${response.data}");
    final callbackUrl =
        Uri.parse('$baseUrl/payment/razorpay-callback?paymentId=$payment_id');
    final callbackResponse = await http.post(
      callbackUrl,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'razorpayPaymentId': response.paymentId,
        'razorpayOrderId': response.orderId,
        'razorpaySignature': response.signature,
      }),
    );

    final responseData = jsonDecode(callbackResponse.body);

    if (callbackResponse.statusCode == 200) {
      snackbarService
          .showSnackBar('Payment success: ${responseData['message']}');
      Navigator.pop(context, true);
      ref.invalidate(getUserSubscriptionProvider);
      ref.read(userProvider.notifier).refreshUser();
    } else {
      log(responseData.toString());
      snackbarService.showSnackBar(
          'Payment verification failed: ${responseData['message']}');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    snackbarService.showSnackBar('Payment Failed');
    log("PAYMENT ERROR:${response.message}");
    Navigator.pop(context, false);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet: ${response.walletName}')),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: kPrimaryLightColor,
      body: Center(child: LoadingAnimation()),
    );
  }
}
