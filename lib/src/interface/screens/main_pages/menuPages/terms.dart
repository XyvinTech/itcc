import 'package:flutter/material.dart';
import 'package:itcc/src/data/constants/color_constants.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  TextStyle get _headingStyle => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: kPrimaryColor,
        height: 2.0,
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
          'Terms & Conditions',
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
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
              const SizedBox(height: 24),
              RichText(
                text: TextSpan(
                  style: _bodyStyle,
                  children: [
                    TextSpan(
                      text: '1. Acceptance of Terms\n',
                      style: _headingStyle, // Style for heading
                    ),
                    TextSpan(
                      text:
                          'By accessing and using the ITCC app, you acknowledge that you have read, understood, and agree to be bound by these Terms, as well as our Privacy Policy. These Terms apply to all users of the App.\n\n',
                    ),
                    TextSpan(
                      text: '2. Changes to Terms\n',
                      style: _headingStyle, // Style for heading
                    ),
                    TextSpan(
                      text:
                          'We reserve the right to modify or update these Terms at any time. Any changes will be effective immediately upon posting. Continued use of the App after any such changes constitutes your acceptance of the new Terms. It is your responsibility to review these Terms periodically.\n\n',
                    ),
                    TextSpan(
                      text: '3. User Accounts\n',
                      style: _headingStyle, // Style for heading
                    ),
                    TextSpan(
                      text:
                          'To access certain features of the App, you may be required to create an account. You agree to provide accurate, current, and complete information when creating your account. You are responsible for maintaining the confidentiality of your account information and for all activities that occur under your account.\n\n',
                    ),
                    TextSpan(
                      text: '4. User-Generated Content\n',
                      style: _headingStyle,
                    ),
                    TextSpan(
                      text:
                          '''By submitting, posting, or displaying content on or through the App ('User Content'), you grant us a worldwide, non-exclusive, royalty-free license to use, copy, reproduce, process, adapt, modify, publish, transmit, display and distribute such content. You represent and warrant that you have all rights, licenses, consents and permissions necessary to grant these rights.

You are solely responsible for your User Content and the consequences of posting or publishing it. We do not endorse any User Content or any opinion, recommendation, or advice expressed therein, and we expressly disclaim any and all liability in connection with User Content.

We reserve the right to:
- Review, screen, and monitor User Content
- Remove or refuse to display content that violates these Terms or applicable laws
- Take appropriate legal action against users who repeatedly infringe or are believed to be infringing the rights of others

Prohibited Content includes but is not limited to:
- Hate speech or discriminatory content
- Sexually explicit material
- Violence or graphic content
- Harassment or bullying
- Spam or deceptive practices
- Content that promotes illegal activities
- Personal or confidential information of others
- Content that infringes intellectual property rights\n\n''',
                    ),
                    TextSpan(
                      text: '5. End User License Agreement (EULA)\n',
                      style: _headingStyle,
                    ),
                    TextSpan(
                      text:
                          '''This End User License Agreement ('EULA') is a binding agreement between you and ITCC. By installing or using the App, you agree to be bound by the terms of this EULA.

License Grant: Subject to your compliance with these Terms, we grant you a limited, non-exclusive, non-transferable, non-sublicensable, revocable license to download, install, and use the App for your personal, non-commercial use.

Restrictions: You may not:
- Modify, reverse engineer, decompile, or disassemble the App
- Remove proprietary notices from the App
- Use the App in violation of applicable laws
- Transfer, sublicense, or assign your rights under this license

The App is licensed, not sold, to you. We reserve all rights not expressly granted to you.\n\n''',
                    ),
                    TextSpan(
                      text: '6. Use of the App\n',
                      style: _headingStyle,
                    ),
                    TextSpan(
                      text:
                          '''The App is intended for personal, non-commercial use only. You agree not to use the App for any unlawful or prohibited purpose, including but not limited to:

- Engaging in fraudulent activities
- Harassing or threatening other users
- Uploading, sharing, or distributing any content that is offensive, defamatory, or infringing on intellectual property rights
- Attempting to gain unauthorized access to the App, other user accounts, or our systems\n\n''',
                    ),
                    TextSpan(
                      text: '7. Intellectual Property\n',
                      style: _headingStyle, // Style for heading
                    ),
                    TextSpan(
                      text:
                          '''All content, trademarks, logos, and intellectual property related to the App are owned by or licensed to ITCC. You may not reproduce, distribute, or otherwise exploit the content for commercial purposes without written consent from ITCC.
''',
                    ),
                    TextSpan(
                      text: '8. Privacy Policy\n',
                      style: _headingStyle, // Style for heading
                    ),
                    TextSpan(
                      text:
                          '''Your use of the App is also governed by our Privacy Policy, which outlines how we collect, use, and protect your personal information. By using the App, you consent to the collection and use of your data as outlined in the Privacy Policy.\n\n''',
                    ),
                    TextSpan(
                      text: '9. Termination\n',
                      style: _headingStyle, // Style for heading
                    ),
                    TextSpan(
                      text:
                          '''We reserve the right to suspend or terminate your account and access to the App at our sole discretion, without notice or liability, for any reason, including but not limited to a violation of these Terms.\n\n''',
                    ),
                    TextSpan(
                      text: '10. Limitation of Liability\n',
                      style: _headingStyle, // Style for heading
                    ),
                    TextSpan(
                      text:
                          '''ITCC is not liable for any direct, indirect, incidental, or consequential damages arising from your use or inability to use the App. The App is provided on an "as-is" and "as available" basis without warranties of any kind.\n\n''',
                    ),
                    TextSpan(
                      text: '12. Contact Information\n',
                      style: _headingStyle, // Style for heading
                    ),
                    TextSpan(
                      text:
                          '''For any questions regarding these Terms, please contact us at mail@skybertech.com\n\n''',
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
