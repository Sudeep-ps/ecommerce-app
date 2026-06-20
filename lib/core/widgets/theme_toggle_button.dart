import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/theme_provider.dart';

class ThemeRevealController {
  _ThemeRevealWrapperState? _state;

  void _attach(_ThemeRevealWrapperState state) => _state = state;
  void _detach() => _state = null;

  void revealFrom(Offset origin) => _state?._startReveal(origin);
}

class ThemeRevealWrapper extends ConsumerStatefulWidget {
  final Widget child;
  final ThemeRevealController controller;

  const ThemeRevealWrapper({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  ConsumerState<ThemeRevealWrapper> createState() => _ThemeRevealWrapperState();
}

class _ThemeRevealWrapperState extends ConsumerState<ThemeRevealWrapper>
    with SingleTickerProviderStateMixin {
  final GlobalKey _repaintKey = GlobalKey();
  late final AnimationController _controller;
  late final Animation<double> _radius;

  ui.Image? _snapshot;
  Offset? _origin;

  @override
  void initState() {
    super.initState();
    widget.controller._attach(this);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _radius =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _snapshot = null);
        _origin = null;
      }
    });
  }

  @override
  void didUpdateWidget(covariant ThemeRevealWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller._detach();
      widget.controller._attach(this);
    }
  }

  @override
  void dispose() {
    widget.controller._detach();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startReveal(Offset origin) async {
    final boundary = _repaintKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return;

    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    if (!mounted) return;

    setState(() {
      _snapshot = image;
      _origin = origin;
    });

    ref.read(themeModeProvider.notifier).toggleTheme();

    _controller
      ..reset()
      ..forward();
  }

  double _maxRadiusFor(Size size, Offset origin) {
    final corners = [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];
    var maxDist = 0.0;
    for (final corner in corners) {
      final dist = (corner - origin).distance;
      if (dist > maxDist) maxDist = dist;
    }
    return maxDist;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RepaintBoundary(key: _repaintKey, child: widget.child),
        if (_snapshot != null && _origin != null)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _radius,
                builder: (context, _) {
                  final size = MediaQuery.of(context).size;
                  final maxRadius = _maxRadiusFor(size, _origin!);

                  return ClipPath(
                    clipper: _CircleRevealClipper(
                      center: _origin!,
                      radius: maxRadius * _radius.value,
                    ),
                    child: RawImage(image: _snapshot, fit: BoxFit.cover),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _CircleRevealClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  _CircleRevealClipper({required this.center, required this.radius});

  @override
  Path getClip(Size size) {
    final circle = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    final full = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    return Path.combine(PathOperation.difference, full, circle);
  }

  @override
  bool shouldReclip(covariant _CircleRevealClipper oldClipper) {
    return oldClipper.center != center || oldClipper.radius != radius;
  }
}

class ThemeToggleButton extends ConsumerWidget {
  final ThemeRevealController revealController;

  const ThemeToggleButton({super.key, required this.revealController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Builder(
      builder: (buttonContext) {
        return IconButton(
          tooltip: 'Toggle dark mode',
          onPressed: () {
            final box = buttonContext.findRenderObject() as RenderBox?;
            final origin = box != null
                ? box.localToGlobal(box.size.center(Offset.zero))
                : MediaQuery.of(context).size.center(Offset.zero);
            revealController.revealFrom(origin);
          },
          icon: TweenAnimationBuilder<double>(
            key: ValueKey(isDark),
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.rotate(
                angle: (1 - value) * math.pi / 2,
                child: Transform.scale(
                  scale: 0.6 + (0.4 * value),
                  child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
                ),
              );
            },
            child: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              key: ValueKey('icon-$isDark'),
            ),
          ),
        );
      },
    );
  }
}
