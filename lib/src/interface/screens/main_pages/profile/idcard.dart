import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:itcc/src/data/constants/color_constants.dart';
import 'package:itcc/src/data/constants/style_constants.dart';
import 'package:itcc/src/data/models/user_model.dart';
import 'package:itcc/src/data/services/extract_level_details.dart';
import 'package:itcc/src/data/services/save_qr.dart';
import 'package:itcc/src/data/services/share_qr.dart';
import 'package:itcc/src/interface/components/Buttons/primary_button.dart';
import 'package:itcc/src/interface/components/animations/glowing_profile.dart';
import 'package:itcc/src/interface/components/custom_widgets/custom_icon_container.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

// Simple provider for fullscreen state
final isFullScreenProvider = StateProvider<bool>((ref) => false);

class IDCardScreen extends ConsumerWidget {
  final UserModel user;

  const IDCardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ScreenshotController screenshotController = ScreenshotController();

    final isFullScreen = ref.watch(isFullScreenProvider);
    final designations = user.company!
        .map((i) => i.designation)
        .where((d) => d != null && d.isNotEmpty)
        .map((d) => d!)
        .toList();

    final companyNames = user.company!
        .map((i) => i.name)
        .where((n) => n != null && n.isNotEmpty)
        .map((n) => n!)
        .toList();

    String joinedDate = DateFormat('dd/MM/yyyy').format(user.createdAt!);
    Map<String, String> levelData = extractLevelDetails(user.level ?? '');

