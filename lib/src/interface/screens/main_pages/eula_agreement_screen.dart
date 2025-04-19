import 'package:flutter/material.dart';
import 'package:itcc/src/data/constants/color_constants.dart';
import 'package:itcc/src/data/services/navgitor_service.dart';
import 'package:itcc/src/data/utils/secure_storage.dart';
import 'package:itcc/src/interface/screens/main_pages/menuPages/terms.dart';
import 'package:itcc/src/interface/screens/main_pages/profile/editUser.dart';

class EulaAgreementScreen extends StatelessWidget {
  const EulaAgreementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    NavigationService navigationService = NavigationService();
    return Scaffold(
      backgroundColor: kPrimaryLightColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: kPrimaryLightColor,
        elevation: 0,
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TermsAndConditionsPage(),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Save that user has agreed to terms
                      await SecureStorage.write('eula_agreed', 'true');

                      navigationService.pushNamedReplacement('ProfileCompletion');
                    
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'I Agree to Terms & Conditions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      SecureStorage.deleteAll();
                      navigationService.pushNamedReplacement('PhoneNumber');
                    },
                    child: const Text(
                      'Decline',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
