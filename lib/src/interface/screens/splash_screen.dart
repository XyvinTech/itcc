import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:itcc/src/data/constants/color_constants.dart';
import 'package:itcc/src/data/models/app_version_model.dart';
import 'package:itcc/src/data/models/user_model.dart';
import 'package:itcc/src/data/notifiers/user_notifier.dart';
import 'package:itcc/src/data/services/deep_link_service.dart';
import 'package:itcc/src/data/services/launch_url.dart';
import 'package:itcc/src/data/utils/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itcc/src/data/globals.dart';
import 'package:itcc/src/data/services/getFcmToken.dart';
import 'package:itcc/src/data/services/navgitor_service.dart';
import 'package:flutter_upgrade_version/flutter_upgrade_version.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends ConsumerStatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool isAppUpdateRequired = false;
  bool hasVersionCheckError = false;
  String errorMessage = '';

  bool isPermissionCheckComplete = false;

  // Add a flag to track first launch
  String isFirstLaunch = 'false';

  @override
  void initState() {
    super.initState();
    checkFirstLaunch().then((_) {
      handlePermissions();
    });
  }

  Future<void> checkFirstLaunch() async {
    isFirstLaunch = await SecureStorage.read('has_launched_before') ?? 'false';
    if (isFirstLaunch == 'true') {
      await SecureStorage.write('has_launched_before', 'true');
    }
  }

  Future<void> handlePermissions() async {
    if (isFirstLaunch == 'true') {
      // For first launch, directly request permission using the system dialog
      await getToken();
      setState(() {
        isPermissionCheckComplete = true;
      });
      proceedWithAppFlow();
    } else {
      // For subsequent launches, check status first
      final status = await Permission.notification.status;
      if (status.isGranted) {
        await getToken();
        setState(() {
          isPermissionCheckComplete = true;
        });
        proceedWithAppFlow();
      } else if (status.isPermanentlyDenied) {
        // Show custom dialog if permission was permanently denied
        if (mounted) {
          await showPermissionDialog();
        }
      } else {
        // For other cases (like first denial), try system dialog again
        await getToken();
        setState(() {
          isPermissionCheckComplete = true;
        });
        proceedWithAppFlow();
      }
    }
  }

  void proceedWithAppFlow() {
    checkAppVersion(context).then((_) {
      if (!isAppUpdateRequired) {
        initialize();
      }
    });
  }

  Future<void> showPermissionDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon at the top
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: Colors.blue.shade700,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                "Enable Notifications",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
              ),
              const SizedBox(height: 12),

              // Content
              Text(
                "Would you like to enable notifications to stay updated with important information?",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);

                        setState(() {
                          isPermissionCheckComplete = true;
                        });

                        proceedWithAppFlow();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Color(0xFF004797)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Skip",
                        style: TextStyle(color: Color(0xFF004797)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await openAppSettings();

                        final newStatus = await Permission.notification.status;
                        if (newStatus.isGranted) {
                          await getToken();
                        }

                        setState(() {
                          isPermissionCheckComplete = true;
                        });

                        proceedWithAppFlow();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Color(0xFF004797),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Enable"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
    final deepLinkService = ref.watch(deepLinkServiceProvider);
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
          }
          // 3. Normal navigation
          final pendingDeepLink = deepLinkService.pendingDeepLink;
          if (pendingDeepLink != null) {
            navigationService.pushNamedReplacement('MainPage').then((_) {
              deepLinkService.handleDeepLink(pendingDeepLink);
              deepLinkService.clearPendingDeepLink();
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
