import 'dart:async';
import 'dart:developer';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itcc/src/data/api_routes/user_api/admin/admin_activities_api.dart';
import 'package:itcc/src/data/api_routes/user_api/login/user_login_api.dart';
import 'package:itcc/src/data/api_routes/user_api/user_data/edit_user.dart';
import 'package:itcc/src/data/api_routes/user_api/user_data/user_data.dart';
import 'package:itcc/src/data/constants/color_constants.dart';
import 'package:itcc/src/data/constants/style_constants.dart';
import 'package:itcc/src/data/globals.dart';
import 'package:itcc/src/data/notifiers/user_notifier.dart';
import 'package:itcc/src/data/services/navgitor_service.dart';
import 'package:itcc/src/data/services/snackbar_service.dart';
import 'package:itcc/src/data/utils/secure_storage.dart';
import 'package:itcc/src/interface/components/Buttons/primary_button.dart';

import 'package:itcc/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:itcc/src/interface/screens/main_page.dart';
import 'package:itcc/src/interface/screens/main_pages/profile/editUser.dart';
import 'package:itcc/src/interface/screens/main_pages/eula_agreement_screen.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itcc/src/data/notifiers/loading_notifier.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

TextEditingController _mobileController = TextEditingController();
TextEditingController _otpController = TextEditingController();

final countryCodeProvider = StateProvider<String?>((ref) => '91');

class PhoneNumberScreen extends ConsumerWidget {
  const PhoneNumberScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(loadingProvider);
    final countryCode = ref.watch(countryCodeProvider);

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kPrimaryLightColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const SizedBox(height: 80),
              Text(
                'Login',
                style: kHeadTitleB.copyWith(color: kPrimaryColor),
              ),
              SizedBox(
                height: 40,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: bottomInset),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Please enter your mobile number',
                            style: kBodyTitleL),
                        const SizedBox(height: 20),
                        IntlPhoneField(
                          validator: (phone) {
                            if (phone!.number.length > 9) {
                              if (phone.number.length > 10) {
                                return 'Phone number cannot exceed 10 digits';
                              }
                            }
                            return null;
                          },
                          style: const TextStyle(
                            letterSpacing: 8,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                          controller: _mobileController,
                          disableLengthCheck: true,
                          showCountryFlag: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: kWhite,
                            hintText: 'Enter your phone number',
                            hintStyle: const TextStyle(
                              letterSpacing: 2,
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: kGrey),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: kGrey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(color: kGrey),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 10.0,
                            ),
                          ),
                          onCountryChanged: (value) {
                            ref.read(countryCodeProvider.notifier).state =
                                value.dialCode;
                          },
                          initialCountryCode: 'IN',
                          onChanged: (PhoneNumber phone) {
                            print(phone.completeNumber);
                          },
                          flagsButtonPadding:
                              const EdgeInsets.only(left: 10, right: 10.0),
                          showDropdownIcon: true,
                          dropdownIconPosition: IconPosition.trailing,
                          dropdownTextStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text('A 6 digit verification code will be sent',
                            style: kSmallTitleR),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 5, right: 5, top: 10),
                          child: SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: customButton(
                              label: 'Send OTP',
                              onPressed: isLoading
                                  ? null
                                  : () => _handleOtpGeneration(context, ref),
                              fontSize: 16,
                              isLoading: isLoading,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleOtpGeneration(BuildContext context, WidgetRef ref) async {
    SnackbarService snackbarService = SnackbarService();
    final countryCode = ref.watch(countryCodeProvider);
    FocusScope.of(context).unfocus();
    ref.read(loadingProvider.notifier).startLoading();

    try {
      if (countryCode == '971') {
        if (_mobileController.text.length != 9) {
          snackbarService.showSnackBar('Please Enter valid mobile number');
        } else {
          final data = await submitPhoneNumber(
              countryCode == '971'
                  ? 9710.toString()
                  : countryCode ?? 91.toString(),
              context,
              _mobileController.text);
          final verificationId = data['verificationId'];
          final resendToken = data['resendToken'];
          if (verificationId != null && verificationId.isNotEmpty) {
            log('Otp Sent successfully');

            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => OTPScreen(
                phone: _mobileController.text,
                verificationId: verificationId,
                resendToken: resendToken ?? '',
              ),
            ));
          } else {
            snackbarService.showSnackBar('Failed');
          }
        }
      } else if (countryCode != '971') {
        if (_mobileController.text.length != 10) {
          snackbarService.showSnackBar('Please Enter valid mobile number');
        } else {
          final data = await submitPhoneNumber(
              countryCode == '971'
                  ? 9710.toString()
                  : countryCode ?? 971.toString(),
              context,
              _mobileController.text);
          final verificationId = data['verificationId'];
          final resendToken = data['resendToken'];
          if (verificationId != null && verificationId.isNotEmpty) {
            log('Otp Sent successfully');

            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => OTPScreen(
                phone: _mobileController.text,
                verificationId: verificationId,
                resendToken: resendToken ?? '',
              ),
            ));
          } else {
            snackbarService.showSnackBar('Failed');
          }
        }
      }
    } catch (e) {
      log(e.toString());
      snackbarService.showSnackBar('Failed');
    } finally {
      ref.read(loadingProvider.notifier).stopLoading();
    }
  }
}

