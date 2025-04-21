import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:itcc/src/data/constants/color_constants.dart';
import 'package:itcc/src/data/router/nav_router.dart';
import 'package:itcc/src/data/services/navgitor_service.dart';
import 'package:itcc/src/interface/components/Buttons/primary_button.dart';

class PremiumDialog extends ConsumerWidget {
  const PremiumDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(selectedIndexProvider.notifier).updateIndex(0);
        }
      },
      child: AlertDialog(
        backgroundColor: kPrimaryLightColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: EdgeInsets.all(10),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F38C2), Color(0xFF072182)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              const PulseIcon(),
              const SizedBox(width: 8),
              const Text(
                'Premium',
                style: TextStyle(
                  color: Colors.white, // To contrast against the dark gradient
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        content: const Text(
          'This feature is available for Premium members only.\n\n'
          'Activate Premium now to start unlocking powerful tools and grow your reach like never before!',
        ),
        actions: [
          customButton(
            label: 'Activate Premium',
            onPressed: () {
              NavigationService navigationService = NavigationService();
              navigationService.pushNamed('MySubscriptionPage');
            },
          )
        ],
      ),
    );
  }
}

class PulseIcon extends StatefulWidget {
  const PulseIcon({super.key});

  @override
  State<PulseIcon> createState() => _PulseIconState();
}

class _PulseIconState extends State<PulseIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFDADFFF),
            width: 1,
          ),
        ),
        child: Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 166, 176, 211),
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset('assets/svg/icons/premium_lock.svg'),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD700),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.star, color: Colors.white, size: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