    return Scaffold(
      // Animated AppBar that appears only in normal mode
      appBar: isFullScreen
          ? null
          : AppBar(
              flexibleSpace: Container(),
              centerTitle: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              bottom: PreferredSize(
                preferredSize: const Size(double.infinity, 0),
                child: Container(
                    width: double.infinity, height: 1, color: kTertiary),
              ),
              backgroundColor: kWhite,
              title: const Text(
                'Preview',
                style: kSmallTitleR,
              ),
            ),
      body: Screenshot(controller: screenshotController,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0B96F5),
                Color(0xFF0C1E8A),
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                AnimatedAlign(
                  alignment:
                      isFullScreen ? Alignment.topCenter : Alignment.center,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  child: SingleChildScrollView(
                    physics: isFullScreen
                        ? const AlwaysScrollableScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: isFullScreen ? 70 : 0,
                        bottom: isFullScreen
                            ? 20
                            : 100, // Add extra padding at bottom in normal mode for button
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 40,
                          ),
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                                width: isFullScreen
                                    ? MediaQuery.of(context).size.width - 40
                                    : MediaQuery.of(context).size.width * 0.85,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                padding:
                                    const EdgeInsets.only(top: 60, bottom: 20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    QrImageView(
                                      data:
                                          'https://admin.itccconnect.com/user/${user.uid}',
                                      version: QrVersions.auto,
                                      size: 150,
                                      foregroundColor: Colors.white,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(user.name ?? '',
                                        style:
                                            kLargeTitleB.copyWith(color: kWhite),
                                        textAlign: TextAlign.center),
                                    // Use AnimatedSize to create smooth transition for content
                                    AnimatedSize(
                                      duration: const Duration(milliseconds: 400),
                                      curve: Curves.easeInOut,
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: isFullScreen
                                            ? Column(
                                                children: [
                                                  if (designations.isNotEmpty ||
                                                      companyNames.isNotEmpty)
                                                    Column(
                                                      children: [
                                                        if (designations
                                                            .isNotEmpty)
                                                          Text(
                                                            designations
                                                                .join(' | '),
                                                            style:
                                                                const TextStyle(
                                                                    fontSize: 12,
                                                                    color: Colors
                                                                        .white),
                                                            textAlign:
                                                                TextAlign.center,
                                                          ),
                                                        if (companyNames
                                                            .isNotEmpty)
                                                          Text(
                                                            companyNames
                                                                .join(' | '),
                                                            style:
                                                                const TextStyle(
                                                                    fontSize: 12,
                                                                    color: Colors
                                                                        .white),
                                                            textAlign:
                                                                TextAlign.center,
                                                          ),
                                                      ],
                                                    ),
                                                  const SizedBox(height: 10),
                                                  Wrap(
                                                    alignment:
                                                        WrapAlignment.center,
                                                    children: [
                                                      Text(
                                                          '${levelData['stateName']} / ',
                                                          style: const TextStyle(
                                                              color: kWhite,
                                                              fontSize: 12)),
                                                      Text(
                                                          '${levelData['zoneName']} / ',
                                                          style: const TextStyle(
                                                              color: kWhite,
                                                              fontSize: 12)),
                                                      Text(
                                                          '${levelData['districtName']} / ',
                                                          style: const TextStyle(
                                                              color: kWhite,
                                                              fontSize: 12)),
                                                      Text(
                                                          '${levelData['chapterName']}',
                                                          style: const TextStyle(
                                                              color: kWhite,
                                                              fontSize: 12)),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    'Joined Date: $joinedDate',
                                                    style: const TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.white),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Center(
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 6),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                10),
                                                      ),
                                                      child: IntrinsicWidth(
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 10),
                                                              child: Image.asset(
                                                                  scale: 20,
                                                                  'assets/pngs/itcc_logo.png'),
                                                            ),
                                                            const SizedBox(
                                                                width: 10),
                                                            Text(
                                                                'Member ID: ${user.memberId}',
                                                                style: kSmallerTitleB
                                                                    .copyWith(
                                                                        color:
                                                                            kPrimaryColor)),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : const SizedBox.shrink(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Profile picture avatar
                              Positioned(
                                top: -75,
                                child: GlowingAnimatedAvatar(
                                  imageUrl: user.image,
                                  defaultAvatarAsset:
                                      'assets/svg/icons/dummy_person_large.svg',
                                  size: 110,
                                  glowColor: Colors.white,
                                  borderColor: Colors.white,
                                  borderWidth: 3.0,
                                ),
                              ),
                            ],
                          ),
                          // Use AnimatedOpacity + AnimatedContainer for contact section
                          AnimatedOpacity(
                            opacity: isFullScreen ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                              height: isFullScreen ? null : 0,
                              child: Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 40),
                                    height: 1,
                                    child: CustomPaint(
                                      size: const Size(double.infinity, 1),
                                      painter: DottedLinePainter(),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 30),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      children: [
                                        ContactRow(
                                            icon: Icons.phone,
                                            text: user.phone ?? ''),
                                        const SizedBox(height: 10),
                                        ContactRow(
                                            icon: Icons.email,
                                            text: user.email ?? ''),
                                        const SizedBox(height: 10),
                                        ContactRow(
                                            icon: Icons.location_on,
                                            text: user.address ?? ''),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        
                // Fullscreen toggle button - positioned similarly in both modes
                Positioned(
                  top: isFullScreen ? 10 : 20,
                  right: 16,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => ref
                            .read(isFullScreenProvider.notifier)
                            .state = !isFullScreen,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            isFullScreen
                                ? Icons.close_fullscreen_outlined
                                : Icons.open_in_full,
                            color: Colors.indigo,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        
                // Download button at bottom (only visible in normal mode)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedOpacity(
                    opacity: isFullScreen ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: isFullScreen ? 0 : 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SizedBox(
                          height: 50,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 15),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Flexible(
                                  child: customButton(
                                      buttonHeight: 60,
                                      fontSize: 16,
                                      label: 'Share',
                                      onPressed: () async {
                                        captureAndShareOrDownloadWidgetScreenshot(context);
                                      }),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Flexible(
                                  child: customButton(
                                      sideColor: kPrimaryColor,
                                      labelColor: kPrimaryColor,
                                      buttonColor: kWhite,
                                      buttonHeight: 60,
                                      fontSize: 15,
                                      label: 'Download QR',
                                      onPressed: () async {
                                             captureAndShareOrDownloadWidgetScreenshot(context,download: true);
                                      }),
                                ),
                              ],
                            ),
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const ContactRow({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomIconContainer(
          icon: icon,
          backgroundColor: kWhite,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
          ),
        )
      ],
    );
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 5.0;
    const dashSpace = 5.0;
    final paint = Paint()
      ..color = Colors.white38
      ..strokeWidth = 2.0;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