class OTPScreen extends ConsumerStatefulWidget {
  final String verificationId;
  final String resendToken;
  final String phone;
  const OTPScreen({
    required this.phone,
    required this.resendToken,
    super.key,
    required this.verificationId,
  });

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  Timer? _timer;

  int _start = 59;

  bool _isButtonDisabled = true;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _isButtonDisabled = true;
    _start = 59;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _isButtonDisabled = false;
        });
        timer.cancel();
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void resendCode() {
    startTimer();

    resendOTP(widget.phone, widget.verificationId, widget.resendToken);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kPrimaryLightColor,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const SizedBox(height: 80),
            Text(
              'Verify OTP',
              style: kHeadTitleB.copyWith(color: kPrimaryColor),
            ),
            SizedBox(
              height: 40,
            ),
            Text('Enter the OTP to verify',
                style: kSmallerTitleEL.copyWith(fontSize: 20)),
            const SizedBox(height: 5),
            PinCodeTextField(
              appContext: context,
              length: 6, // Number of OTP digits
              obscureText: false,
              keyboardType: TextInputType.number, // Number-only keyboard
              animationType: AnimationType.fade,
              textStyle: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w300,
                letterSpacing: 5.0,
              ),
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(5),
                fieldHeight: 55,
                fieldWidth: 50, selectedColor: kPrimaryColor,
                activeColor: const Color.fromARGB(255, 232, 226, 226),
                inactiveColor: kWhite,
                activeFillColor: kWhite, // Box color when focused
                selectedFillColor: kWhite, // Box color when selected
                inactiveFillColor: kWhite, // Box fill color when not selected
              ),
              animationDuration: const Duration(milliseconds: 300),
              backgroundColor: Colors.transparent,
              enableActiveFill: true,
              controller: _otpController,
              onChanged: (value) {
                // Handle input change
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                    _isButtonDisabled
                        ? 'Resend OTP in $_start seconds'
                        : 'Enter your OTP',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: _isButtonDisabled ? kGrey : kBlack),
                  ),
                ),
                GestureDetector(
                  onTap: _isButtonDisabled ? null : resendCode,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Text(
                      _isButtonDisabled ? '' : 'Resend Code',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: _isButtonDisabled ? kGrey : kRed),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: SizedBox(
                height: 47,
                width: double.infinity,
                child: customButton(
                  label: 'Verify',
                  onPressed: isLoading
                      ? null
                      : () => _handleOtpVerification(context, ref),
                  fontSize: 16,
                  isLoading: isLoading,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleOtpVerification(
      BuildContext context, WidgetRef ref) async {
    ref.read(loadingProvider.notifier).startLoading();

    try {
      print(_otpController.text);

      Map<String, dynamic> responseMap = await verifyOTP(
          verificationId: widget.verificationId,
          fcmToken: fcmToken,
          smsCode: _otpController.text,
          context: context);

      String savedToken = responseMap['token'];
      String savedId = responseMap['userId'];

      if (savedToken.isNotEmpty && savedId.isNotEmpty) {
        await SecureStorage.write('token', savedToken);
        await SecureStorage.write('id', savedId);
        token = savedToken;
        id = savedId;
        log('savedToken: $savedToken');
        log('savedId: $savedId');
        await ref.read(userProvider.notifier).refreshUser();
        final asyncUser = ref.watch(userProvider);
        await asyncUser.when(
          data: (user) async {
            if (user.name == null || user.name!.trim().isEmpty) {
              String? enteredName = await showDialog<String>(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  final TextEditingController nameController =
                      TextEditingController();
                  return Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      backgroundColor: kWhite,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 28),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Complete Your Profile',
                                  style: kDisplayTitleSB.copyWith(
                                      fontSize: 22, color: kPrimaryColor),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Please enter your full name to continue.',
                                  style:
                                      TextStyle(fontSize: 16, color: kGreyDark),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                TextField(
                                  controller: nameController,
                                  decoration: InputDecoration(
                                    hintText: 'Full Name',
                                    filled: true,
                                    fillColor: kPrimaryLightColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: kPrimaryColor, width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: kPrimaryColor, width: 2),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                  ),
                                  style: kDisplayTitleM.copyWith(
                                      fontSize: 16, color: kBlack),
                                ),
                                const SizedBox(height: 24),
                                customButton(
                                  label: 'Continue',
                                  onPressed: () {
                                    if (nameController.text.trim().isNotEmpty) {
                                      Navigator.of(context)
                                          .pop(nameController.text.trim());
                                    }
                                  },
                                  buttonColor: kPrimaryColor,
                                  fontSize: 18,
                                ),
                              ])));
                },
              );
              if (enteredName != null && enteredName.isNotEmpty) {
                await asyncUser.when(
                  data: (user) async {
                    if (user != null) {
                      final countryCode = ref.watch(countryCodeProvider);

                      await editUser({
                        'name': enteredName,
                        "phone": '+$countryCode${widget.phone}'
                      });
                      ref
                          .read(userProvider.notifier)
                          .updateName(name: enteredName);
                      // Optionally, refresh user info again
                      await ref.read(userProvider.notifier).refreshUser();
                      // Navigate to EULA agreement after name entry
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const EulaAgreementScreen(),
                      ));
                    }
                  },
                  error: (error, _) {
                    // Handle error
                  },
                  loading: () {
                    // Handle loading
                  },
                );
              }
            } else {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const EulaAgreementScreen()));
            }
          },
          error: (error, _) {
            // Handle error
          },
          loading: () {
            // Handle loading
          },
        );
      } else {
        // CustomSnackbar.showSnackbar(context, 'Wrong OTP');
      }
    } catch (e) {
      log(e.toString());
      // CustomSnackbar.showSnackbar(context, 'Wrong OTP');
    } finally {
      ref.read(loadingProvider.notifier).stopLoading();
    }
  }
}

