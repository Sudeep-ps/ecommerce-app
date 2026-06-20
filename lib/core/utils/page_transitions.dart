import 'package:flutter/material.dart';

/// A consistent "continuation" transition used for every push in the app:
/// the incoming page fades + scales up from ~92% to 100%, like it's
/// growing out of the tap that triggered it, rather than sliding in from
/// off-screen like the default [MaterialPageRoute].
///
/// Pairs well with widget-level [Hero] animations (e.g. the product image
/// list -> detail) since both run on the same underlying transition clock
/// and settle together rather than competing.
///
/// Usage: replace `MaterialPageRoute(builder: (_) => SomeScreen())` with
/// `SharedAxisRoute(page: SomeScreen())`.
class SharedAxisRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SharedAxisRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 260),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            // Outgoing page (the one being navigated away from) gets a
            // gentle fade + slight scale-down, so it visually recedes
            // rather than just popping away.
            final secondaryCurved = CurvedAnimation(
              parent: secondaryAnimation,
              curve: Curves.easeOutCubic,
            );

            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
                child: FadeTransition(
                  // Fades the *new* page out slightly when something is
                  // pushed on top of it (secondary animation).
                  opacity: Tween<double>(begin: 1.0, end: 0.85)
                      .animate(secondaryCurved),
                  child: child,
                ),
              ),
            );
          },
        );
}
