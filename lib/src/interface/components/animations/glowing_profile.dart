import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GlowingAnimatedAvatar extends StatefulWidget {
  final String? imageUrl;
  final String defaultAvatarAsset;
  final double size;
  final Color glowColor;
  final Color borderColor;
  final double borderWidth;

  const GlowingAnimatedAvatar({
    Key? key,
    this.imageUrl,
    required this.defaultAvatarAsset,
    this.size = 100,
    this.glowColor = Colors.white,
    this.borderColor = Colors.white,
    this.borderWidth = 3.0,
  }) : super(key: key);

  @override
  _GlowingAnimatedAvatarState createState() => _GlowingAnimatedAvatarState();
}

class _GlowingAnimatedAvatarState extends State<GlowingAnimatedAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.6, end: 1.4).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 1.6,
      height: widget.size * 1.3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildPulseRing(delay: 0.0),
          _buildPulseRing(delay: 0.5),
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.borderColor,
                width: widget.borderWidth,
              ),
            ),
            padding: EdgeInsets.all(widget.borderWidth),
            child: ClipOval(
              child: _buildChildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseRing({required double delay}) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double progress = (_controller.value + delay) % 1.0;
        double scale = 1.0 + (progress * 0.2); // subtle scale: 1.0 to 1.2
        double opacity = (1 - progress).clamp(0.0, 1.0);

        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.glowColor.withOpacity(0.4),
                    spreadRadius: 2,
                    blurRadius: 10,
                  ),
                ],
                border: Border.all(
                  color: widget.glowColor.withOpacity(0.6),
                  width: 2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChildContent() {
    final bool hasValidImage =
        widget.imageUrl != null && widget.imageUrl!.isNotEmpty;

    if (hasValidImage) {
      return ClipOval(
        child: Image.network(
          widget.imageUrl!,
          width: widget.size - 10,
          height: widget.size - 10,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackAvatar();
          },
        ),
      );
    } else {
      return _buildFallbackAvatar();
    }
  }

  Widget _buildFallbackAvatar() {
    return SvgPicture.asset(
      widget.defaultAvatarAsset,
      width: widget.size - 10,
      height: widget.size - 10,
    );
  }
}
