import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:itcc/src/data/constants/color_constants.dart';
import 'package:itcc/src/data/models/app_version_model.dart';
import 'package:itcc/src/data/models/user_model.dart';
import 'package:itcc/src/data/notifiers/user_notifier.dart';
import 'package:itcc/src/data/services/deep_link_service.dart';
import 'package:itcc/src/data/services/launch_url.dart';
import 'package:itcc/src/data/utils/secure_storage.dart';
import 'package:itcc/src/interface/components/Buttons/primary_button.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itcc/main.dart';
import 'package:itcc/src/data/globals.dart';
import 'package:itcc/src/data/services/getFcmToken.dart';
import 'package:itcc/src/data/services/navgitor_service.dart';

import 'package:flutter_upgrade_version/flutter_upgrade_version.dart';
import 'package:flutter_upgrade_version/models/package_info.dart';
import 'package:itcc/src/interface/screens/main_pages/profile/premium_subscription_flow.dart';

class SplashScreen extends ConsumerStatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool isAppUpdateRequired = false;
  bool hasVersionCheckError = false;
  String errorMessage = '';
  final DeepLinkService _deepLinkService = DeepLinkService();
  @override
  void initState() {
    super.initState();
    checkAppVersion(context).then((_) {
      if (!isAppUpdateRequired && !hasVersionCheckError) {
        initialize();
      }
    });
    getToken();
  }

  Future<void> checkAppVersion(context) async {
    try {
      log('Checking app version...');
      final response = await http.get(Uri.parse('$baseUrl/user/app-version'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final appVersionResponse = AppVersionResponse.fromJson(jsonResponse);
        await checkForUpdate(appVersionResponse, context);
      } else {
        log('Failed to fetch app version: ${response.statusCode}');
        setState(() {
          hasVersionCheckError = true;
          errorMessage = 'Server is down please try again later';
        });
      }
    } catch (e) {
      log('Error checking app version: $e');
      setState(() {
        hasVersionCheckError = true;
        errorMessage =
            'An error occurred while checking for updates. Please try again.';
      });
    }
  }

  Future<void> checkForUpdate(AppVersionResponse response, context) async {
    PackageInfo packageInfo = await PackageManager.getPackageInfo();
    final currentVersion = int.parse(packageInfo.version.split('.').join());
    log('Current version: $currentVersion');
    log('New version: ${response.version}');

    if (currentVersion < response.version && response.force) {
      // Pause initialization and show update dialog
      isAppUpdateRequired = true;
      showUpdateDialog(response, context);
    }
  }

  void showUpdateDialog(AppVersionResponse response, BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Force update requirement
      builder: (context) => AlertDialog(
        title: Text('Update Required'),
        content: Text(response.updateMessage),
        actions: [
          TextButton(
            onPressed: () {
              // Redirect to app store
              launchURL(response.applink);
            },
            child: Text('Update Now'),
          ),
        ],
      ),
    );
  }

  Future<void> retryVersionCheck() async {
    setState(() {
      hasVersionCheckError = false;
      errorMessage = '';
    });
    await checkAppVersion(context);
  }

  Future<void> initialize() async {
    NavigationService navigationService = NavigationService();
    await checktoken();
    Timer(Duration(seconds: 2), () async {
      if (!isAppUpdateRequired) {
        print('Logged in : $LoggedIn');
        if (LoggedIn) {
          // Fetch user data
          final container = ProviderContainer();
          final asyncUser = container.read(userProvider);
          UserModel? user;
          if (asyncUser is AsyncData<UserModel>) {
            user = asyncUser.value;
          } else {
            // fallback: try to refresh and get user
            await container.read(userProvider.notifier).refreshUser();
            final refreshed = container.read(userProvider);
            if (refreshed is AsyncData<UserModel>) {
              user = refreshed.value;
            }
          }
          if (user != null) {
            if (user.status?.toLowerCase() == 'awaiting_payment') {
              navigationService.pushNamedReplacement('MySubscriptionPage');
              return;
            }
            final premiumFlagKey = 'premium_flow_shown_${user.uid}';
            final premiumFlowShown = (await SecureStorage.read(premiumFlagKey)) == 'true';
            if (user.status?.toLowerCase() == 'trial' && !premiumFlowShown) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (_) => PremiumSubscriptionFlow(
                  onComplete: () async {      premium_flow_shown = 'true';
                    await SecureStorage.write(premiumFlagKey, 'true');
                    navigationService.pushNamedReplacement('MainPage');
                  },
                ),
              ));
              return;
            }
          }
          // 3. Normal navigation
          final pendingDeepLink = _deepLinkService.pendingDeepLink;
          if (pendingDeepLink != null) {
            navigationService.pushNamedReplacement('MainPage').then((_) {
              _deepLinkService.handleDeepLink(pendingDeepLink);
              _deepLinkService.clearPendingDeepLink();
            });
          } else {
            navigationService.pushNamedReplacement('MainPage');
          }
        } else {
          navigationService.pushNamedReplacement('PhoneNumber');
        }
      }
    });
  }

  Future<void> checktoken() async {
    String? savedtoken = await SecureStorage.read('token') ?? '';
    String? savedId = await SecureStorage.read('id') ?? '';
    log('token:$savedtoken');
    log('userId:$savedId');
    if (savedtoken != '' && savedtoken.isNotEmpty && savedId != '') {
      setState(() {
        LoggedIn = true;
        token = savedtoken;
        id = savedId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryLightColor,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Image.asset(
              scale: 8,
              'assets/pngs/itcc_logo_group.png',
            ),
          ),
          if (hasVersionCheckError)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 16),
                    // customButton(label: 'Retry', onPressed: retryVersionCheck)
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