class ProfileCompletionScreen extends ConsumerWidget {
  const ProfileCompletionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUser = ref.watch(userProvider);
    return asyncUser.when(
      data: (user) {
        final bool nameMissing = user.name == null || user.name!.trim().isEmpty;
        return Scaffold(
          backgroundColor: kPrimaryLightColor,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/svg/images/letsgetstarted.svg'),
                SizedBox(
                  height: 10,
                ),
                Text("Let's Get Started,\nComplete your profile",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.unna(
                      color: kGreyDark,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 25, right: 25, top: 10),
                  child: SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: customButton(
                          label: 'Next',
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    settings: const RouteSettings(
                                        name: 'ProfileCompletion'),
                                    builder: (context) => const EditUser()));
                          },
                          fontSize: 16)),
                ),
                if (!nameMissing)
                  TextButton(
                    onPressed: () async {
                      // Check if user has agreed to EULA
                      final eulaAgreed =
                          await SecureStorage.read('eula_agreed');
                      if (eulaAgreed != 'true') {
                        // Show EULA agreement screen if not agreed
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) =>
                                  const EulaAgreementScreen()),
                        );
                        return;
                      }
                      NavigationService navigationService = NavigationService();
                      navigationService.pushNamedReplacement('MainPage');
                    },
                    child: Text(
                      'Skip',
                      style: kSmallTitleB.copyWith(color: kPrimaryColor),
                    ),
                  )
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: LoadingAnimation()),
      error: (error, stackTrace) =>
          const Center(child: Text('Error loading user')),
    );
  }
}
