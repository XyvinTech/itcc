import 'package:flutter/material.dart';
import 'package:itcc/src/data/constants/color_constants.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  TextStyle get _headingStyle => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: kPrimaryColor,
        height: 2.0,
      );

  TextStyle get _subheadingStyle => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: kPrimaryColor,
        height: 1.8,
      );

  TextStyle get _bodyStyle => GoogleFonts.inter(
        fontSize: 15,
        height: 1.6,
        color: Colors.black87,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Privacy Policy',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: kPrimaryColor,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: kPrimaryColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Version info
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Last Updated: April 19, 2025',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  _sectionTitle('Introduction'),
                  _sectionText(
                      'This Privacy Policy describes Our policies and procedures on the '
                      'collection, use and disclosure of Your information when You use the '
                      'Service and tells You about Your privacy rights and how the law protects You.'),
                  SizedBox(height: 16),
                  _sectionText(
                      'We use Your Personal data to provide and improve the Service. By using the '
                      'Service, You agree to the collection and use of information in accordance '
                      'with this Privacy Policy.'),
                  _sectionTitle('Interpretation and Definitions'),
                  _sectionSubtitle('Interpretation'),
                  _sectionText(
                      'The words of which the initial letter is capitalized have meanings defined under the following conditions. '
                      'The following definitions shall have the same meaning regardless of whether they appear in singular or in plural.'),
                  _sectionSubtitle('Definitions'),
                  _sectionText('For the purposes of this Privacy Policy:'),
                  _bulletPoint(
                      'Account means a unique account created for You to access our Service or parts of our Service.'),
                  _bulletPoint(
                      'Affiliate means an entity that controls, is controlled by or is under common control with a party, '
                      'where "control" means ownership of 50% or more of the shares, equity interest or other securities entitled '
                      'to vote for election of directors or other managing authority.'),
                  _bulletPoint(
                      'Application refers to ITCC, the software program provided by the Company.'),
                  _bulletPoint(
                      'Company refers to Skybertech IT Innovations Pvt Ltd, Infopark Technology Business Centre Sector D, E & F Hall, '
                      'JNI Stadium Complex, Kaloor Kochi, Kerala 682 017, IN.'),
                  SizedBox(height: 16),

                  // Add more sections following the same pattern...
                  _sectionTitle('Contact Us'),
                  _sectionText(
                      'If you have any questions about this Privacy Policy, You can contact us:'),
                  _bulletPoint('By email: mail@skybertech.com'),
                  _bulletPoint(
                      'By visiting this page on our website: www.skybertech.com'),
                  _bulletPoint('By phone number: +918138916303'),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: _headingStyle,
      ),
    );
  }

  Widget _sectionSubtitle(String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        subtitle,
        style: _subheadingStyle,
      ),
    );
  }

  Widget _sectionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: _bodyStyle,
      ),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: _bodyStyle),
          Expanded(
            child: Text(
              text,
              style: _bodyStyle,
            ),
          ),
        ],
      ),
    );
  }
}
