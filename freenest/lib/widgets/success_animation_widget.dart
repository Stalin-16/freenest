import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class SuccessAnimationWidget extends StatefulWidget {
  final String message;
  final Duration duration;
  final VoidCallback? onAnimationComplete;
  final bool showConfetti;
  final IconData? icon;
  final Color? iconColor;
  final Color? backgroundColor;

  const SuccessAnimationWidget({
    super.key,
    this.message = 'Success!',
    this.duration = const Duration(seconds: 3),
    this.onAnimationComplete,
    this.showConfetti = true,
    this.icon,
    this.iconColor = Colors.green,
    this.backgroundColor,
  });

  @override
  State<SuccessAnimationWidget> createState() => _SuccessAnimationWidgetState();
}

class _SuccessAnimationWidgetState extends State<SuccessAnimationWidget>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _iconScaleAnimation;

  @override
  void initState() {
    super.initState();

    // Confetti controller
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 1500),
    );

    // Main animation controller
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Create animations
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
      ),
    );

    _iconScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    // Start confetti
    if (widget.showConfetti) {
      _confettiController.play();
      await Future.delayed(const Duration(milliseconds: 300));
      _confettiController.play();
    }

    // Start main animation
    _animationController.forward().then((_) {
      // Wait a moment before completing
      Future.delayed(const Duration(milliseconds: 500), () {
        if (widget.onAnimationComplete != null) {
          widget.onAnimationComplete!();
        }
      });
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Confetti background
          if (widget.showConfetti)
            Positioned.fill(
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: -pi / 2,
                emissionFrequency: 0.05,
                numberOfParticles: 25,
                maxBlastForce: 20,
                minBlastForce: 8,
                gravity: 0.2,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                  Colors.yellow,
                  Colors.teal,
                ],
              ),
            ),

          // Center animation
          Positioned.fill(
            child: Container(
              color: widget.backgroundColor ??
                  (isDark ? Colors.black54 : Colors.black26),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Center(
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(90),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.4 : 0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated icon
                        AnimatedBuilder(
                          animation: _iconScaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _iconScaleAnimation.value,
                              child: child,
                            );
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: widget.iconColor!.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: widget.iconColor!.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              widget.icon ?? Icons.check_circle,
                              size: 60,
                              color: widget.iconColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Message with fade in animation
                        FadeTransition(
                          opacity: Tween<double>(begin: 0, end: 1).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.3, 0.6,
                                  curve: Curves.easeIn),
                            ),
                          ),
                          child: Text(
                            widget.message,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: widget.iconColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
