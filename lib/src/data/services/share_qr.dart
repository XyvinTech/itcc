import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:itcc/src/data/constants/color_constants.dart';
import 'package:itcc/src/data/constants/style_constants.dart';
import 'package:itcc/src/data/models/user_model.dart';
import 'package:itcc/src/data/services/extract_level_details.dart';
import 'package:itcc/src/data/services/snackbar_service.dart';
import 'package:itcc/src/interface/components/Buttons/primary_button.dart';
import 'package:itcc/src/interface/components/animations/glowing_profile.dart';
import 'package:itcc/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:itcc/src/interface/screens/main_pages/profile/idcard.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itcc/src/data/notifiers/user_notifier.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

Future<void> captureAndShareOrDownloadWidgetScreenshot(BuildContext context,
    {bool download = false}) async {
  // Create a GlobalKey to hold the widget's RepaintBoundary
  final boundaryKey = GlobalKey();
  String userId = '';
  // Define the widget to capture
  final widgetToCapture = RepaintBoundary(
    key: boundaryKey,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Consumer(
          builder: (context, ref, child) {
            final asyncUser = ref.watch(userProvider);
            return asyncUser.when(
              data: (user) {
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

                String joinedDate =
                    DateFormat('dd/MM/yyyy').format(user.createdAt!);
                Map<String, String> levelData =
                    extractLevelDetails(user.level ?? '');
                userId = user.uid ?? '';
                return Container(
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
                          alignment: Alignment.topCenter,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: 70,
                                bottom:
                                    20, // Add extra padding at bottom in normal mode for button
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
                                        duration:
                                            const Duration(milliseconds: 400),
                                        curve: Curves.easeInOut,
                                        width:
                                            MediaQuery.of(context).size.width -
                                                40,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        padding: const EdgeInsets.only(
                                            top: 60, bottom: 20),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                                style: kLargeTitleB.copyWith(
                                                    color: kWhite),
                                                textAlign: TextAlign.center),
                                            // Use AnimatedSize to create smooth transition for content
                                            AnimatedSize(
                                              duration: const Duration(
                                                  milliseconds: 400),
                                              curve: Curves.easeInOut,
                                              child: Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                                child: Column(
                                                  children: [
                                                    if (designations
                                                            .isNotEmpty ||
                                                        companyNames.isNotEmpty)
                                                      Column(
                                                        children: [
                                                          if (designations
                                                              .isNotEmpty)
                                                            Text(
                                                              designations
                                                                  .join(' | '),
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .white),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          if (companyNames
                                                              .isNotEmpty)
                                                            Text(
                                                              companyNames
                                                                  .join(' | '),
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .white),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
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
                                                            style:
                                                                const TextStyle(
                                                                    color:
                                                                        kWhite,
                                                                    fontSize:
                                                                        12)),
                                                        Text(
                                                            '${levelData['zoneName']} / ',
                                                            style:
                                                                const TextStyle(
                                                                    color:
                                                                        kWhite,
                                                                    fontSize:
                                                                        12)),
                                                        Text(
                                                            '${levelData['districtName']} / ',
                                                            style:
                                                                const TextStyle(
                                                                    color:
                                                                        kWhite,
                                                                    fontSize:
                                                                        12)),
                                                        Text(
                                                            '${levelData['chapterName']}',
                                                            style:
                                                                const TextStyle(
                                                                    color:
                                                                        kWhite,
                                                                    fontSize:
                                                                        12)),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      'Joined Date: $joinedDate',
                                                      style: const TextStyle(
                                                          fontSize: 11,
                                                          color: Colors.white),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Center(
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 10,
                                                                vertical: 6),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: IntrinsicWidth(
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10),
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
                                                ),
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
                                    opacity: 1.0,
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      curve: Curves.easeInOut,
                                      child: Column(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 40),
                                            height: 1,
                                            child: CustomPaint(
                                              size: const Size(
                                                  double.infinity, 1),
                                              painter: DottedLinePainter(),
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 30),
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.3),
                                              borderRadius:
                                                  BorderRadius.circular(20),
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
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Center(child: LoadingAnimation()),
              error: (error, stackTrace) =>
                  const Center(child: Text('Error loading user')),
            );
          },
        ),
      ),
    ),
  );

  // Create an OverlayEntry to render the widget
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (_) => Material(
      color: Colors.transparent,
      child: Center(child: widgetToCapture),
    ),
  );

  // Add the widget to the overlay
  overlay.insert(overlayEntry);

  // Allow time for rendering
  await Future.delayed(const Duration(milliseconds: 500));

  // Capture the screenshot
  final boundary =
      boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) {
    overlayEntry.remove(); // Clean up the overlay
    return;
  }

  // Convert to image
  final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
  final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
  overlayEntry.remove(); // Clean up the overlay

  if (byteData == null) return;

  final Uint8List pngBytes = byteData.buffer.asUint8List();

  // Save the image as a temporary file
  final tempDir = await getTemporaryDirectory();
  final file =
      await File('${tempDir.path}/screenshot.png').writeAsBytes(pngBytes);

  if (download) {
    // Save to gallery
    final result = await ImageGallerySaverPlus.saveFile(file.path);
    SnackbarService snackbarService = SnackbarService();
    snackbarService.showSnackBar(result['isSuccess'] == true
        ? 'QR saved to gallery!'
        : 'Failed to save QR.');
  } else {
    // Share
    Share.shareXFiles(
      [XFile(file.path)],
      text:
          'Check out my profile on ITCC!:\n https://admin.itccconnect.com/user/${userId}',
    );
  }
}
