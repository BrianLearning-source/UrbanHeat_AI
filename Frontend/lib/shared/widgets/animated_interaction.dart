import 'package:flutter/material.dart';

class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.scale = 0.985,
    this.elevation = 0,
    this.shadowColor = Colors.black12,
    this.borderRadius = BorderRadius.zero,
  });

  final Widget child;
  final double scale;
  final double elevation;
  final Color shadowColor;
  final BorderRadius borderRadius;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  final Set<int> _activePointers = <int>{};

  void _handlePointerDown(PointerDownEvent event) {
    setState(() => _activePointers.add(event.pointer));
  }

  void _handlePointerEnd(PointerEvent event) {
    if (_activePointers.remove(event.pointer)) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerUp: _handlePointerEnd,
      onPointerCancel: _handlePointerEnd,
      child: AnimatedPhysicalModel(
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        elevation: !reduceMotion && _activePointers.isNotEmpty
            ? widget.elevation
            : 0,
        color: Colors.transparent,
        shadowColor: widget.shadowColor,
        borderRadius: widget.borderRadius,
        shape: BoxShape.rectangle,
        clipBehavior: Clip.none,
        child: AnimatedScale(
          scale: !reduceMotion && _activePointers.isNotEmpty ? widget.scale : 1,
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: widget.child,
        ),
      ),
    );
  }
}

class StaggeredEntrance extends StatefulWidget {
  const StaggeredEntrance({
    super.key,
    required this.child,
    required this.delay,
  });

  final Widget child;
  final Duration delay;

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance> {
  late bool _visible;

  @override
  void initState() {
    super.initState();
    _visible = false;
    Future<void>.delayed(widget.delay, () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final visible = _visible || reduceMotion;

    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, 0.035),
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
